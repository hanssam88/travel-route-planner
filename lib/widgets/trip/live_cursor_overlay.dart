import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class LiveCursorOverlay extends StatelessWidget {
  final List<String> names;
  const LiveCursorOverlay({super.key, required this.names});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.terracotta,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit, size: 11, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            '${names.first}님 보는 중',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
