import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/collaborator.dart';
import '../data/mock_trips.dart';
import '../data/trip.dart';

class TripsNotifier extends StateNotifier<List<Trip>> {
  TripsNotifier() : super(List.of(mockTrips));

  Trip? byId(String id) {
    for (final t in state) {
      if (t.id == id) return t;
    }
    return null;
  }

  String create({
    required String title,
    required String region,
    required String coverEmoji,
    required int days,
  }) {
    final id = 't${DateTime.now().millisecondsSinceEpoch}';
    final trip = Trip(
      id: id,
      title: title,
      region: region,
      coverEmoji: coverEmoji,
      days: List.generate(
        days,
        (i) => TripDay(label: 'Day ${i + 1}', spotIds: const []),
      ),
      collaborators: const [
        Collaborator(id: 'c1', name: '나', emoji: '🙂', color: Color(0xFF5C8A6E)),
      ],
      updatedAt: DateTime.now(),
    );
    state = [trip, ...state];
    return id;
  }

  void addSpotToDay(String tripId, int dayIndex, String spotId) {
    state = state.map((t) {
      if (t.id != tripId) return t;
      final newDays = [...t.days];
      final day = newDays[dayIndex];
      if (day.spotIds.contains(spotId)) return t;
      newDays[dayIndex] = day.copyWith(
        spotIds: [...day.spotIds, spotId],
        optimized: false,
      );
      return t.copyWith(days: newDays);
    }).toList();
  }

  void removeSpotFromDay(String tripId, int dayIndex, String spotId) {
    state = state.map((t) {
      if (t.id != tripId) return t;
      final newDays = [...t.days];
      final day = newDays[dayIndex];
      newDays[dayIndex] = day.copyWith(
        spotIds: day.spotIds.where((id) => id != spotId).toList(),
        optimized: false,
      );
      return t.copyWith(days: newDays);
    }).toList();
  }

  void reorderSpots(String tripId, int dayIndex, int oldIdx, int newIdx) {
    state = state.map((t) {
      if (t.id != tripId) return t;
      final newDays = [...t.days];
      final day = newDays[dayIndex];
      final ids = [...day.spotIds];
      if (oldIdx < 0 || oldIdx >= ids.length) return t;
      final adj = newIdx > oldIdx ? newIdx - 1 : newIdx;
      final item = ids.removeAt(oldIdx);
      ids.insert(adj.clamp(0, ids.length), item);
      newDays[dayIndex] = day.copyWith(spotIds: ids, optimized: false);
      return t.copyWith(days: newDays);
    }).toList();
  }

  void markOptimized(String tripId) {
    state = state.map((t) {
      if (t.id != tripId) return t;
      return t.copyWith(
        days: t.days.map((d) => d.copyWith(optimized: true)).toList(),
      );
    }).toList();
  }
}

final tripsProvider = StateNotifierProvider<TripsNotifier, List<Trip>>(
  (ref) => TripsNotifier(),
);

final tripByIdProvider = Provider.family<Trip?, String>((ref, id) {
  final trips = ref.watch(tripsProvider);
  for (final t in trips) {
    if (t.id == id) return t;
  }
  return null;
});
