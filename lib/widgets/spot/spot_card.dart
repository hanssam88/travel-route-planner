import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/saved_spot.dart';
import '../../providers/saved_spots_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../common/app_bookmark_button.dart';
import 'mood_tag.dart';
import 'source_badge.dart';
import 'waiting_badge.dart';

class SpotCard extends ConsumerWidget {
  final SavedSpot spot;
  final VoidCallback? onTap;
  final bool showSource;

  const SpotCard({
    super.key,
    required this.spot,
    this.onTap,
    this.showSource = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final saved = ref.watch(savedSpotsProvider).any((s) => s.id == spot.id);

    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Cover(emoji: spot.emoji),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            spot.name,
                            style: tt.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppBookmarkButton(
                          saved: saved,
                          size: 32,
                          onPressed: () {
                            final notifier = ref.read(savedSpotsProvider.notifier);
                            saved ? notifier.remove(spot.id) : notifier.add(spot);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${spot.region} · ${spot.category}',
                          style: tt.bodySmall,
                        ),
                        if (showSource) ...[
                          const SizedBox(width: 8),
                          SourceBadge(source: spot.source, compact: true),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
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
    );
  }
}

class _Cover extends StatelessWidget {
  final String emoji;
  const _Cover({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 84,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sageContainer, AppColors.creamHighest],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 32)),
    );
  }
}
