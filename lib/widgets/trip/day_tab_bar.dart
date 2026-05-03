import 'package:flutter/material.dart';
import '../../data/trip.dart';
import '../../theme/app_colors.dart';

class DayTabBar extends StatelessWidget {
  final List<TripDay> days;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const DayTabBar({
    super.key,
    required this.days,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return SizedBox(
      height: 56,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = i == activeIndex;
          final d = days[i];
          return Center(
            child: Material(
              color: selected ? cs.primary : cs.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: selected ? cs.primary : cs.outlineVariant),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onChanged(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        d.label,
                        style: tt.labelLarge?.copyWith(
                          color: selected ? cs.onPrimary : cs.onSurface,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.25)
                              : AppColors.creamHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${d.spotIds.length}',
                          style: tt.labelSmall?.copyWith(
                            color: selected ? Colors.white : cs.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
