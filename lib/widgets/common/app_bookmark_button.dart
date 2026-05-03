import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppBookmarkButton extends StatelessWidget {
  final bool saved;
  final VoidCallback onPressed;
  final double size;

  const AppBookmarkButton({
    super.key,
    required this.saved,
    required this.onPressed,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: saved
          ? AppColors.bookmark.withValues(alpha: 0.18)
          : cs.surfaceContainer,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            saved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            color: saved ? AppColors.bookmark : cs.onSurfaceVariant,
            size: size * 0.55,
          ),
        ),
      ),
    );
  }
}
