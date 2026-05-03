import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sageContainer, AppColors.creamHigh],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Text('✈️', style: TextStyle(fontSize: 80, color: cs.onPrimaryContainer.withValues(alpha: 0.15))),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.terracotta, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('NEW · Mood + 실시간 협업', style: tt.labelSmall),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('어디로 떠나볼까요?', style: tt.displaySmall),
              const SizedBox(height: 6),
              Text(
                'SNS·블로그에서 모은 장소를 한 번에 묶고\n자동으로 최적 루트를 만들어드려요.',
                style: tt.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push('/spot/add'),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('스팟 저장하기'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/trip/new'),
                    icon: const Icon(Icons.luggage_outlined, size: 18),
                    label: const Text('Trip 만들기'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
