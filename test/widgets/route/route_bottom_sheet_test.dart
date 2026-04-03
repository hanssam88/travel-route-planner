import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/models/travel_route.dart';
import 'package:travel_route_planner/models/place.dart';
import 'package:travel_route_planner/models/route_segment.dart';
import 'package:travel_route_planner/widgets/route/route_bottom_sheet.dart';

TravelRoute _createTestRoute() => TravelRoute(
      places: [
        Place.fromJson({'slot': 'breakfast', 'name': '순두부젤라또', 'coordinates': {'lat': 37.79, 'lng': 128.91}, 'reason': '강릉 명물', 'estimatedBudget': 12000}),
        Place.fromJson({'slot': 'morning_cafe', 'name': '테라로사', 'coordinates': {'lat': 37.78, 'lng': 128.90}, 'reason': '커피 맛집', 'estimatedBudget': 8000}),
      ],
      segments: [RouteSegment.fromJson({'from': '순두부젤라또', 'to': '테라로사', 'mode': 'driving', 'distance': 3200, 'duration': 10})],
      totalBudget: 20000, totalDistance: 3200, totalDuration: 10, comment: '강릉 맛집 투어',
    );

TravelRoute _createEmptyRoute() => const TravelRoute(places: [], segments: [], totalBudget: 0, totalDistance: 0, totalDuration: 0, comment: '빈 루트');

TravelRoute _createSinglePlaceRoute() => TravelRoute(
      places: [Place.fromJson({'slot': 'lunch', 'name': '교동반점', 'coordinates': {'lat': 37.77, 'lng': 128.89}, 'reason': '강릉 짬뽕', 'estimatedBudget': 15000})],
      segments: const [], totalBudget: 15000, totalDistance: 0, totalDuration: 0, comment: '점심 한 곳',
    );

void main() {
  group('RouteBottomSheet', () {
    testWidgets('요약 헤더를 표시한다', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Stack(children: [RouteBottomSheet(route: _createTestRoute())]))));
      expect(find.text('강릉 맛집 투어'), findsOneWidget);
    });
    testWidgets('onPlaceTap 콜백을 전달한다', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: SizedBox(height: 800, child: Stack(children: [RouteBottomSheet(route: _createTestRoute(), onPlaceTap: (i) => tappedIndex = i)])))));
      expect(tappedIndex, isNull);
    });
    testWidgets('빈 루트일 때 크래시하지 않는다', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Stack(children: [RouteBottomSheet(route: _createEmptyRoute())]))));
      expect(find.text('빈 루트'), findsOneWidget);
    });
    testWidgets('장소 1개 + 세그먼트 0개일 때 정상 표시', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Stack(children: [RouteBottomSheet(route: _createSinglePlaceRoute())]))));
      expect(find.text('점심 한 곳'), findsOneWidget);
    });
  });
}
