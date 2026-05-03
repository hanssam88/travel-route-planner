import 'package:flutter/material.dart';
import '../data/import_source.dart';
import '../theme/app_spacing.dart';
import '../widgets/spot/import/gallery_import_sheet.dart';
import '../widgets/spot/import/import_source_grid.dart';
import '../widgets/spot/import/manual_search_sheet.dart';
import '../widgets/spot/import/url_paste_sheet.dart';

class SpotAddScreen extends StatelessWidget {
  const SpotAddScreen({super.key});

  Future<void> _handle(BuildContext context, ImportSource source) async {
    Widget sheet = switch (source) {
      ImportSource.gallery => const GalleryImportSheet(),
      ImportSource.manual => const ManualSearchSheet(),
      _ => UrlPasteSheet(source: source),
    };
    final added = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => sheet,
    );
    if (added != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('스팟 $added개를 저장했어요'),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('스팟 추가', style: tt.titleLarge),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('어디에서 가져올까요?', style: tt.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'SNS·블로그·갤러리에서 한 번에 모아드려요. 한국 사용자를 위해 네이버·카카오도 지원해요.',
                  style: tt.bodyMedium,
                ),
              ],
            ),
          ),
          ImportSourceGrid(onSelect: (s) => _handle(context, s)),
        ],
      ),
    );
  }
}
