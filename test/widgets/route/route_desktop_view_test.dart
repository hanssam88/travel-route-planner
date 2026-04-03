import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/travel_route.dart';
import 'package:travel_route_planner/models/place.dart';
import 'package:travel_route_planner/models/route_segment.dart';
import 'package:travel_route_planner/widgets/route/route_desktop_view.dart';

void main() {
  final testRoute = TravelRoute(
    places: [
      Place.fromJson({'slot': 'breakfast', 'name': '순두부젤라또', 'coordinates': {'lat': 37.79, 'lng': 128.91}, 'reason': '강릉 명물', 'estimatedBudget': 12000}),
      Place.fromJson({'slot': 'morning_cafe', 'name': '테라로사', 'coordinates': {'lat': 37.78, 'lng': 128.90}, 'reason': '커피 맛집', 'estimatedBudget': 8000}),
    ],
    segments: [RouteSegment.fromJson({'from': '순두부젤라또', 'to': '테라로사', 'mode': 'driving', 'distance': 3200, 'duration': 10})],
    totalBudget: 20000, totalDistance: 3200, totalDuration: 10, comment: '강릉 맛집 투어',
  );

  group('RouteDesktopView', () {
    testWidgets('요약 헤더와 장소 카드를 표시한다', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: RouteDesktopView(route: testRoute))));
      // RouteTimeline의 요약 헤더
      expect(find.text('강릉 맛집 투어'), findsOneWidget);
    });

    testWidgets('onPlaceTap 콜백을 전달한다', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: RouteDesktopView(route: testRoute, onPlaceTap: (i) => tappedIndex = i))));
      await tester.tap(find.text('순두부젤라또'));
      expect(tappedIndex, 0);
    });
  });
}
