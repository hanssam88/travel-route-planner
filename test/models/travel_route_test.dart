import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/place.dart';
import 'package:travel_route_planner/models/route_segment.dart';
import 'package:travel_route_planner/models/travel_route.dart';

Place _place(String name, {String slot = 'lunch', double lat = 37, double lng = 127}) =>
    Place(
      slot: slot,
      name: name,
      address: '',
      roadAddress: '',
      category: '한식',
      lat: lat,
      lng: lng,
      reason: '',
      estimatedBudget: 10000,
    );

RouteSegment _seg(String from, String to) => RouteSegment(
      from: from,
      to: to,
      mode: 'driving',
      distance: 1000,
      duration: 5,
    );

TravelRoute _route(List<String> names) => TravelRoute(
      places: names.map(_place).toList(),
      segments: [
        for (var i = 0; i < names.length - 1; i++) _seg(names[i], names[i + 1]),
      ],
      totalBudget: 50000,
      totalDistance: 5000,
      totalDuration: 30,
      comment: 'test',
    );

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

  group('copyWith', () {
    test('지정한 필드만 교체한다', () {
      final original = _route(['A', 'B', 'C']);
      final copy = original.copyWith(comment: '수정됨');
      expect(copy.comment, '수정됨');
      expect(copy.places.length, 3);
      expect(copy.totalBudget, 50000);
    });

    test('생략한 필드는 원본 유지', () {
      final original = _route(['A', 'B']);
      final copy = original.copyWith();
      expect(copy.places, original.places);
      expect(copy.segments, original.segments);
    });
  });

  group('reorderPlaces', () {
    test('A,B,C → B,A,C (0을 1로 이동)', () {
      final r = _route(['A', 'B', 'C']).reorderPlaces(0, 2);
      expect(r.places.map((p) => p.name).toList(), ['B', 'A', 'C']);
    });

    test('A,B,C → A,C,B (1을 3으로 이동, ReorderableListView 컨벤션)', () {
      final r = _route(['A', 'B', 'C']).reorderPlaces(1, 3);
      expect(r.places.map((p) => p.name).toList(), ['A', 'C', 'B']);
    });

    test('역방향 이동: A,B,C → C,A,B (2를 0으로 이동)', () {
      final r = _route(['A', 'B', 'C']).reorderPlaces(2, 0);
      expect(r.places.map((p) => p.name).toList(), ['C', 'A', 'B']);
    });

    test('reorder 후 segments는 비워지고 distance/duration은 0', () {
      final r = _route(['A', 'B', 'C']).reorderPlaces(0, 2);
      expect(r.segments, isEmpty);
      expect(r.totalDistance, 0);
      expect(r.totalDuration, 0);
      expect(r.totalBudget, 50000); // budget은 유지
    });

    test('동일 인덱스면 원본 반환', () {
      final original = _route(['A', 'B']);
      final result = original.reorderPlaces(0, 0);
      expect(identical(result, original), isTrue);
    });

    test('범위 밖 인덱스면 원본 반환', () {
      final original = _route(['A', 'B']);
      expect(identical(original.reorderPlaces(-1, 0), original), isTrue);
      expect(identical(original.reorderPlaces(0, 99), original), isTrue);
    });
  });

  group('removePlace', () {
    test('A,B,C에서 1번 제거 → A,C', () {
      final r = _route(['A', 'B', 'C']).removePlace(1);
      expect(r.places.map((p) => p.name).toList(), ['A', 'C']);
    });

    test('remove 후 segments 비고 distance/duration 0', () {
      final r = _route(['A', 'B', 'C']).removePlace(1);
      expect(r.segments, isEmpty);
      expect(r.totalDistance, 0);
      expect(r.totalDuration, 0);
    });

    test('범위 밖 인덱스는 원본 반환', () {
      final original = _route(['A', 'B']);
      expect(identical(original.removePlace(-1), original), isTrue);
      expect(identical(original.removePlace(99), original), isTrue);
    });
  });
}
