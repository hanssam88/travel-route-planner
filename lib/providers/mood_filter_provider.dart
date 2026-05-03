import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoodFilterNotifier extends StateNotifier<Set<String>> {
  MoodFilterNotifier() : super(const {});

  void toggle(String tag) {
    state = state.contains(tag)
        ? (state.toSet()..remove(tag))
        : (state.toSet()..add(tag));
  }

  void clear() => state = const {};
}

final moodFilterProvider =
    StateNotifierProvider<MoodFilterNotifier, Set<String>>(
  (ref) => MoodFilterNotifier(),
);
