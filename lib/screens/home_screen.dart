import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/trips_provider.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/section_header.dart';
import '../widgets/home/discover_carousel.dart';
import '../widgets/home/hero_section.dart';
import '../widgets/home/ongoing_trip_card.dart';
import '../widgets/home/recent_saved_strip.dart';
import '../widgets/home/region_pill_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);
    final tt = Theme.of(context).textTheme;
    final ongoing = trips.isNotEmpty ? trips.first : null;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        title: Row(
          children: [
            Text(
              'Roamy',
              style: tt.headlineMedium,
            ),
            const SizedBox(width: 6),
            Text('🌿', style: tt.headlineSmall),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/spot/add'),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          const HeroSection(),
          if (ongoing != null) ...[
            const SectionHeader(title: '진행 중인 Trip'),
            OngoingTripCard(trip: ongoing),
            const SizedBox(height: AppSpacing.lg),
          ],
          const SectionHeader(
            title: '인기 지역',
            subtitle: '국내 여행자들이 가장 많이 저장한 곳',
          ),
          const RegionStrip(),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            title: '커뮤니티 가이드',
            subtitle: '한 번 누르면 내 Trip으로 복제',
            actionLabel: '전체',
            onAction: () {},
          ),
          const DiscoverCarousel(),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(
            title: '최근 저장한 스팟',
            actionLabel: '모두 보기',
            onAction: () => context.go('/saved'),
          ),
          const RecentSavedStrip(),
          const SizedBox(height: AppSpacing.lg),
          const _FooterCard(),
        ],
      ),
    );
  }
}

class _FooterCard extends StatelessWidget {
  const _FooterCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('⚡', style: tt.headlineMedium),
            const SizedBox(width: 8),
            Expanded(
              child: Text('스팟만 모으면 끝', style: tt.titleLarge),
            ),
          ]),
          const SizedBox(height: 8),
          Text(
            'SNS·블로그·카카오맵에서 모은 장소를 한 번에 묶고\n대기시간·날씨·동선을 고려해 자동으로 최적화해드려요.',
            style: tt.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
