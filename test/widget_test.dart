import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_route_planner/app.dart';

void main() {
  testWidgets('앱이 정상적으로 시작되고 홈 화면을 보여준다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TravelRouteApp()),
    );
    await tester.pump();

    expect(find.text('Roamy'), findsOneWidget);
    expect(find.text('어디로 떠나볼까요?'), findsOneWidget);
  });
}
