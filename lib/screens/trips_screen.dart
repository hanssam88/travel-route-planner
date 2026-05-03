import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/trips_provider.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/trip/trip_card.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);
    final tt = Theme.of(context).textTheme;
    final wide = !isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Trips', style: tt.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/trip/new'),
            tooltip: '새 Trip',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: trips.isEmpty
          ? EmptyState(
              icon: Icons.luggage_outlined,
              title: '아직 만든 Trip이 없어요',
              message: '저장한 스팟을 묶어 첫 Trip을 만들어보세요',
              action: FilledButton(
                onPressed: () => context.push('/trip/new'),
                child: const Text('새 Trip 만들기'),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, 100),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: wide ? 280 : 240,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemCount: trips.length,
              itemBuilder: (_, i) => TripCard(trip: trips[i]),
            ),
    );
  }
}
