import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/preference.dart';
import 'package:travel_route_planner/providers/preference_provider.dart';

void main() {
  late PreferenceNotifier notifier;

  setUp(() => notifier = PreferenceNotifier());

  group('PreferenceNotifier', () {
    test('초기 상태가 올바르다', () {
      expect(notifier.state.region, '');
      expect(notifier.state.foodTypes, isEmpty);
      expect(notifier.state.budgetRange, BudgetRange.from10kTo30k);
      expect(notifier.state.transportMode, TransportMode.driving);
      expect(notifier.state.isComplete, isFalse);
      expect(notifier.state.canSubmit, isFalse);
    });
    test('setRegion으로 지역 설정', () {
      notifier.setRegion('강릉');
      expect(notifier.state.region, '강릉');
    });
    test('toggleFoodType으로 음식 추가/제거', () {
      notifier.toggleFoodType('한식');
      expect(notifier.state.foodTypes, ['한식']);
      notifier.toggleFoodType('일식');
      expect(notifier.state.foodTypes, ['한식', '일식']);
      notifier.toggleFoodType('한식');
      expect(notifier.state.foodTypes, ['일식']);
    });
    test('canSubmit: 지역+음식 둘 다 있어야 true', () {
      expect(notifier.state.canSubmit, isFalse);
      notifier.setRegion('강릉');
      expect(notifier.state.canSubmit, isFalse);
      notifier.toggleFoodType('한식');
      expect(notifier.state.canSubmit, isTrue);
    });
    test('markComplete로 완료 상태 전환', () {
      notifier.markComplete();
      expect(notifier.state.isComplete, isTrue);
    });
    test('reset으로 초기 상태 복원', () {
      notifier.setRegion('제주');
      notifier.toggleFoodType('해산물');
      notifier.markComplete();
      notifier.reset();
      expect(notifier.state.region, '');
      expect(notifier.state.foodTypes, isEmpty);
      expect(notifier.state.isComplete, isFalse);
    });
  });
}
