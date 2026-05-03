import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/saved_spot.dart';
import '../../providers/congestion_provider.dart';
import 'congestion_dot.dart';

class WaitingBadge extends ConsumerWidget {
  final String spotId;
  final Congestion fallback;
  final int? fallbackWaiting;
  final bool compact;

  const WaitingBadge({
    super.key,
    required this.spotId,
    required this.fallback,
    this.fallbackWaiting,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(liveCongestionProvider(spotId));
    final info = live.maybeWhen(
      data: (d) => d,
      orElse: () => CongestionInfo(
        congestion: fallback,
        waitingMinutes: fallbackWaiting,
      ),
    );

    final c = info.congestion;
    final wait = info.waitingMinutes ?? 0;
    final color = colorForCongestion(c);
    final tt = Theme.of(context).textTheme;
    final label = wait > 0 ? '${c.label}·$wait분' : c.label;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CongestionDot(congestion: c, size: compact ? 6 : 7),
          const SizedBox(width: 5),
          Text(
            label,
            style: (compact ? tt.labelSmall : tt.labelMedium)?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
