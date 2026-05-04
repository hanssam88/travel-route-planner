import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/route_segment.dart';
import '../models/travel_route.dart';
import '../services/api_service.dart';
import 'api_provider.dart';
import 'preference_provider.dart';
import 'chat_provider.dart';

class _Sentinel {
  const _Sentinel();
}

const _kErrorSentinel = _Sentinel();

class RouteState {
  final TravelRoute? route;
  final bool isLoading;
  final bool isEditing;
  final bool isRecalculating;
  final String? error;

  const RouteState({
    this.route,
    this.isLoading = false,
    this.isEditing = false,
    this.isRecalculating = false,
    this.error,
  });

  /// error는 sentinel 패턴 — 명시적으로 null 또는 String 전달 시에만 변경,
  /// 생략하면 기존 값 유지 (실수로 다른 액션이 직전 에러를 silent clear하지 않도록).
  RouteState copyWith({
    TravelRoute? route,
    bool? isLoading,
    bool? isEditing,
    bool? isRecalculating,
    Object? error = _kErrorSentinel,
  }) =>
      RouteState(
        route: route ?? this.route,
        isLoading: isLoading ?? this.isLoading,
        isEditing: isEditing ?? this.isEditing,
        isRecalculating: isRecalculating ?? this.isRecalculating,
        error: identical(error, _kErrorSentinel) ? this.error : error as String?,
      );
}

/// 디바운스 간격 — 편집 후 재계산까지 대기 시간.
/// 테스트에서 짧은 값으로 override 가능.
const Duration kRecalcDebounce = Duration(seconds: 1);

/// 클라이언트 토큰버킷 — 백엔드 /api/directions 30/min 한도 대비 5 여유.
const int kDirectionsClientRateLimit = 25;
const Duration kDirectionsRateWindow = Duration(minutes: 1);

class RouteNotifier extends StateNotifier<RouteState> {
  final ApiService _api;
  final Ref _ref;
  Timer? _recalcTimer;
  final Duration _debounce;

  /// generation token — 빠른 연속 편집 시 stale write 방지.
  int _recalcGen = 0;

  /// 최근 호출 타임스탬프 (sliding window)
  final List<DateTime> _recentCalls = <DateTime>[];

  RouteNotifier(
    this._api,
    this._ref, {
    Duration debounce = kRecalcDebounce,
  })  : _debounce = debounce,
        super(const RouteState());

  /// 루트 생성 요청
  Future<void> generateRoute() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final preference = _ref.read(preferenceProvider);
      final chatState = _ref.read(chatProvider);

      final additionalContext = chatState.messages
          .map((m) => '${m.role == MessageRole.user ? "사용자" : "AI"}: ${m.content}')
          .join('\n');

      final generateResult = await _api.generateRoute(
        preference: preference.toPreference(),
        additionalContext: additionalContext.isNotEmpty ? additionalContext : null,
      );

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

      final route = TravelRoute.fromGenerateAndDirections(
        generateResult,
        directionsResult,
      );

      state = RouteState(route: route);
    } on ApiException catch (e) {
      state = RouteState(error: e.message);
    } on NetworkException catch (e) {
      state = RouteState(error: e.message);
    } catch (e) {
      state = RouteState(error: '알 수 없는 오류가 발생했습니다');
    }
  }

  /// 편집 모드 토글.
  void toggleEditMode() {
    state = state.copyWith(isEditing: !state.isEditing);
  }

  /// 장소 순서 변경 후 디바운스 재계산.
  void reorderPlaces(int oldIndex, int newIndex) {
    final route = state.route;
    if (route == null) return;
    final next = route.reorderPlaces(oldIndex, newIndex);
    if (identical(next, route)) return;
    state = state.copyWith(route: next);
    _scheduleRecalc();
  }

  /// 장소 삭제 후 디바운스 재계산.
  void removePlace(int index) {
    final route = state.route;
    if (route == null) return;
    if (route.places.length <= 2) {
      state = state.copyWith(error: '장소가 너무 적어 삭제할 수 없습니다 (최소 2개)');
      return;
    }
    final next = route.removePlace(index);
    state = state.copyWith(route: next, error: null);
    _scheduleRecalc();
  }

  void _scheduleRecalc() {
    _recalcTimer?.cancel();
    final gen = ++_recalcGen;
    _recalcTimer = Timer(_debounce, () => _recalculateDirections(gen));
  }

  bool _canCallDirections() {
    final now = DateTime.now();
    _recentCalls.removeWhere(
      (t) => now.difference(t) > kDirectionsRateWindow,
    );
    return _recentCalls.length < kDirectionsClientRateLimit;
  }

  Future<void> _recalculateDirections(int gen) async {
    if (gen != _recalcGen) return; // stale
    final route = state.route;
    if (route == null || route.places.length < 2) return;

    if (!_canCallDirections()) {
      state = state.copyWith(
        isRecalculating: false,
        error: '편집이 너무 잦습니다. 잠시 후 다시 시도해주세요',
      );
      return;
    }
    _recentCalls.add(DateTime.now());

    state = state.copyWith(isRecalculating: true, error: null);

    try {
      final preference = _ref.read(preferenceProvider);
      final placesPayload = route.places
          .map((p) => <String, dynamic>{
                'slot': p.slot,
                'coordinates': {'lat': p.lat, 'lng': p.lng},
              })
          .toList();

      final directionsResult = await _api.getDirections(
        places: placesPayload,
        mode: preference.transportMode.value,
      );

      // late check — 응답 도착 전 사용자가 다시 편집했으면 결과 폐기.
      if (gen != _recalcGen) {
        state = state.copyWith(isRecalculating: false);
        return;
      }

      final segments = (directionsResult['segments'] as List)
          .map((s) => RouteSegment.fromJson(s as Map<String, dynamic>))
          .toList();

      // 최신 state의 places 위에 segments만 덮음 (이론상 gen check로 동등하지만 방어적).
      final currentRoute = state.route ?? route;
      state = state.copyWith(
        route: currentRoute.copyWith(
          segments: segments,
          totalDistance: (directionsResult['totalDistance'] as num).toInt(),
          totalDuration: (directionsResult['totalDuration'] as num).toInt(),
        ),
        isRecalculating: false,
      );
    } on ApiException catch (e) {
      if (gen != _recalcGen) return;
      state = state.copyWith(isRecalculating: false, error: e.message);
    } on NetworkException catch (e) {
      if (gen != _recalcGen) return;
      state = state.copyWith(isRecalculating: false, error: e.message);
    } catch (_) {
      if (gen != _recalcGen) return;
      state = state.copyWith(
        isRecalculating: false,
        error: '경로 재계산에 실패했습니다',
      );
    }
  }

  void reset() {
    _recalcTimer?.cancel();
    _recalcGen++; // 진행 중 응답 모두 폐기
    _recentCalls.clear();
    state = const RouteState();
  }

  @override
  void dispose() {
    _recalcTimer?.cancel();
    super.dispose();
  }
}

final routeProvider = StateNotifierProvider<RouteNotifier, RouteState>((ref) {
  final api = ref.watch(apiServiceProvider);
  return RouteNotifier(api, ref);
});
