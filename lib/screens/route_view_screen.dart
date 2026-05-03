import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/trip.dart';
import '../providers/trips_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/responsive.dart';
import '../widgets/route/route_timeline_view.dart';
import '../widgets/trip/day_tab_bar.dart';

class RouteViewScreen extends ConsumerStatefulWidget {
  final String tripId;
  const RouteViewScreen({super.key, required this.tripId});

  @override
  ConsumerState<RouteViewScreen> createState() => _RouteViewScreenState();
}

class _RouteViewScreenState extends ConsumerState<RouteViewScreen> {
  int _activeDay = 0;

  @override
  Widget build(BuildContext context) {
    final trip = ref.watch(tripByIdProvider(widget.tripId));
    final tt = Theme.of(context).textTheme;
    if (trip == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Trip 없음')));

    final activeDay = trip.days[_activeDay];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        title: Row(
          children: [
            const Icon(Icons.bolt, size: 18),
            const SizedBox(width: 4),
            Text('최적화 루트', style: tt.titleLarge),
          ],
        ),
      ),
      body: isMobile(context) ? _Mobile(trip: trip, activeDay: _activeDay, onDayChanged: (i) => setState(() => _activeDay = i)) : _Desktop(trip: trip, activeDay: _activeDay, onDayChanged: (i) => setState(() => _activeDay = i)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions, size: 18),
                  label: const Text('네비 시작'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    final ids = activeDay.spotIds;
                    if (ids.isEmpty) return;
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => _AllSavedSheet(spotIds: ids),
                    );
                  },
                  icon: const Icon(Icons.bookmark, size: 18),
                  label: const Text('전체 저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Mobile extends StatelessWidget {
  final Trip trip;
  final int activeDay;
  final ValueChanged<int> onDayChanged;

  const _Mobile({required this.trip, required this.activeDay, required this.onDayChanged});

  @override
  Widget build(BuildContext context) {
    final activeDayData = trip.days[activeDay];
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: _MapMock(spotIds: activeDayData.spotIds),
        ),
        DayTabBar(days: trip.days, activeIndex: activeDay, onChanged: onDayChanged),
        Expanded(child: RouteTimelineView(spotIds: activeDayData.spotIds)),
      ],
    );
  }
}

class _Desktop extends StatelessWidget {
  final Trip trip;
  final int activeDay;
  final ValueChanged<int> onDayChanged;

  const _Desktop({required this.trip, required this.activeDay, required this.onDayChanged});

  @override
  Widget build(BuildContext context) {
    final activeDayData = trip.days[activeDay];
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.lg),
              child: _MapMock(spotIds: activeDayData.spotIds),
            ),
          ),
        ),
        SizedBox(
          width: 460,
          child: Column(
            children: [
              DayTabBar(days: trip.days, activeIndex: activeDay, onChanged: onDayChanged),
              Expanded(child: RouteTimelineView(spotIds: activeDayData.spotIds)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapMock extends ConsumerWidget {
  final List<String> spotIds;
  const _MapMock({required this.spotIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sageContainer, AppColors.creamHigh],
        ),
      ),
      child: Stack(
        children: [
          // grid lines
          for (int i = 0; i < 6; i++)
            Positioned(
              left: 0, right: 0, top: 40.0 * i,
              child: Container(height: 1, color: Colors.white.withValues(alpha: 0.4)),
            ),
          // route line zigzag
          if (spotIds.length > 1)
            CustomPaint(
              painter: _RoutePainter(count: spotIds.length, color: cs.primary),
              size: Size.infinite,
            ),
          // pins
          for (int i = 0; i < spotIds.length; i++)
            Positioned(
              left: 30 + (i * 60.0) % 280,
              top: 40 + (i * 47.0) % 140,
              child: _NumberedPin(index: i + 1, color: cs.primary),
            ),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final int count;
  final Color color;
  _RoutePainter({required this.count, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path();
    for (int i = 0; i < count; i++) {
      final x = 30.0 + (i * 60.0) % 280 + 14;
      final y = 40.0 + (i * 47.0) % 140 + 14;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    final dashed = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, dashed);
    canvas.drawPath(path, paint..color = color.withValues(alpha: 0.4));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _NumberedPin extends StatelessWidget {
  final int index;
  final Color color;
  const _NumberedPin({required this.index, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4)],
      ),
      alignment: Alignment.center,
      child: Text('$index', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
    );
  }
}

class _AllSavedSheet extends ConsumerWidget {
  final List<String> spotIds;
  const _AllSavedSheet({required this.spotIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이 Day의 ${spotIds.length}개 스팟', style: tt.titleLarge),
            const SizedBox(height: 12),
            Text('이미 저장된 스팟이에요. 친구에게 공유하거나 가이드로 만들 수 있어요.', style: tt.bodyMedium),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('가이드로 발행 준비됨')),
                );
              },
              child: const Text('가이드로 발행하기'),
            ),
          ],
        ),
      ),
    );
  }
}
