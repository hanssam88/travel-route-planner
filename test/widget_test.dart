import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_route_planner/app.dart';

void main() {
  testWidgets('앱이 정상적으로 시작되고 홈 화면을 보여준다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TravelRouteApp()),
    );

    expect(find.text('여행 루트 플래너'), findsOneWidget);
    expect(find.text('루트 추천 시작'), findsOneWidget);
  });

  testWidgets('시작 버튼을 누르면 플래너 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TravelRouteApp()),
    );

    await tester.tap(find.text('루트 추천 시작'));
    await tester.pumpAndSettle();

    expect(find.text('취향 선택'), findsOneWidget);
    expect(find.text('어디로 여행 가시나요?'), findsOneWidget);
  });
}
