import 'package:flutter/material.dart';
import '../../models/travel_route.dart';
import '../../models/route_segment.dart';
import 'route_card.dart';

class RouteTimeline extends StatelessWidget {
  final TravelRoute route;
  final void Function(int index)? onPlaceTap;

  const RouteTimeline({
    super.key,
    required this.route,
    this.onPlaceTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // 요약 헤더
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: colorScheme.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                route.comment,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _SummaryChip(
                    icon: Icons.attach_money,
                    label: '총 ${_formatBudget(route.totalBudget)}',
                  ),
                  const SizedBox(width: 12),
                  _SummaryChip(
                    icon: Icons.schedule,
                    label: '이동 ${_formatDuration(route.totalDuration)}',
                  ),
                  const SizedBox(width: 12),
                  _SummaryChip(
                    icon: Icons.straighten,
                    label: _formatDistance(route.totalDistance),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 장소 + 구간 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: route.places.length + route.segments.length,
            itemBuilder: (context, index) {
              // 짝수: 장소, 홀수: 구간
              if (index.isEven) {
                final placeIndex = index ~/ 2;
                return RouteCard(
                  place: route.places[placeIndex],
                  index: placeIndex,
                  onTap: onPlaceTap != null
                      ? () => onPlaceTap!(placeIndex)
                      : null,
                );
              } else {
                final segIndex = index ~/ 2;
                if (segIndex < route.segments.length) {
                  return _SegmentDivider(segment: route.segments[segIndex]);
                }
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ],
    );
  }

  String _formatBudget(int budget) {
    if (budget >= 10000) return '${budget ~/ 10000}만원';
    return '$budget원';
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}시간 ${m}분' : '${h}시간';
    }
    return '$minutes분';
  }

  String _formatDistance(int meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)}km';
    return '${meters}m';
  }
}

class _SegmentDivider extends StatelessWidget {
  final RouteSegment segment;
  const _SegmentDivider({required this.segment});

  @override
  Widget build(BuildContext context) {
    final icon = switch (segment.mode) {
      'driving' => Icons.directions_car,
      'transit' => Icons.directions_bus,
      'walking' => Icons.directions_walk,
      _ => Icons.arrow_downward,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '${segment.durationLabel} · ${segment.distanceLabel}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Expanded(
            child: Divider(indent: 8),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SummaryChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Theme.of(context).colorScheme.onPrimaryContainer),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}
