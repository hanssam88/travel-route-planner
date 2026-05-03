import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MoodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool dense;

  const MoodChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Material(
      color: selected ? cs.primary : cs.surfaceContainerLowest,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? cs.primary : cs.outlineVariant,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dense ? 10 : 14,
            vertical: dense ? 6 : 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.check : Icons.tag,
                size: dense ? 12 : 14,
                color: selected ? cs.onPrimary : AppColors.inkSoft,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: (dense ? tt.labelMedium : tt.labelLarge)?.copyWith(
                  color: selected ? cs.onPrimary : cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
