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
}
