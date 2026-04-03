import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../providers/preference_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/route_provider.dart';
import '../widgets/chat/preference_chips.dart';
import '../widgets/chat/chat_panel.dart';
import '../widgets/route/route_timeline.dart';
import '../widgets/map/route_map.dart';

enum PlannerStep { preference, chat, route }

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  PlannerStep _step = PlannerStep.preference;
  int? _selectedPlaceIndex;
  final _itemScrollController = ItemScrollController();

  void _onPreferenceComplete() {
    ref.read(preferenceProvider.notifier).markComplete();
    ref.read(chatProvider.notifier).startChat();
    setState(() => _step = PlannerStep.chat);
  }

  void _onRouteRequested() {
    ref.read(routeProvider.notifier).generateRoute();
    setState(() => _step = PlannerStep.route);
  }

  void _onReset() {
    ref.read(preferenceProvider.notifier).reset();
    ref.read(chatProvider.notifier).reset();
    ref.read(routeProvider.notifier).reset();
    setState(() {
      _step = PlannerStep.preference;
      _selectedPlaceIndex = null;
    });
  }

  /// 하단 리스트에서 장소 카드 탭 → 지도가 해당 마커로 이동
  void _onPlaceTapFromList(int index) {
    setState(() => _selectedPlaceIndex = index);
  }

  /// 지도에서 마커 탭 → 하단 리스트가 해당 카드로 스크롤
  void _onMarkerTapFromMap(int index) {
    setState(() => _selectedPlaceIndex = index);
    // placeIndex → 리스트 아이템 index (짝수 = 장소)
    final listIndex = index * 2;
    _itemScrollController.scrollTo(
      index: listIndex,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(routeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(switch (_step) {
          PlannerStep.preference => '취향 선택',
          PlannerStep.chat => 'AI와 대화',
          PlannerStep.route => '추천 루트',
        }),
        actions: [
          if (_step != PlannerStep.preference)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: '처음부터 다시',
              onPressed: _onReset,
            ),
        ],
      ),
      body: switch (_step) {
        PlannerStep.preference => PreferenceChips(
            onComplete: _onPreferenceComplete,
          ),
        PlannerStep.chat => ChatPanel(
            onRouteRequested: _onRouteRequested,
          ),
        PlannerStep.route => _buildRouteView(routeState),
      },
    );
  }

  Widget _buildRouteView(RouteState routeState) {
    if (routeState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI가 최적의 루트를 생성하고 있습니다...'),
            SizedBox(height: 8),
            Text(
              '맛집 검색 + 리뷰 분석 + 경로 최적화',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (routeState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(routeState.error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  ref.read(routeProvider.notifier).generateRoute(),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (routeState.route != null) {
      return Column(
        children: [
          // 상단: 카카오 맵 (40%, 최소 200px)
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 200),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: RouteMap(
                places: routeState.route!.places,
                selectedIndex: _selectedPlaceIndex,
                onMarkerTap: _onMarkerTapFromMap,
              ),
            ),
          ),
          // 하단: 루트 타임라인 (60%)
          Expanded(
            child: RouteTimeline(
              route: routeState.route!,
              onPlaceTap: _onPlaceTapFromList,
              itemScrollController: _itemScrollController,
            ),
          ),
        ],
      );
    }

    return const Center(child: Text('루트를 생성해주세요'));
  }
}
