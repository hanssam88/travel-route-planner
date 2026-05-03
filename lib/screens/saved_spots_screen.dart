import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/saved_spot.dart';
import '../providers/mood_filter_provider.dart';
import '../providers/saved_spots_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/spot/mood_filter_bar.dart';
import '../widgets/spot/spot_card.dart';

enum _ViewMode { list, map }

class SavedSpotsScreen extends ConsumerStatefulWidget {
  final String? initialRegion;
  const SavedSpotsScreen({super.key, this.initialRegion});

  @override
  ConsumerState<SavedSpotsScreen> createState() => _SavedSpotsScreenState();
}

class _SavedSpotsScreenState extends ConsumerState<SavedSpotsScreen> {
  _ViewMode _mode = _ViewMode.list;
  String? _regionFilter;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _regionFilter = widget.initialRegion;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SavedSpot> _filtered(List<SavedSpot> all, Set<String> moodTags) {
    return all.where((s) {
      if (_regionFilter != null && s.region != _regionFilter) return false;
      if (moodTags.isNotEmpty && !moodTags.any(s.moodTags.contains)) return false;
      if (_query.isNotEmpty &&
          !s.name.contains(_query) &&
          !s.region.contains(_query) &&
          !s.category.contains(_query)) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(savedSpotsProvider);
    final moods = ref.watch(moodFilterProvider);
    final list = _filtered(all, moods);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Spots', style: tt.headlineMedium),
        actions: [
          if (_regionFilter != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_regionFilter!, style: tt.labelMedium),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => setState(() => _regionFilter = null),
                        child: const Icon(Icons.close, size: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 4, AppSpacing.lg, AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: '저장한 장소 검색',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _ModeToggle(
                  mode: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                ),
              ],
            ),
          ),
          const MoodFilterBar(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
            child: Row(
              children: [
                Text('${list.length}개', style: tt.labelLarge),
                const Spacer(),
                Icon(Icons.sort, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('최근 저장순', style: tt.labelMedium),
              ],
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? EmptyState(
                    icon: Icons.bookmark_border,
                    title: '저장된 스팟이 없어요',
                    message: '필터 조건을 바꿔보거나, 새 스팟을 추가해보세요',
                  )
                : _mode == _ViewMode.list
                    ? _List(spots: list)
                    : _MapMock(spots: list),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final _ViewMode mode;
  final ValueChanged<_ViewMode> onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget btn(IconData icon, _ViewMode m) {
      final selected = mode == m;
      return Material(
        color: selected ? cs.primary : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => onChanged(m),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 18, color: selected ? cs.onPrimary : cs.onSurfaceVariant),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.view_list, _ViewMode.list),
          btn(Icons.map_outlined, _ViewMode.map),
        ],
      ),
    );
  }
}

class _List extends StatelessWidget {
  final List<SavedSpot> spots;
  const _List({required this.spots});

  @override
  Widget build(BuildContext context) {
    final wide = !isMobile(context);
    if (wide) {
      return GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 460,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3.2,
        ),
        itemCount: spots.length,
        itemBuilder: (_, i) => SpotCard(spot: spots[i]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 4, AppSpacing.lg, 100),
      itemCount: spots.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => SpotCard(spot: spots[i]),
    );
  }
}

class _MapMock extends StatelessWidget {
  final List<SavedSpot> spots;
  const _MapMock({required this.spots});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.lg, 4, AppSpacing.lg, 100),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sageContainer, AppColors.creamHigh],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Stack(
        children: [
          // Mock pins
          for (int i = 0; i < spots.length; i++)
            Positioned(
              left: 30 + (i * 47) % 240,
              top: 60 + (i * 73) % 320,
              child: _MapPin(spot: spots[i]),
            ),
          Positioned(
            left: 16,
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app_outlined, size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '핀을 탭해 스팟을 확인하세요 · 실제 카카오맵으로 연결됩니다',
                      style: tt.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final SavedSpot spot;
  const _MapPin({required this.spot});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Text(spot.emoji, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
