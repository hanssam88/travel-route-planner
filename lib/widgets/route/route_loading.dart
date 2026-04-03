import 'dart:async';
import 'package:flutter/material.dart';

const _loadingSteps = [
  '맛집을 검색하고 있어요...',
  '리뷰를 분석하고 있어요...',
  '최적 루트를 계산하고 있어요...',
  '거의 다 됐어요!',
];

class RouteLoading extends StatefulWidget {
  const RouteLoading({super.key});

  @override
  State<RouteLoading> createState() => _RouteLoadingState();
}

class _RouteLoadingState extends State<RouteLoading> {
  int _stepIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_stepIndex < _loadingSteps.length - 1) setState(() => _stepIndex++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (_stepIndex + 1) / _loadingSteps.length;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(_loadingSteps[_stepIndex], key: ValueKey(_stepIndex),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onSurface)),
            ),
            const SizedBox(height: 16),
            SizedBox(width: 200, child: LinearProgressIndicator(value: progress)),
            const SizedBox(height: 8),
            Text('${(_stepIndex + 1)}/${_loadingSteps.length}', style: TextStyle(fontSize: 12, color: colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}
