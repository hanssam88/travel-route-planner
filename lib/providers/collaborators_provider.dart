import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/collaborator.dart';
import 'trips_provider.dart';

/// Streams a live-updating list of collaborators for a trip,
/// moving the second collaborator's cursor across the trip's spots
/// every few seconds to mimic a real-time edit session.
final liveCollaboratorsProvider =
    StreamProvider.family<List<Collaborator>, String>((ref, tripId) {
  final trip = ref.watch(tripByIdProvider(tripId));
  if (trip == null) return Stream.value(const []);
  final base = trip.collaborators;
  if (base.length < 2) return Stream.value(base);

  final allSpotIds = trip.days.expand((d) => d.spotIds).toList();
  if (allSpotIds.isEmpty) return Stream.value(base);

  final rand = Random();
  final controller = StreamController<List<Collaborator>>();
  var idx = 0;

  void emit() {
    final updated = [...base];
    final spotId = allSpotIds[idx % allSpotIds.length];
    updated[1] = base[1].copyWith(cursorSpotId: spotId);
    if (updated.length > 2) {
      final altSpot = allSpotIds[(idx + 2) % allSpotIds.length];
      updated[2] = base[2].copyWith(cursorSpotId: altSpot);
    }
    controller.add(updated);
    idx = (idx + 1 + rand.nextInt(2));
  }

  emit();
  final timer = Timer.periodic(const Duration(seconds: 3), (_) => emit());

  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});
