import 'package:flutter/material.dart';
import '../../models/travel_route.dart';
import '../../models/route_segment.dart';
import 'route_card.dart';

const double _estimatedItemHeight = 100.0;

class RouteBottomSheet extends StatefulWidget {
  final TravelRoute route;
  final void Function(int index)? onPlaceTap;
  final int? selectedPlaceIndex;

  const RouteBottomSheet({super.key, required this.route, this.onPlaceTap, this.selectedPlaceIndex});

  @override
  State<RouteBottomSheet> createState() => _RouteBottomSheetState();
}

class _RouteBottomSheetState extends State<RouteBottomSheet> {
  final _sheetController = DraggableScrollableController();
  ScrollController? _scrollController;

  @override
  void didUpdateWidget(covariant RouteBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPlaceIndex != oldWidget.selectedPlaceIndex && widget.selectedPlaceIndex != null) {
      _scrollToPlace(widget.selectedPlaceIndex!);
    }
  }

  void _scrollToPlace(int placeIndex) {
    if (_sheetController.isAttached && _sheetController.size < 0.5) {
      _sheetController.animateTo(0.55, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    final offset = placeIndex * _estimatedItemHeight;
    if (_scrollController != null && _scrollController!.hasClients) {
      _scrollController!.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.18,
      minChildSize: 0.18,
      maxChildSize: 0.85,
      snap: true,
      snapSizes: const [0.18, 0.55, 0.85],
      builder: (context, scrollController) {
        _scrollController = scrollController;
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, -4))],
          ),
          child: ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.zero,
            itemCount: 1 + widget.route.places.length + widget.route.segments.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _buildHeader(context);
              final contentCount = widget.route.places.length + widget.route.segments.length;
              if (index == contentCount + 1) return const SizedBox(height: 32);
              final contentIndex = index - 1;
              if (contentIndex.isEven) {
                final placeIndex = contentIndex ~/ 2;
                return RouteCard(
                  place: widget.route.places[placeIndex],
                  index: placeIndex,
                  onTap: widget.onPlaceTap != null ? () => widget.onPlaceTap!(placeIndex) : null,
                );
              } else {
                final segIndex = contentIndex ~/ 2;
                if (segIndex < widget.route.segments.length) {
                  return _SegmentDivider(segment: widget.route.segments[segIndex]);
                }
                return const SizedBox.shrink();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Container(width: 36, height: 4, decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.route.comment, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                _Chip(icon: Icons.attach_money, label: '총 ${_formatBudget(widget.route.totalBudget)}'),
                _Chip(icon: Icons.schedule, label: '이동 ${_formatDuration(widget.route.totalDuration)}'),
                _Chip(icon: Icons.straighten, label: _formatDistance(widget.route.totalDistance)),
              ]),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
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

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: colorScheme.onPrimaryContainer),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onPrimaryContainer)),
      ]),
    );
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
      child: Row(children: [
        const SizedBox(width: 16),
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text('${segment.durationLabel} · ${segment.distanceLabel}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const Expanded(child: Divider(indent: 8)),
      ]),
    );
  }
}
