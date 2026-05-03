import 'package:flutter/material.dart';
import '../../data/saved_spot.dart';
import '../../theme/app_colors.dart';

Color colorForCongestion(Congestion c) => switch (c) {
      Congestion.low => AppColors.congestionLow,
      Congestion.mid => AppColors.congestionMid,
      Congestion.high => AppColors.congestionHigh,
    };

class CongestionDot extends StatelessWidget {
  final Congestion congestion;
  final double size;

  const CongestionDot({super.key, required this.congestion, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorForCongestion(congestion),
        shape: BoxShape.circle,
      ),
    );
  }
}
