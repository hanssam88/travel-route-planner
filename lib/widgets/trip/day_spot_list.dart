import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/saved_spot.dart';
import '../../providers/saved_spots_provider.dart';
import '../../providers/trips_provider.dart';
import '../../theme/app_spacing.dart';
import '../spot/spot_list_item.dart';
import 'live_cursor_overlay.dart';

class DaySpotList extends ConsumerWidget {
  final String tripId;
  final int dayIndex;
  final List<String> spotIds;
  final bool optimized;
  final Map<String, String> cursorOnSpotId; // collaboratorName -> spotId

  const DaySpotList({
    super.key,
    required this.tripId,
    required this.dayIndex,
    required this.spotIds,
    required this.optimized,
    this.cursorOnSpotId = const {},
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (spotIds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Text(
            '이 Day에는 아직 저장한 스팟이 없어요\n+ 버튼으로 스팟을 추가하세요',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      buildDefaultDragHandles: false,
      itemCount: spotIds.length,
      onReorder: (oldI, newI) {
        ref.read(tripsProvider.notifier).reorderSpots(tripId, dayIndex, oldI, newI);
      },
      itemBuilder: (context, i) {
        final id = spotIds[i];
        final SavedSpot? spot = ref.watch(savedSpotByIdProvider(id));
        if (spot == null) {
          return SizedBox(key: ValueKey('missing_$id'));
        }
        final cursors = cursorOnSpotId.entries.where((e) => e.value == id).map((e) => e.key).toList();
        return Padding(
          key: ValueKey(id),
          padding: const EdgeInsets.only(bottom: 8),
          child: Stack(
            children: [
              SpotListItem(
                spot: spot,
                indexBadge: optimized ? i + 1 : null,
                onTap: () {},
                trailing: ReorderableDragStartListener(
                  index: i,
                  child: const Icon(Icons.drag_handle, size: 18),
                ),
              ),
              if (cursors.isNotEmpty)
                Positioned(
                  right: 8,
                  top: -4,
                  child: LiveCursorOverlay(names: cursors),
                ),
            ],
          ),
        );
      },
    );
  }
}
