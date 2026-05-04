import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../models/travel_route.dart';
import '../providers/preference_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/route_provider.dart';
import '../utils/responsive.dart';
import '../widgets/chat/preference_chips.dart';
import '../widgets/chat/chat_panel.dart';
import '../widgets/common/error_retry.dart';
import '../widgets/map/route_map.dart';
import '../widgets/route/editable_route_timeline.dart';
import '../widgets/route/route_bottom_sheet.dart';
import '../widgets/route/route_desktop_view.dart';
import '../widgets/route/route_loading.dart';

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

  void _onPlaceTapFromList(int index) {
    setState(() => _selectedPlaceIndex = index);
  }

  void _onMarkerTapFromMap(int index) {
    setState(() => _selectedPlaceIndex = index);
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
          if (_step == PlannerStep.route && routeState.route != null)
            IconButton(
              icon: Icon(routeState.isEditing ? Icons.check : Icons.edit),
              tooltip: routeState.isEditing ? '편집 완료' : '편집',
              onPressed: () =>
                  ref.read(routeProvider.notifier).toggleEditMode(),
            ),
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
      return const RouteLoading();
    }

    if (routeState.error != null && routeState.route == null) {
      return ErrorRetry(
        message: routeState.error!,
        onRetry: () => ref.read(routeProvider.notifier).generateRoute(),
      );
    }

    if (routeState.route == null) {
      return const Center(child: Text('루트를 생성해주세요'));
    }

    final route = routeState.route!;

    if (routeState.isEditing) {
      return EditableRouteTimeline(places: route.places);
    }

    if (isMobile(context)) {
      return _buildMobileRouteView(route);
    }
    return _buildDesktopRouteView(route);
  }

  Widget _buildMobileRouteView(TravelRoute route) {
    return Stack(
      children: [
        Positioned.fill(
          child: RouteMap(
            places: route.places,
            segments: route.segments,
            selectedIndex: _selectedPlaceIndex,
            onMarkerTap: (index) {
              setState(() => _selectedPlaceIndex = index);
            },
          ),
        ),
        RouteBottomSheet(
          route: route,
          onPlaceTap: _onPlaceTapFromList,
          selectedPlaceIndex: _selectedPlaceIndex,
        ),
      ],
    );
  }

  Widget _buildDesktopRouteView(TravelRoute route) {
    return RouteDesktopView(
      route: route,
      selectedPlaceIndex: _selectedPlaceIndex,
      onPlaceTap: _onPlaceTapFromList,
      onMarkerTap: _onMarkerTapFromMap,
      itemScrollController: _itemScrollController,
    );
  }
}
