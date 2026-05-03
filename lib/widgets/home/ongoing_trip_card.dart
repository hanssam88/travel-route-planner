import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/trip.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../trip/collaborator_stack.dart';

class OngoingTripCard extends StatelessWidget {
  final Trip trip;
  const OngoingTripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Material(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.lg),
          onTap: () => context.push('/trip/${trip.id}'),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.sageContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                  alignment: Alignment.center,
                  child: Text(trip.coverEmoji, style: const TextStyle(fontSize: 30)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('진행 중', style: tt.labelSmall?.copyWith(color: cs.onPrimaryContainer)),
                          ),
                          const SizedBox(width: 6),
                          Text(trip.region, style: tt.labelMedium),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(trip.title, style: tt.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text('${trip.days.length}일 · ${trip.totalSpots}곳', style: tt.bodySmall),
                          const Spacer(),
                          CollaboratorStack(collaborators: trip.collaborators, size: 22),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
