import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_saved_spots.dart';
import '../data/saved_spot.dart';

class SavedSpotsNotifier extends StateNotifier<List<SavedSpot>> {
  SavedSpotsNotifier() : super(List.of(mockSavedSpots));

  void add(SavedSpot spot) {
    if (state.any((s) => s.id == spot.id)) return;
    state = [spot, ...state];
  }

  void addMany(List<SavedSpot> spots) {
    final existing = state.map((s) => s.id).toSet();
    final fresh = spots.where((s) => !existing.contains(s.id)).toList();
    if (fresh.isEmpty) return;
    state = [...fresh, ...state];
  }

  void remove(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  bool has(String id) => state.any((s) => s.id == id);

  SavedSpot? byId(String id) {
    for (final s in state) {
      if (s.id == id) return s;
    }
    return null;
  }
}

final savedSpotsProvider =
    StateNotifierProvider<SavedSpotsNotifier, List<SavedSpot>>(
  (ref) => SavedSpotsNotifier(),
);

final savedSpotByIdProvider =
    Provider.family<SavedSpot?, String>((ref, id) {
  final spots = ref.watch(savedSpotsProvider);
  for (final s in spots) {
    if (s.id == id) return s;
  }
  return null;
});
