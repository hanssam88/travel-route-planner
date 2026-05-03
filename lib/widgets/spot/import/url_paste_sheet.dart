import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/import_source.dart';
import '../../../providers/import_provider.dart';
import '../../../providers/saved_spots_provider.dart';
import '../../../theme/app_spacing.dart';

class UrlPasteSheet extends ConsumerStatefulWidget {
  final ImportSource source;
  const UrlPasteSheet({super.key, required this.source});

  @override
  ConsumerState<UrlPasteSheet> createState() => _UrlPasteSheetState();
}

class _UrlPasteSheetState extends ConsumerState<UrlPasteSheet> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    setState(() => _busy = true);
    final result = await ref.read(importProvider.notifier).simulate(widget.source, _controller.text);
    ref.read(savedSpotsProvider.notifier).addMany(result.spots);
    if (!mounted) return;
    Navigator.of(context).pop(result.spots.length);
  }

  String _placeholder() => switch (widget.source) {
        ImportSource.instagram => 'https://www.instagram.com/p/...',
        ImportSource.tiktok => 'https://www.tiktok.com/@user/video/...',
        ImportSource.naverBlog => 'https://blog.naver.com/...',
        ImportSource.kakaoMap => 'https://place.map.kakao.com/...',
        _ => '링크를 붙여넣어주세요',
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.source.brandColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(widget.source.icon, color: widget.source.brandColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.source.label, style: tt.titleLarge),
                        Text(widget.source.hint, style: tt.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _controller,
                autofocus: true,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: _placeholder(),
                  prefixIcon: const Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.tips_and_updates_outlined, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'AI가 본문에서 장소·주소·메뉴를 자동 추출해요',
                      style: tt.labelSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _busy ? null : _import,
                  icon: _busy
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download_outlined, size: 18),
                  label: Text(_busy ? '추출 중…' : '스팟 추출하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
