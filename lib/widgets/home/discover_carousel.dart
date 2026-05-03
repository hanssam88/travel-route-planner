import 'package:flutter/material.dart';
import '../../data/mock_discover.dart';
import '../../theme/app_spacing.dart';
import 'discover_route_card.dart';

class DiscoverCarousel extends StatelessWidget {
  const DiscoverCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 310,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: mockDiscoverGuides.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) => DiscoverRouteCard(guide: mockDiscoverGuides[i]),
      ),
    );
  }
}
