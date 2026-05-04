import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/route_segment.dart';

void main() {
  RouteSegment seg({
    String mode = 'driving',
    int distance = 1000,
    int duration = 10,
    List<dynamic>? path,
  }) =>
      RouteSegment.fromJson({
        'from': 'a',
        'to': 'b',
        'mode': mode,
        'distance': distance,
        'duration': duration,
        'path': ?path,
      });

  group('RouteSegment.fromJson', () {
    test('정상 JSON을 파싱한다', () {
      final s = RouteSegment.fromJson({
        'from': '순두부젤라또',
        'to': '테라로사',
        'mode': 'driving',
        'distance': 3200,
        'duration': 10,
      });
      expect(s.from, '순두부젤라또');
      expect(s.distance, 3200);
      expect(s.path, isNull);
      expect(s.hasPath, isFalse);
    });

    test('path 필드가 있으면 List<List<double>>로 파싱한다', () {
      final s = seg(path: [
        [128.91, 37.79],
        [128.905, 37.785],
        [128.90, 37.78],
      ]);
      expect(s.hasPath, isTrue);
      expect(s.path, hasLength(3));
      expect(s.path![0], [128.91, 37.79]);
      expect(s.path![2], [128.90, 37.78]);
    });

    test('path가 빈 배열이면 hasPath는 false', () {
      final s = seg(path: []);
      expect(s.hasPath, isFalse);
    });

    test('int 좌표도 double로 파싱한다', () {
      final s = seg(path: [
        [128, 37],
      ]);
      expect(s.path![0][0], 128.0);
      expect(s.path![0][1], 37.0);
    });
  });

  group('toJson', () {
    test('path가 없으면 path 키를 생략한다', () {
      final json = seg().toJson();
      expect(json.containsKey('path'), isFalse);
      expect(json['from'], 'a');
      expect(json['mode'], 'driving');
    });

    test('path가 있으면 그대로 직렬화한다', () {
      final json = seg(path: [
        [128.91, 37.79],
      ]).toJson();
      expect(json['path'], [
        [128.91, 37.79],
      ]);
    });

    test('fromJson → toJson round-trip이 동등하다', () {
      final original = {
        'from': 'A',
        'to': 'B',
        'mode': 'transit',
        'distance': 5000,
        'duration': 25,
        'path': [
          [127.0, 37.5],
          [127.1, 37.6],
        ],
      };
      final s = RouteSegment.fromJson(original);
      expect(s.toJson(), original);
    });
  });

  group('pathLatLngs', () {
    test('path가 없으면 빈 리스트', () {
      expect(seg().pathLatLngs, isEmpty);
    });

    test('[lng, lat] → LatLng(lat, lng)로 스왑한다', () {
      final s = seg(path: [
        [128.91, 37.79],
        [128.90, 37.78],
      ]);
      final ll = s.pathLatLngs;
      expect(ll, hasLength(2));
      expect(ll[0].latitude, 37.79);
      expect(ll[0].longitude, 128.91);
      expect(ll[1].latitude, 37.78);
      expect(ll[1].longitude, 128.90);
    });

  });

  group('fromJson 좌표 검증 (W1)', () {
    test('좌표 길이가 부족하면 FormatException', () {
      expect(
        () => seg(path: [
          [128.91, 37.79],
          [128.90],
        ]),
        throwsA(isA<FormatException>()),
      );
    });

    test('NaN 좌표는 FormatException', () {
      expect(
        () => seg(path: [
          [double.nan, 37.79],
        ]),
        throwsA(isA<FormatException>()),
      );
    });

    test('범위 밖 좌표는 FormatException', () {
      expect(
        () => seg(path: [
          [200.0, 37.79], // lng > 180
        ]),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => seg(path: [
          [128.0, 91.0], // lat > 90
        ]),
        throwsA(isA<FormatException>()),
      );
    });

    test('path가 5000점 초과면 FormatException', () {
      final tooLong = List.generate(
        5001,
        (_) => <double>[128.0, 37.0],
      );
      expect(
        () => seg(path: tooLong),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('distanceLabel', () {
    test('1000m 이상이면 km', () => expect(seg(distance: 3200).distanceLabel, '3.2km'));
    test('1000m 미만이면 m', () => expect(seg(distance: 500).distanceLabel, '500m'));
  });

  group('durationLabel', () {
    test('60분 이상 시간+분', () => expect(seg(duration: 90).durationLabel, '1시간 30분'));
    test('정확히 60분', () => expect(seg(duration: 60).durationLabel, '1시간'));
    test('60분 미만', () => expect(seg(duration: 45).durationLabel, '45분'));
  });

  group('modeLabel', () {
    test('driving → 자동차', () => expect(seg(mode: 'driving').modeLabel, '자동차'));
    test('transit → 대중교통', () => expect(seg(mode: 'transit').modeLabel, '대중교통'));
    test('walking → 도보', () => expect(seg(mode: 'walking').modeLabel, '도보'));
  });
}
