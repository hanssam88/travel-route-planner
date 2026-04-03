import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/preference.dart';

void main() {
  group('UserPreference.toJson', () {
    test('필수 필드를 JSON으로 변환', () {
      const pref = UserPreference(region: '강릉', foodTypes: ['한식', '일식'], budgetRange: BudgetRange.from10kTo30k, transportMode: TransportMode.driving);
      final json = pref.toJson();
      expect(json['region'], '강릉');
      expect(json['foodTypes'], ['한식', '일식']);
      expect(json['budgetRange'], '10k_30k');
      expect(json.containsKey('date'), isFalse);
    });
    test('선택 필드 포함', () {
      const pref = UserPreference(region: '제주', date: '2026-04-10', foodTypes: ['해산물'], budgetRange: BudgetRange.noLimit, transportMode: TransportMode.transit, additionalRequest: '해변 근처');
      final json = pref.toJson();
      expect(json['date'], '2026-04-10');
      expect(json['additionalRequest'], '해변 근처');
    });
  });
  group('BudgetRange', () {
    test('value와 label', () {
      expect(BudgetRange.under10k.value, 'under_10k');
      expect(BudgetRange.under10k.label, '1만원 이하');
    });
  });
  group('TransportMode', () {
    test('value와 label', () {
      expect(TransportMode.driving.value, 'driving');
      expect(TransportMode.driving.label, '자가용');
    });
  });
}
