import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/travel_route.dart';
import '../services/api_service.dart';
import 'api_provider.dart';
import 'preference_provider.dart';
import 'chat_provider.dart';

class RouteState {
  final TravelRoute? route;
  final bool isLoading;
  final String? error;

  const RouteState({
    this.route,
    this.isLoading = false,
    this.error,
  });

  RouteState copyWith({
    TravelRoute? route,
    bool? isLoading,
    String? error,
  }) =>
      RouteState(
        route: route ?? this.route,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class RouteNotifier extends StateNotifier<RouteState> {
  final ApiService _api;
  final Ref _ref;

  RouteNotifier(this._api, this._ref) : super(const RouteState());

  /// 루트 생성 요청
  Future<void> generateRoute() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final preference = _ref.read(preferenceProvider);
      final chatState = _ref.read(chatProvider);

      // AI 대화에서 수집된 추가 컨텍스트
      final additionalContext = chatState.messages
          .map((m) => '${m.role == MessageRole.user ? "사용자" : "AI"}: ${m.content}')
          .join('\n');

      // 1. 루트 생성
      final generateResult = await _api.generateRoute(
        preference: preference.toPreference(),
        additionalContext: additionalContext.isNotEmpty ? additionalContext : null,
      );

      // 2. 경로 계산
      final places = (generateResult['places'] as List)
          .map((p) {
            final coords = p['coordinates'] as Map<String, dynamic>;
            return <String, dynamic>{
              'slot': p['slot'],
              'coordinates': <String, dynamic>{
                'lat': coords['lat'],
                'lng': coords['lng'],
              },
            };
          })
          .toList();

      final directionsResult = await _api.getDirections(
        places: places,
        mode: preference.transportMode.value,
      );

      // 3. 결과 조합
      final route = TravelRoute.fromGenerateAndDirections(
        generateResult,
        directionsResult,
      );

      state = RouteState(route: route);
    } on ApiException catch (e) {
      state = RouteState(error: e.message);
    } catch (e) {
      state = RouteState(error: '루트 생성 중 오류가 발생했습니다');
    }
  }

  void reset() => state = const RouteState();
}

final routeProvider = StateNotifierProvider<RouteNotifier, RouteState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return RouteNotifier(api, ref);
});
