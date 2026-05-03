import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/discover_guide.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../spot/mood_tag.dart';

class DiscoverRouteCard extends StatelessWidget {
  final DiscoverGuide guide;
  const DiscoverRouteCard({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return SizedBox(
      width: 240,
      child: Material(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          onTap: () => context.push('/discover/${guide.id}'),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.sageContainer, AppColors.creamHigh],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(guide.coverEmoji, style: const TextStyle(fontSize: 64)),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(guide.title, style: tt.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(guide.authorEmoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        guide.author,
                        style: tt.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 13, color: cs.onSurfaceVariant),
                    const SizedBox(width: 2),
                    Text('${guide.spotCount}곳', style: tt.labelMedium),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_today_outlined, size: 13, color: cs.onSurfaceVariant),
                    const SizedBox(width: 2),
                    Text('${guide.days}일', style: tt.labelMedium),
                    const Spacer(),
                    Icon(Icons.bookmark_rounded, size: 13, color: AppColors.bookmark),
                    const SizedBox(width: 2),
                    Text(_formatSaves(guide.saves), style: tt.labelMedium),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: guide.moodTags.map((t) => MoodTag(label: t)).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatSaves(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}
