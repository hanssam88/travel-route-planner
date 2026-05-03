import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/saved_spots_provider.dart';
import '../providers/trips_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/common/app_bookmark_button.dart';
import '../widgets/spot/mood_tag.dart';
import '../widgets/spot/source_badge.dart';
import '../widgets/spot/waiting_badge.dart';

class SpotDetailScreen extends ConsumerWidget {
  final String spotId;
  const SpotDetailScreen({super.key, required this.spotId});

  Future<void> _addToTrip(BuildContext context, WidgetRef ref) async {
    final trips = ref.read(tripsProvider);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    if (trips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip을 먼저 만들어주세요')),
      );
      return;
    }
    final picked = await showModalBottomSheet<(String, int)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Trip에 담기', style: tt.titleLarge),
              const SizedBox(height: 12),
              ...trips.expand((t) => [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Row(
                        children: [
                          Text(t.coverEmoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(t.title, style: tt.titleSmall),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: List.generate(t.days.length, (di) {
                        return ActionChip(
                          backgroundColor: cs.surfaceContainer,
                          side: BorderSide(color: cs.outlineVariant),
                          label: Text('${t.days[di].label} (${t.days[di].spotIds.length}곳)'),
                          onPressed: () => Navigator.of(context).pop((t.id, di)),
                        );
                      }),
                    ),
                  ]),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (picked != null) {
      ref.read(tripsProvider.notifier).addSpotToDay(picked.$1, picked.$2, spotId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('스팟을 Trip에 담았어요')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spot = ref.watch(savedSpotByIdProvider(spotId));
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (spot == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('해당 스팟을 찾을 수 없어요')),
      );
    }

    final saved = ref.watch(savedSpotsProvider).any((s) => s.id == spot.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: cs.surface,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: AppBookmarkButton(
                  saved: saved,
                  onPressed: () {
                    final n = ref.read(savedSpotsProvider.notifier);
                    saved ? n.remove(spot.id) : n.add(spot);
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.sageContainer, AppColors.creamHigh],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(spot.emoji, style: const TextStyle(fontSize: 90)),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(child: Text(spot.name, style: tt.headlineMedium)),
                    SourceBadge(source: spot.source),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${spot.region} · ${spot.category}', style: tt.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                WaitingBadge(
                  spotId: spot.id,
                  fallback: spot.congestion,
                  fallbackWaiting: spot.waitingMinutes,
                ),
                const SizedBox(height: AppSpacing.md),
                if (spot.moodTags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: spot.moodTags.map((t) => MoodTag(label: t)).toList(),
                  ),
                const SizedBox(height: AppSpacing.lg),
                _InfoRow(icon: Icons.location_on_outlined, label: '좌표', value: '${spot.lat.toStringAsFixed(4)}, ${spot.lng.toStringAsFixed(4)}'),
                if (spot.estimatedBudget != null)
                  _InfoRow(icon: Icons.payments_outlined, label: '예상 1인 비용', value: '${spot.estimatedBudget}원'),
                _InfoRow(icon: Icons.label_outline, label: '카테고리', value: spot.category),
                if (spot.note != null)
                  _InfoRow(icon: Icons.description_outlined, label: '메모', value: spot.note!),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SizedBox(
            height: 50,
            child: FilledButton.icon(
              onPressed: () => _addToTrip(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Trip에 담기'),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: Text(label, style: tt.labelMedium),
          ),
          Expanded(child: Text(value, style: tt.bodyMedium)),
        ],
      ),
    );
  }
}
