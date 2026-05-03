import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/mock_discover.dart';
import '../data/region_emojis.dart';
import '../providers/trips_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/spot/mood_tag.dart';

class DiscoverDetailScreen extends ConsumerWidget {
  final String guideId;
  const DiscoverDetailScreen({super.key, required this.guideId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guide = mockDiscoverGuides.firstWhere((g) => g.id == guideId, orElse: () => mockDiscoverGuides.first);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: cs.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.sageContainer, AppColors.creamHigh]),
                ),
                alignment: Alignment.center,
                child: Text(guide.coverEmoji, style: const TextStyle(fontSize: 100)),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('커뮤니티 가이드', style: tt.labelSmall?.copyWith(color: cs.onPrimaryContainer)),
                ),
                const SizedBox(height: 12),
                Text(guide.title, style: tt.headlineLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(guide.authorEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(guide.author, style: tt.titleSmall),
                    const Spacer(),
                    Icon(Icons.bookmark_rounded, size: 14, color: AppColors.bookmark),
                    const SizedBox(width: 4),
                    Text('${guide.saves}', style: tt.labelMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    _Stat(icon: Icons.calendar_today_outlined, label: '${guide.days}일'),
                    const SizedBox(width: 8),
                    _Stat(icon: Icons.place_outlined, label: '${guide.spotCount}곳'),
                    const SizedBox(width: 8),
                    _Stat(icon: Icons.location_on_outlined, label: guide.region),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: guide.moodTags.map((t) => MoodTag(label: t)).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('이 가이드에 담긴 스팟', style: tt.titleLarge),
                const SizedBox(height: 8),
                ..._mockGuideSpots(guide.spotCount).map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.creamHigh,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(s['emoji']!, style: const TextStyle(fontSize: 22)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s['name']!, style: tt.titleSmall),
                                  Text(s['note']!, style: tt.bodySmall),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    )),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
                final id = ref.read(tripsProvider.notifier).create(
                      title: guide.title,
                      region: guide.region,
                      coverEmoji: emojiForRegion(guide.region),
                      days: guide.days,
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('내 Trip으로 복제했어요')),
                );
                context.go('/trip/$id');
              },
              icon: const Icon(Icons.copy_all_outlined),
              label: const Text('내 Trip으로 복제하기'),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _mockGuideSpots(int n) {
    const samples = [
      {'emoji': '☕', 'name': '테라로사 커피공장', 'note': '대표 시그니처 라떼'},
      {'emoji': '🍦', 'name': '순두부 젤라또', 'note': '강릉 명물, 줄 서서 먹는 곳'},
      {'emoji': '🌅', 'name': '안목해변', 'note': '카페거리 + 일출 명소'},
      {'emoji': '🍜', 'name': '교동반점', 'note': '강릉 짬뽕 원조'},
      {'emoji': '🐟', 'name': '주문진수산시장', 'note': '회 + 대게'},
      {'emoji': '🌳', 'name': '경포호수', 'note': '산책 코스'},
      {'emoji': '🍻', 'name': '버드나무브루어리', 'note': '수제맥주'},
      {'emoji': '🏔️', 'name': '대관령 양떼목장', 'note': '인생샷 명소'},
      {'emoji': '🎨', 'name': '하슬라아트월드', 'note': '미술관 + 카페'},
      {'emoji': '🌊', 'name': '정동심곡 바다부채길', 'note': '해안절벽 트레킹'},
    ];
    return samples.take(n).toList();
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(label, style: tt.labelMedium),
        ],
      ),
    );
  }
}
