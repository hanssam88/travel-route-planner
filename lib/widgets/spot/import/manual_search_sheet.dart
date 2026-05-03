import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/import_source.dart';
import '../../../providers/import_provider.dart';
import '../../../providers/saved_spots_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';

class ManualSearchSheet extends ConsumerStatefulWidget {
  const ManualSearchSheet({super.key});

  @override
  ConsumerState<ManualSearchSheet> createState() => _ManualSearchSheetState();
}

class _ManualSearchSheetState extends ConsumerState<ManualSearchSheet> {
  final _controller = TextEditingController();
  bool _busy = false;

  static const _suggestions = [
    {'emoji': '☕', 'name': '카페 모모스', 'region': '부산'},
    {'emoji': '🍜', 'name': '교동반점', 'region': '강릉'},
    {'emoji': '🦪', 'name': '연포해녀의집', 'region': '제주'},
    {'emoji': '🏯', 'name': '경주 황리단길', 'region': '경주'},
  ];

  Future<void> _addAndClose(String name) async {
    setState(() => _busy = true);
    final result = await ref.read(importProvider.notifier).simulate(ImportSource.manual, name);
    ref.read(savedSpotsProvider.notifier).addMany(result.spots);
    if (!mounted) return;
    Navigator.of(context).pop(result.spots.length);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
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
              Text('직접 검색·핀', style: tt.titleLarge),
              const SizedBox(height: 4),
              Text('이름이나 주소로 장소를 찾아 추가해요', style: tt.bodySmall),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '예: 강릉 테라로사',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('인기 검색어', style: tt.labelMedium),
              const SizedBox(height: 8),
              ..._suggestions.map((s) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.creamHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(s['emoji']!, style: const TextStyle(fontSize: 20)),
                    ),
                    title: Text(s['name']!, style: tt.titleSmall),
                    subtitle: Text(s['region']!, style: tt.bodySmall),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _busy ? null : () => _addAndClose(s['name']!),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
