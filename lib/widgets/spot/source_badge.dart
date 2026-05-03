import 'package:flutter/material.dart';
import '../../data/import_source.dart';

class SourceBadge extends StatelessWidget {
  final ImportSource source;
  final bool compact;

  const SourceBadge({super.key, required this.source, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final brand = source.brandColor;
    final isLight = brand.computeLuminance() > 0.6;
    final fg = isLight ? Colors.black87 : Colors.white;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: brand,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(source.icon, size: compact ? 10 : 12, color: fg),
          const SizedBox(width: 3),
          Text(
            source.badgeLabel,
            style: TextStyle(
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
