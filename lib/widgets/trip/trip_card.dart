import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/trip.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'collaborator_stack.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  const TripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Material(
      color: cs.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        onTap: () => context.push('/trip/${trip.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 96,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.sageContainer, AppColors.creamHigh],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  children: [
                    Center(child: Text(trip.coverEmoji, style: const TextStyle(fontSize: 56))),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(trip.region, style: tt.labelSmall),
                      ),
                    ),
                    if (trip.isOptimized && trip.totalSpots > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt, size: 12, color: Colors.white),
                              Text('최적화', style: tt.labelSmall?.copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(trip.title, style: tt.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 13, color: cs.onSurfaceVariant),
                  const SizedBox(width: 2),
                  Text('${trip.days.length}일', style: tt.labelMedium),
                  const SizedBox(width: 8),
                  Icon(Icons.place_outlined, size: 13, color: cs.onSurfaceVariant),
                  const SizedBox(width: 2),
                  Text('${trip.totalSpots}곳', style: tt.labelMedium),
                  const Spacer(),
                  CollaboratorStack(collaborators: trip.collaborators, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
