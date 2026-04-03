import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/place.dart';

void main() {
  group('Place.fromJson', () {
    test('정상 JSON을 파싱한다', () {
      final json = {
        'slot': 'breakfast', 'name': '순두부젤라또',
        'address': '강릉시 초당동', 'roadAddress': '강릉시 초당순두부길 15',
        'category': '한식', 'coordinates': {'lat': 37.7912, 'lng': 128.9114},
        'reason': '강릉 명물', 'estimatedBudget': 12000, 'reviewSummary': '맛있어요',
      };
      final place = Place.fromJson(json);
      expect(place.slot, 'breakfast');
      expect(place.name, '순두부젤라또');
      expect(place.lat, 37.7912);
      expect(place.lng, 128.9114);
      expect(place.estimatedBudget, 12000);
      expect(place.reviewSummary, '맛있어요');
    });
    test('좌표가 없으면 0,0으로 기본값 설정', () {
      final place = Place.fromJson({'slot': 'lunch', 'name': '테스트'});
      expect(place.lat, 0);
      expect(place.lng, 0);
    });
  });
  group('Place.slotLabel', () {
    for (final e in [('breakfast', '아침'), ('morning_cafe', '오전 카페'), ('lunch', '점심'), ('afternoon_cafe', '오후 카페'), ('dinner', '저녁')]) {
      test('${e.$1} → ${e.$2}', () {
        expect(Place.fromJson({'slot': e.$1, 'name': 'x'}).slotLabel, e.$2);
      });
    }
  });
  group('Place.isCafe', () {
    test('morning_cafe는 카페', () => expect(Place.fromJson({'slot': 'morning_cafe', 'name': 'x'}).isCafe, isTrue));
    test('afternoon_cafe는 카페', () => expect(Place.fromJson({'slot': 'afternoon_cafe', 'name': 'x'}).isCafe, isTrue));
    test('breakfast는 카페가 아님', () => expect(Place.fromJson({'slot': 'breakfast', 'name': 'x'}).isCafe, isFalse));
  });
}
