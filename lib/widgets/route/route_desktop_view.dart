import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../models/travel_route.dart';
import '../map/route_map.dart';
import 'route_timeline.dart';

class RouteDesktopView extends StatelessWidget {
  final TravelRoute route;
  final int? selectedPlaceIndex;
  final void Function(int index)? onPlaceTap;
  final void Function(int index)? onMarkerTap;
  final ItemScrollController? itemScrollController;

  const RouteDesktopView({
    super.key,
    required this.route,
    this.selectedPlaceIndex,
    this.onPlaceTap,
    this.onMarkerTap,
    this.itemScrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 200),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.4,
            child: RouteMap(
              places: route.places,
              segments: route.segments,
              selectedIndex: selectedPlaceIndex,
              onMarkerTap: onMarkerTap,
            ),
          ),
        ),
        Expanded(
          child: RouteTimeline(
            route: route,
            onPlaceTap: onPlaceTap,
            itemScrollController: itemScrollController,
          ),
        ),
      ],
    );
  }
}
