import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/region_emojis.dart';
import '../providers/trips_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/constants.dart';

class TripCreateScreen extends ConsumerStatefulWidget {
  const TripCreateScreen({super.key});

  @override
  ConsumerState<TripCreateScreen> createState() => _TripCreateScreenState();
}

class _TripCreateScreenState extends ConsumerState<TripCreateScreen> {
  final _titleController = TextEditingController();
  String? _region;
  int _days = 2;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _titleController.text.trim().isNotEmpty && _region != null;

  void _create() {
    final id = ref.read(tripsProvider.notifier).create(
          title: _titleController.text.trim(),
          region: _region!,
          coverEmoji: emojiForRegion(_region!),
          days: _days,
        );
    context.go('/trip/$id');
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('새 Trip', style: tt.titleLarge)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('어디로 떠나요?', style: tt.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.95,
            ),
            itemCount: popularRegions.length,
            itemBuilder: (_, i) {
              final r = popularRegions[i];
              final selected = r == _region;
              return Material(
                color: selected ? cs.primaryContainer : cs.surfaceContainerLowest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  side: BorderSide(
                    color: selected ? cs.primary : cs.outlineVariant,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.md),
                  onTap: () => setState(() => _region = r),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emojiForRegion(r), style: const TextStyle(fontSize: 26)),
                        const SizedBox(height: 4),
                        Text(r, style: tt.labelLarge),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Trip 이름', style: tt.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: '예: 강릉 1박 2일 카페투어',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('며칠 일정인가요?', style: tt.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final d in [1, 2, 3, 4, 5])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(d == 1 ? '당일' : '${d - 1}박 $d일'),
                    selected: _days == d,
                    onSelected: (_) => setState(() => _days = d),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.sageContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '저장한 스팟을 day별로 묶고 "최적화" 버튼을 누르면 동선을 자동 정렬해드려요',
                    style: tt.labelMedium,
                  ),
                ),
              ],
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
              onPressed: _canSubmit ? _create : null,
              icon: const Icon(Icons.add),
              label: const Text('Trip 만들기'),
            ),
          ),
        ),
      ),
    );
  }
}
