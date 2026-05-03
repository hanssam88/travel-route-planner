import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/collaborators_provider.dart';
import '../providers/saved_spots_provider.dart';
import '../providers/trips_provider.dart';
import '../theme/app_spacing.dart';
import '../widgets/trip/collaborator_stack.dart';
import '../widgets/trip/day_spot_list.dart';
import '../widgets/trip/day_tab_bar.dart';
import '../widgets/trip/optimize_cta.dart';
import '../widgets/trip/share_sheet.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final String tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  int _activeDay = 0;

  Future<void> _addSpotToCurrentDay() async {
    final spots = ref.read(savedSpotsProvider);
    final tt = Theme.of(context).textTheme;
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        builder: (ctx, scroll) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('스팟 선택', style: tt.titleLarge),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    controller: scroll,
                    itemCount: spots.length,
                    itemBuilder: (_, i) {
                      final s = spots[i];
                      return ListTile(
                        leading: Text(s.emoji, style: const TextStyle(fontSize: 24)),
                        title: Text(s.name),
                        subtitle: Text('${s.region} · ${s.category}'),
                        onTap: () => Navigator.of(ctx).pop(s.id),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (picked != null) {
      ref.read(tripsProvider.notifier).addSpotToDay(widget.tripId, _activeDay, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripByIdProvider(widget.tripId));
    final live = ref.watch(liveCollaboratorsProvider(widget.tripId));
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (trip == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Trip을 찾을 수 없어요')));
    }

    final collaborators = live.maybeWhen(data: (d) => d, orElse: () => trip.collaborators);
    final cursorMap = <String, String>{};
    for (final c in collaborators) {
      if (c.cursorSpotId != null && c.id != 'c1') {
        cursorMap[c.name] = c.cursorSpotId!;
      }
    }
    final activeDay = trip.days[_activeDay];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/trips'),
        ),
        title: Row(
          children: [
            Text(trip.coverEmoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(trip.title, style: tt.titleLarge, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => ShareSheet.show(context, trip.id, trip.title),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, 6),
            child: Row(
              children: [
                CollaboratorStack(collaborators: collaborators, showLiveLabel: true),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_outlined, size: 13, color: cs.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(trip.region, style: tt.labelMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
          DayTabBar(
            days: trip.days,
            activeIndex: _activeDay,
            onChanged: (i) => setState(() => _activeDay = i),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DaySpotList(
                    tripId: trip.id,
                    dayIndex: _activeDay,
                    spotIds: activeDay.spotIds,
                    optimized: activeDay.optimized,
                    cursorOnSpotId: cursorMap,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.lg),
                    child: OutlinedButton.icon(
                      onPressed: _addSpotToCurrentDay,
                      icon: const Icon(Icons.add),
                      label: Text('${activeDay.label}에 스팟 추가'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          OptimizeCta(
            tripId: trip.id,
            isOptimized: activeDay.optimized,
            spotCount: activeDay.spotIds.length,
          ),
        ],
      ),
    );
  }
}
