import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/saved_spot.dart';
import '../../providers/saved_spots_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../spot/mood_tag.dart';
import '../spot/source_badge.dart';
import '../spot/waiting_badge.dart';

/// Vertical optimized-route timeline used by RouteViewScreen.
class RouteTimelineView extends ConsumerWidget {
  final List<String> spotIds;
  final ScrollController? controller;

  const RouteTimelineView({
    super.key,
    required this.spotIds,
    this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 120),
      itemCount: spotIds.length,
      itemBuilder: (context, i) {
        final spot = ref.watch(savedSpotByIdProvider(spotIds[i]));
        if (spot == null) return const SizedBox.shrink();
        return _TimelineRow(
          index: i,
          total: spotIds.length,
          spot: spot,
          showSegment: i > 0,
          railColor: cs.primary,
        );
      },
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final int index;
  final int total;
  final SavedSpot spot;
  final bool showSegment;
  final Color railColor;

  const _TimelineRow({
    required this.index,
    required this.total,
    required this.spot,
    required this.showSegment,
    required this.railColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 36,
            child: Column(
              children: [
                if (showSegment)
                  Expanded(
                    child: Container(width: 2, color: railColor.withValues(alpha: 0.4)),
                  )
                else
                  const SizedBox(height: 8),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: railColor, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(
                    '${index + 1}',
                    style: tt.labelLarge?.copyWith(color: cs.onPrimary),
                  ),
                ),
                if (index < total - 1)
                  Expanded(
                    child: Container(width: 2, color: railColor.withValues(alpha: 0.4)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSegment)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(Icons.directions_car_outlined, size: 14, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '약 ${(8 + (index * 3))}분 · ${(2 + index * 1.4).toStringAsFixed(1)}km',
                            style: tt.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  Material(
                    color: cs.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(AppSpacing.lg),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.creamHigh,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(spot.emoji, style: const TextStyle(fontSize: 28)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(spot.name, style: tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                    SourceBadge(source: spot.source, compact: true),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text('${spot.region} · ${spot.category}', style: tt.bodySmall),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    WaitingBadge(
                                      spotId: spot.id,
                                      fallback: spot.congestion,
                                      fallbackWaiting: spot.waitingMinutes,
                                      compact: true,
                                    ),
                                    ...spot.moodTags.take(2).map((t) => MoodTag(label: t)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
