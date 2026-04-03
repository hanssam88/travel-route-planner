import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/widgets/route/route_loading.dart';

void main() {
  group('RouteLoading', () {
    testWidgets('로딩 인디케이터와 메시지를 표시한다', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: RouteLoading())));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('맛집을 검색하고 있어요...'), findsOneWidget);
    });
    testWidgets('시간이 지나면 단계 텍스트가 변경된다', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: RouteLoading())));
      expect(find.text('맛집을 검색하고 있어요...'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('리뷰를 분석하고 있어요...'), findsOneWidget);
    });
    testWidgets('진행률 바가 표시된다', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: RouteLoading())));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
