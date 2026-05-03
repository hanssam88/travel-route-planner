import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/trips_provider.dart';
import '../../theme/app_spacing.dart';

class OptimizeCta extends ConsumerStatefulWidget {
  final String tripId;
  final bool isOptimized;
  final int spotCount;

  const OptimizeCta({
    super.key,
    required this.tripId,
    required this.isOptimized,
    required this.spotCount,
  });

  @override
  ConsumerState<OptimizeCta> createState() => _OptimizeCtaState();
}

class _OptimizeCtaState extends ConsumerState<OptimizeCta> {
  bool _loading = false;

  Future<void> _run() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    ref.read(tripsProvider.notifier).markOptimized(widget.tripId);
    setState(() => _loading = false);
    if (!mounted) return;
    context.push('/trip/${widget.tripId}/route');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final disabled = widget.spotCount == 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          onPressed: disabled || _loading ? null : _run,
          icon: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(widget.isOptimized ? Icons.bolt : Icons.auto_awesome, size: 20),
          label: Text(
            _loading
                ? '루트 최적화 중…'
                : disabled
                    ? '스팟을 추가해주세요'
                    : widget.isOptimized
                        ? '최적 루트 다시 보기'
                        : '한 번에 루트 최적화',
            style: tt.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
