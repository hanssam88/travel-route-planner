import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:travel_route_planner/models/place.dart';
import 'package:travel_route_planner/models/route_segment.dart';
import 'package:travel_route_planner/models/travel_route.dart';
import 'package:travel_route_planner/providers/api_provider.dart';
import 'package:travel_route_planner/providers/route_provider.dart';
import 'package:travel_route_planner/services/api_service.dart';

Place _place(String name) => Place(
      slot: 'lunch',
      name: name,
      address: '',
      roadAddress: '',
      category: '한식',
      lat: 37,
      lng: 127,
      reason: '',
      estimatedBudget: 10000,
    );

TravelRoute _route(List<String> names) => TravelRoute(
      places: names.map(_place).toList(),
      segments: [
        for (var i = 0; i < names.length - 1; i++)
          RouteSegment(
            from: names[i],
            to: names[i + 1],
            mode: 'driving',
            distance: 1000,
            duration: 5,
          ),
      ],
      totalBudget: 50000,
      totalDistance: 5000,
      totalDuration: 30,
      comment: 'test',
    );

ProviderContainer _makeContainer({required ApiService api}) {
  return ProviderContainer(
    overrides: [
      apiServiceProvider.overrideWithValue(api),
    ],
  );
}

void main() {
  group('RouteState.copyWith error sentinel (C2)', () {
    test('error 인자 생략 시 기존 error 유지', () {
      const initial = RouteState(error: '직전 오류');
      final updated = initial.copyWith(isLoading: true);
      expect(updated.error, '직전 오류'); // sentinel — silent clear 안 함
      expect(updated.isLoading, isTrue);
    });

    test('error: null 명시하면 클리어', () {
      const initial = RouteState(error: '직전 오류');
      final updated = initial.copyWith(error: null);
      expect(updated.error, isNull);
    });

    test('error: 새 메시지 명시하면 교체', () {
      const initial = RouteState(error: '직전 오류');
      final updated = initial.copyWith(error: '새 오류');
      expect(updated.error, '새 오류');
    });
  });

  group('toggleEditMode', () {
    test('isEditing이 토글된다', () {
      final api = ApiService(client: MockClient((_) async => http.Response('', 200)));
      final c = _makeContainer(api: api);
      addTearDown(c.dispose);

      expect(c.read(routeProvider).isEditing, isFalse);
      c.read(routeProvider.notifier).toggleEditMode();
      expect(c.read(routeProvider).isEditing, isTrue);
      c.read(routeProvider.notifier).toggleEditMode();
      expect(c.read(routeProvider).isEditing, isFalse);
    });
  });

  group('reorderPlaces', () {
    test('route가 null이면 무시', () {
      final api = ApiService(client: MockClient((_) async => http.Response('', 200)));
      final c = _makeContainer(api: api);
      addTearDown(c.dispose);

      c.read(routeProvider.notifier).reorderPlaces(0, 1);
      expect(c.read(routeProvider).route, isNull);
    });

    test('places 순서가 변경되고 segments는 비워진다', () {
      final api = ApiService(client: MockClient((_) async => http.Response('', 200)));
      final c = _makeContainer(api: api);
      addTearDown(c.dispose);

      // route 강제 주입을 위한 helper — 실제로는 generateRoute로 채워지지만 단위 테스트 간소화
      final notifier = c.read(routeProvider.notifier);
      notifier.state = RouteState(route: _route(['A', 'B', 'C']));

      notifier.reorderPlaces(0, 2);

      final after = c.read(routeProvider).route!;
      expect(after.places.map((p) => p.name).toList(), ['B', 'A', 'C']);
      expect(after.segments, isEmpty);
    });
  });

  group('removePlace', () {
    test('places 2개 이하면 에러 메시지를 set하고 변경 안 함', () {
      final api = ApiService(client: MockClient((_) async => http.Response('', 200)));
      final c = _makeContainer(api: api);
      addTearDown(c.dispose);

      final notifier = c.read(routeProvider.notifier);
      notifier.state = RouteState(route: _route(['A', 'B']));

      notifier.removePlace(0);

      final state = c.read(routeProvider);
      expect(state.error, contains('너무 적어'));
      expect(state.route!.places.length, 2);
    });

    test('places 3개 이상이면 정상 삭제', () {
      final api = ApiService(client: MockClient((_) async => http.Response('', 200)));
      final c = _makeContainer(api: api);
      addTearDown(c.dispose);

      final notifier = c.read(routeProvider.notifier);
      notifier.state = RouteState(route: _route(['A', 'B', 'C']));

      notifier.removePlace(1);

      final state = c.read(routeProvider);
      expect(state.error, isNull);
      expect(state.route!.places.map((p) => p.name).toList(), ['A', 'C']);
    });
  });

  group('디바운스 재계산', () {
    test('reorderPlaces 후 디바운스 시간 경과 시 /api/directions 호출', () async {
      var directionsCalled = 0;
      final api = ApiService(
        client: MockClient((req) async {
          if (req.url.path == '/api/directions') {
            directionsCalled++;
            return http.Response(
              jsonEncode({
                'segments': [
                  {'from': 'B', 'to': 'A', 'mode': 'driving', 'distance': 1500, 'duration': 8},
                  {'from': 'A', 'to': 'C', 'mode': 'driving', 'distance': 2000, 'duration': 10},
                ],
                'totalDistance': 3500,
                'totalDuration': 18,
              }),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }
          return http.Response('{}', 200, headers: {'content-type': 'application/json; charset=utf-8'});
        }),
      );

      final c = ProviderContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(api),
          routeProvider.overrideWith((ref) => RouteNotifier(
                api,
                ref,
                debounce: const Duration(milliseconds: 50),
              )),
        ],
      );
      addTearDown(c.dispose);

      final notifier = c.read(routeProvider.notifier);
      notifier.state = RouteState(route: _route(['A', 'B', 'C']));

      notifier.reorderPlaces(0, 2);
      expect(c.read(routeProvider).route!.segments, isEmpty);

      // 디바운스 대기
      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(directionsCalled, 1);
      expect(c.read(routeProvider).route!.segments.length, 2);
      expect(c.read(routeProvider).route!.totalDistance, 3500);
      expect(c.read(routeProvider).isRecalculating, isFalse);
    });
  });
}
