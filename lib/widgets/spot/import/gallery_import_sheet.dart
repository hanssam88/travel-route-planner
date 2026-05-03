import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/import_source.dart';
import '../../../providers/import_provider.dart';
import '../../../providers/saved_spots_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

class GalleryImportSheet extends ConsumerStatefulWidget {
  const GalleryImportSheet({super.key});

  @override
  ConsumerState<GalleryImportSheet> createState() => _GalleryImportSheetState();
}

class _GalleryImportSheetState extends ConsumerState<GalleryImportSheet> {
  final Set<int> _selected = {};
  bool _busy = false;

  static const _photos = [
    {'emoji': '🏖️', 'place': '협재해수욕장', 'gps': '33.39°N, 126.24°E'},
    {'emoji': '🌅', 'place': '성산일출봉', 'gps': '33.45°N, 126.93°E'},
    {'emoji': '🌳', 'place': '비자림', 'gps': '33.50°N, 126.81°E'},
    {'emoji': '🥢', 'place': '도두해녀의집', 'gps': '33.50°N, 126.47°E'},
    {'emoji': '☕', 'place': '오설록', 'gps': '33.30°N, 126.28°E'},
    {'emoji': '🏔️', 'place': '한라산', 'gps': '33.36°N, 126.52°E'},
  ];

  Future<void> _import() async {
    setState(() => _busy = true);
    final result = await ref.read(importProvider.notifier).simulate(ImportSource.gallery, '');
    ref.read(savedSpotsProvider.notifier).addMany(result.spots);
    if (!mounted) return;
    Navigator.of(context).pop(result.spots.length);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('갤러리에서 자동 추출', style: tt.titleLarge),
            const SizedBox(height: 4),
            Text('사진의 GPS 정보로 방문한 장소를 찾았어요', style: tt.bodySmall),
            const SizedBox(height: AppSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _photos.length,
              itemBuilder: (_, i) {
                final p = _photos[i];
                final selected = _selected.contains(i);
                return Material(
                  color: AppColors.creamHigh,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() {
                      selected ? _selected.remove(i) : _selected.add(i);
                    }),
                    child: Stack(
                      children: [
                        Center(child: Text(p['emoji']!, style: const TextStyle(fontSize: 36))),
                        Positioned(
                          left: 4,
                          right: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              p['place']!,
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (selected)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(color: AppColors.terracotta, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: const Icon(Icons.check, color: Colors.white, size: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _busy ? null : _import,
                child: Text(_busy ? '추출 중…' : '${_selected.isEmpty ? "추천" : _selected.length}개 추가하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
