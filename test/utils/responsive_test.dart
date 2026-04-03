// test/utils/responsive_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_route_planner/utils/responsive.dart';

void main() {
  group('isMobile', () {
    testWidgets('화면 너비 599px이면 true', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(599, 800)),
          child: Builder(builder: (context) {
            expect(isMobile(context), isTrue);
            return const SizedBox();
          }),
        ),
      );
    });
    testWidgets('화면 너비 600px이면 false', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(600, 800)),
          child: Builder(builder: (context) {
            expect(isMobile(context), isFalse);
            return const SizedBox();
          }),
        ),
      );
    });
    testWidgets('화면 너비 1024px이면 false', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(1024, 800)),
          child: Builder(builder: (context) {
            expect(isMobile(context), isFalse);
            return const SizedBox();
          }),
        ),
      );
    });
  });
}
