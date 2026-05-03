import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/saved_spot.dart';

class CongestionInfo {
  final Congestion congestion;
  final int? waitingMinutes;
  const CongestionInfo({required this.congestion, this.waitingMinutes});
}

/// Periodically nudges congestion + wait times for a spot id,
/// to simulate real-time crowd data without a backend.
final liveCongestionProvider =
    StreamProvider.family<CongestionInfo, String>((ref, spotId) {
  final rand = Random(spotId.hashCode);
  final controller = StreamController<CongestionInfo>();

  CongestionInfo gen() {
    final r = rand.nextDouble();
    final c = r < 0.4 ? Congestion.low : r < 0.75 ? Congestion.mid : Congestion.high;
    final wait = switch (c) {
      Congestion.low => rand.nextInt(5),
      Congestion.mid => 5 + rand.nextInt(15),
      Congestion.high => 20 + rand.nextInt(25),
    };
    return CongestionInfo(congestion: c, waitingMinutes: wait);
  }

  controller.add(gen());
  final timer = Timer.periodic(
    const Duration(seconds: 8),
    (_) => controller.add(gen()),
  );

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});
