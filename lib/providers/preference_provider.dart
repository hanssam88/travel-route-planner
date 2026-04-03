import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/preference.dart';

class PreferenceState {
  final String region;
  final List<String> foodTypes;
  final BudgetRange budgetRange;
  final TransportMode transportMode;
  final String? additionalRequest;
  final bool isComplete;

  const PreferenceState({
    this.region = '',
    this.foodTypes = const [],
    this.budgetRange = BudgetRange.from10kTo30k,
    this.transportMode = TransportMode.driving,
    this.additionalRequest,
    this.isComplete = false,
  });

  PreferenceState copyWith({
    String? region,
    List<String>? foodTypes,
    BudgetRange? budgetRange,
    TransportMode? transportMode,
    String? additionalRequest,
    bool? isComplete,
  }) =>
      PreferenceState(
        region: region ?? this.region,
        foodTypes: foodTypes ?? this.foodTypes,
        budgetRange: budgetRange ?? this.budgetRange,
        transportMode: transportMode ?? this.transportMode,
        additionalRequest: additionalRequest ?? this.additionalRequest,
        isComplete: isComplete ?? this.isComplete,
      );

  UserPreference toPreference() => UserPreference(
        region: region,
        foodTypes: foodTypes,
        budgetRange: budgetRange,
        transportMode: transportMode,
        additionalRequest: additionalRequest,
      );

  bool get canSubmit => region.isNotEmpty && foodTypes.isNotEmpty;
}

class PreferenceNotifier extends StateNotifier<PreferenceState> {
  PreferenceNotifier() : super(const PreferenceState());

  void setRegion(String region) =>
      state = state.copyWith(region: region);

  void toggleFoodType(String type) {
    final list = List<String>.from(state.foodTypes);
    if (list.contains(type)) {
      list.remove(type);
    } else {
      list.add(type);
    }
    state = state.copyWith(foodTypes: list);
  }

  void setBudgetRange(BudgetRange range) =>
      state = state.copyWith(budgetRange: range);

  void setTransportMode(TransportMode mode) =>
      state = state.copyWith(transportMode: mode);

  void setAdditionalRequest(String? request) =>
      state = state.copyWith(additionalRequest: request);

  void markComplete() =>
      state = state.copyWith(isComplete: true);

  void reset() => state = const PreferenceState();
}

final preferenceProvider =
    StateNotifierProvider<PreferenceNotifier, PreferenceState>(
  (ref) => PreferenceNotifier(),
);
