import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/travel_route.dart';

void main() {
  group('TravelRoute.fromGenerateAndDirections', () {
    test('generate + directions JSON을 합쳐서 TravelRoute를 생성', () {
      final route = TravelRoute.fromGenerateAndDirections(
        {
          'places': [
            {'slot': 'breakfast', 'name': '순두부젤라또', 'coordinates': {'lat': 37.79, 'lng': 128.91}, 'reason': '강릉 명물', 'estimatedBudget': 12000},
            {'slot': 'morning_cafe', 'name': '테라로사', 'coordinates': {'lat': 37.78, 'lng': 128.90}, 'reason': '커피 맛집', 'estimatedBudget': 8000},
          ],
          'totalBudget': 20000,
          'comment': '강릉 맛집 투어',
        },
        {
          'segments': [{'from': '순두부젤라또', 'to': '테라로사', 'mode': 'driving', 'distance': 3200, 'duration': 10}],
          'totalDistance': 3200,
          'totalDuration': 10,
        },
      );
      expect(route.places.length, 2);
      expect(route.segments.length, 1);
      expect(route.totalBudget, 20000);
      expect(route.comment, '강릉 맛집 투어');
    });
  });
}
