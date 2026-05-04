import 'package:kakao_map_sdk/kakao_map_sdk.dart' show LatLng;

class RouteSegment {
  final String from;
  final String to;
  final String mode;
  final int distance; // meters
  final int duration; // minutes

  /// 백엔드 응답 형식 `[[lng, lat], ...]`. 네이버 directions 응답을 그대로 보존.
  /// 좌표 변환은 [pathLatLngs] getter에서 수행.
  final List<List<double>>? path;

  const RouteSegment({
    required this.from,
    required this.to,
    required this.mode,
    required this.distance,
    required this.duration,
    this.path,
  });

  /// 1구간당 path 좌표 상한. 초과 시 FormatException — 호출자가 흡수해 fallback 직선 사용.
  static const int kMaxPathPoints = 5000;

  factory RouteSegment.fromJson(Map<String, dynamic> json) {
    List<List<double>>? parsedPath;
    final raw = json['path'];
    if (raw is List) {
      if (raw.length > kMaxPathPoints) {
        throw FormatException(
          'RouteSegment.path too long: ${raw.length} > $kMaxPathPoints',
        );
      }
      parsedPath = raw.map<List<double>>((p) {
        if (p is! List || p.length < 2) {
          throw const FormatException('RouteSegment.path: invalid point shape');
        }
        final lng = (p[0] as num).toDouble();
        final lat = (p[1] as num).toDouble();
        if (lng.isNaN || lng.isInfinite || lat.isNaN || lat.isInfinite) {
          throw const FormatException('RouteSegment.path: non-finite coordinate');
        }
        if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
          throw const FormatException('RouteSegment.path: coordinate out of range');
        }
        return [lng, lat];
      }).toList(growable: false);
    }

    return RouteSegment(
      from: json['from'] as String,
      to: json['to'] as String,
      mode: json['mode'] as String,
      distance: (json['distance'] as num).toInt(),
      duration: (json['duration'] as num).toInt(),
      path: parsedPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'from': from,
        'to': to,
        'mode': mode,
        'distance': distance,
        'duration': duration,
        if (path != null) 'path': path,
      };

  bool get hasPath => path != null && path!.isNotEmpty;

  /// 카카오맵 LatLng 형식으로 변환. path는 `[lng, lat]` 순서이므로 lat/lng 스왑.
  /// fromJson에서 검증을 마쳤으므로 여기서는 silent drop 없이 단순 변환.
  List<LatLng> get pathLatLngs {
    if (!hasPath) return const [];
    return path!
        .map((p) => LatLng(p[1], p[0]))
        .toList(growable: false);
  }

  String get distanceLabel {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
    return '${distance}m';
  }

  String get durationLabel {
    if (duration >= 60) {
      final hours = duration ~/ 60;
      final mins = duration % 60;
      return mins > 0 ? '${hours}시간 ${mins}분' : '${hours}시간';
    }
    return '$duration분';
  }

  String get modeLabel => switch (mode) {
        'driving' => '자동차',
        'transit' => '대중교통',
        'walking' => '도보',
        _ => mode,
      };
}
