import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/route_segment.dart';

void main() {
  RouteSegment _seg({String mode = 'driving', int distance = 1000, int duration = 10}) =>
      RouteSegment.fromJson({'from': 'a', 'to': 'b', 'mode': mode, 'distance': distance, 'duration': duration});

  group('RouteSegment.fromJson', () {
    test('정상 JSON을 파싱한다', () {
      final seg = RouteSegment.fromJson({'from': '순두부젤라또', 'to': '테라로사', 'mode': 'driving', 'distance': 3200, 'duration': 10});
      expect(seg.from, '순두부젤라또');
      expect(seg.distance, 3200);
    });
  });
  group('distanceLabel', () {
    test('1000m 이상이면 km', () => expect(_seg(distance: 3200).distanceLabel, '3.2km'));
    test('1000m 미만이면 m', () => expect(_seg(distance: 500).distanceLabel, '500m'));
  });
  group('durationLabel', () {
    test('60분 이상 시간+분', () => expect(_seg(duration: 90).durationLabel, '1시간 30분'));
    test('정확히 60분', () => expect(_seg(duration: 60).durationLabel, '1시간'));
    test('60분 미만', () => expect(_seg(duration: 45).durationLabel, '45분'));
  });
  group('modeLabel', () {
    test('driving → 자동차', () => expect(_seg(mode: 'driving').modeLabel, '자동차'));
    test('transit → 대중교통', () => expect(_seg(mode: 'transit').modeLabel, '대중교통'));
    test('walking → 도보', () => expect(_seg(mode: 'walking').modeLabel, '도보'));
  });
}
