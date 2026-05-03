import 'package:flutter/material.dart';
import '../../../data/import_source.dart';
import '../../../theme/app_spacing.dart';

class ImportSourceGrid extends StatelessWidget {
  final ValueChanged<ImportSource> onSelect;
  const ImportSourceGrid({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final sources = ImportSource.values;
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: sources.length,
      itemBuilder: (_, i) => _SourceTile(source: sources[i], onTap: () => onSelect(sources[i])),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final ImportSource source;
  final VoidCallback onTap;
  const _SourceTile({required this.source, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final brand = source.brandColor;
    return Material(
      color: cs.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: brand.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(source.icon, color: brand, size: 22),
              ),
              const SizedBox(height: 8),
              Text(source.label, style: tt.titleMedium),
              const SizedBox(height: 4),
              Text(source.hint, style: tt.bodySmall, maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }
}
