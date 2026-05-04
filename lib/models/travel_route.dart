import 'place.dart';
import 'route_segment.dart';

class TravelRoute {
  final List<Place> places;
  final List<RouteSegment> segments;
  final int totalBudget;
  final int totalDistance;
  final int totalDuration;
  final String comment;

  const TravelRoute({
    required this.places,
    required this.segments,
    required this.totalBudget,
    required this.totalDistance,
    required this.totalDuration,
    required this.comment,
  });

  factory TravelRoute.fromGenerateAndDirections(
    Map<String, dynamic> generateJson,
    Map<String, dynamic> directionsJson,
  ) {
    final places = (generateJson['places'] as List)
        .map((p) => Place.fromJson(p as Map<String, dynamic>))
        .toList();

    final segments = (directionsJson['segments'] as List)
        .map((s) => RouteSegment.fromJson(s as Map<String, dynamic>))
        .toList();

    return TravelRoute(
      places: places,
      segments: segments,
      totalBudget: (generateJson['totalBudget'] as num).toInt(),
      totalDistance: (directionsJson['totalDistance'] as num).toInt(),
      totalDuration: (directionsJson['totalDuration'] as num).toInt(),
      comment: generateJson['comment'] as String? ?? '',
    );
  }

  TravelRoute copyWith({
    List<Place>? places,
    List<RouteSegment>? segments,
    int? totalBudget,
    int? totalDistance,
    int? totalDuration,
    String? comment,
  }) =>
      TravelRoute(
        places: places ?? this.places,
        segments: segments ?? this.segments,
        totalBudget: totalBudget ?? this.totalBudget,
        totalDistance: totalDistance ?? this.totalDistance,
        totalDuration: totalDuration ?? this.totalDuration,
        comment: comment ?? this.comment,
      );

  /// 장소를 [oldIndex] → [newIndex]로 이동한 새 라우트를 반환.
  ///
  /// segments는 비운다 — 호출자(route_provider)가 디바운스 후 /api/directions 재호출로
  /// 새 segments를 채운다. totalDistance/totalDuration도 0으로 초기화.
  /// totalBudget은 places 합산이 아닌 AI 추천값이므로 유지.
  TravelRoute reorderPlaces(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= places.length) return this;
    if (newIndex < 0 || newIndex > places.length) return this;
    if (oldIndex == newIndex) return this;

    // ReorderableListView 컨벤션: newIndex가 oldIndex보다 크면 -1 (제거 후 insert 인덱스 보정)
    final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    if (adjustedNewIndex == oldIndex) return this; // 보정 후 동일 위치면 단축

    final newPlaces = [...places];
    final moved = newPlaces.removeAt(oldIndex);
    newPlaces.insert(adjustedNewIndex, moved);

    return copyWith(
      places: newPlaces,
      segments: const [],
      totalDistance: 0,
      totalDuration: 0,
    );
  }

  /// [index] 위치의 장소를 제거한 새 라우트를 반환.
  /// segments는 비운다 (재계산 필요).
  TravelRoute removePlace(int index) {
    if (index < 0 || index >= places.length) return this;

    final newPlaces = [...places]..removeAt(index);

    return copyWith(
      places: newPlaces,
      segments: const [],
      totalDistance: 0,
      totalDuration: 0,
    );
  }
}
