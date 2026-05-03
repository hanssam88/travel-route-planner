import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/saved_spots_provider.dart';
import '../providers/trips_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spotCount = ref.watch(savedSpotsProvider).length;
    final tripCount = ref.watch(tripsProvider).length;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('프로필', style: tt.headlineMedium)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.sageContainer, AppColors.creamHigh],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.lg),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text('🙂', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('나의 여행', style: tt.headlineSmall),
                      const SizedBox(height: 2),
                      Text('roamy@example.com', style: tt.bodySmall),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _Stat(emoji: '📍', label: '저장 스팟', value: '$spotCount')),
              const SizedBox(width: 8),
              Expanded(child: _Stat(emoji: '🧳', label: 'Trip', value: '$tripCount')),
              const SizedBox(width: 8),
              Expanded(child: _Stat(emoji: '🏞', label: '방문 지역', value: '4')),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ..._sections(cs, tt),
        ],
      ),
    );
  }

  List<Widget> _sections(ColorScheme cs, TextTheme tt) {
    final items = <(IconData, String, String?)>[
      (Icons.bookmark_outline, '저장한 가이드', '커뮤니티에서 담은 코스'),
      (Icons.history, '방문 기록', '실제 다녀온 장소'),
      (Icons.tune, '취향 설정', '추천 알고리즘 조정'),
      (Icons.help_outline, '도움말', null),
    ];
    return items
        .map((it) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: Icon(it.$1),
                title: Text(it.$2, style: tt.titleSmall),
                subtitle: it.$3 != null ? Text(it.$3!, style: tt.bodySmall) : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ))
        .toList();
  }
}

class _Stat extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  const _Stat({required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value, style: tt.titleLarge),
          Text(label, style: tt.labelSmall),
        ],
      ),
    );
  }
}
