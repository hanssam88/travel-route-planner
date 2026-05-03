import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mood_tags.dart';
import '../../providers/mood_filter_provider.dart';
import '../../theme/app_spacing.dart';
import '../common/mood_chip.dart';

class MoodFilterBar extends ConsumerWidget {
  const MoodFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(moodFilterProvider);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: moodTags.length + (selected.isNotEmpty ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (selected.isNotEmpty && i == 0) {
            return Center(
              child: TextButton.icon(
                onPressed: () => ref.read(moodFilterProvider.notifier).clear(),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('전체'),
              ),
            );
          }
          final tag = moodTags[selected.isNotEmpty ? i - 1 : i];
          return Center(
            child: MoodChip(
              label: tag,
              selected: selected.contains(tag),
              onTap: () => ref.read(moodFilterProvider.notifier).toggle(tag),
            ),
          );
        },
      ),
    );
  }
}
