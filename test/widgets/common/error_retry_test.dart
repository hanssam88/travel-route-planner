import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/widgets/common/error_retry.dart';

void main() {
  group('ErrorRetry', () {
    testWidgets('에러 메시지와 재시도 버튼을 표시한다', (tester) async {
      var retryPressed = false;
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: ErrorRetry(message: '네트워크 연결을 확인해주세요', onRetry: () => retryPressed = true))),
      );
      expect(find.text('네트워크 연결을 확인해주세요'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      await tester.tap(find.text('다시 시도'));
      expect(retryPressed, isTrue);
    });
    testWidgets('onRetry가 null이면 버튼을 표시하지 않는다', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: ErrorRetry(message: '오류 발생'))));
      expect(find.text('오류 발생'), findsOneWidget);
      expect(find.text('다시 시도'), findsNothing);
    });
  });
}
