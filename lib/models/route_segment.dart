class RouteSegment {
  final String from;
  final String to;
  final String mode;
  final int distance; // meters
  final int duration; // minutes

  const RouteSegment({
    required this.from,
    required this.to,
    required this.mode,
    required this.distance,
    required this.duration,
  });

  factory RouteSegment.fromJson(Map<String, dynamic> json) => RouteSegment(
        from: json['from'] as String,
        to: json['to'] as String,
        mode: json['mode'] as String,
        distance: (json['distance'] as num).toInt(),
        duration: (json['duration'] as num).toInt(),
      );

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
