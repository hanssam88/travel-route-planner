import 'package:flutter/material.dart';
import '../../data/saved_spot.dart';
import '../../theme/app_colors.dart';
import 'mood_tag.dart';
import 'waiting_badge.dart';

class SpotListItem extends StatelessWidget {
  final SavedSpot spot;
  final int? indexBadge;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool highlight;

  const SpotListItem({
    super.key,
    required this.spot,
    this.indexBadge,
    this.onTap,
    this.trailing,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Material(
      color: highlight ? cs.primaryContainer : cs.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              if (indexBadge != null) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$indexBadge',
                    style: tt.labelLarge?.copyWith(color: cs.onPrimary),
                  ),
                ),
                const SizedBox(width: 10),
              ] else ...[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.creamHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(spot.emoji, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(spot.name, style: tt.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${spot.region} · ${spot.category}',
                            style: tt.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (spot.moodTags.isNotEmpty) ...[
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
                          ...spot.moodTags.take(1).map((t) => MoodTag(label: t)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
