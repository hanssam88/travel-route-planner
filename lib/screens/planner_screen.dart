import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/preference_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/route_provider.dart';
import '../widgets/chat/preference_chips.dart';
import '../widgets/chat/chat_panel.dart';
import '../widgets/route/route_timeline.dart';

enum PlannerStep { preference, chat, route }

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  PlannerStep _step = PlannerStep.preference;

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
    setState(() => _step = PlannerStep.preference);
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
      return RouteTimeline(route: routeState.route!);
    }

    return const Center(child: Text('루트를 생성해주세요'));
  }
}
