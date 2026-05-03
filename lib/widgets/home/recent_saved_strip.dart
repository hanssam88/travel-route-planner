import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/saved_spots_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class RecentSavedStrip extends ConsumerWidget {
  const RecentSavedStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spots = ref.watch(savedSpotsProvider).take(8).toList();
    final tt = Theme.of(context).textTheme;
    if (spots.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: spots.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final s = spots[i];
          return SizedBox(
            width: 84,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.md),
              onTap: () => context.push('/spot/${s.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 70,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.sageContainer, AppColors.creamHigh],
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                    ),
                    alignment: Alignment.center,
                    child: Text(s.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(height: 6),
                  Text(s.name, style: tt.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
