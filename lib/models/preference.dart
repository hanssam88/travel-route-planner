class UserPreference {
  final String region;
  final String? date;
  final List<String> foodTypes;
  final BudgetRange budgetRange;
  final TransportMode transportMode;
  final String? additionalRequest;

  const UserPreference({
    required this.region,
    this.date,
    required this.foodTypes,
    required this.budgetRange,
    required this.transportMode,
    this.additionalRequest,
  });

  Map<String, dynamic> toJson() => {
        'region': region,
        if (date != null) 'date': date,
        'foodTypes': foodTypes,
        'budgetRange': budgetRange.value,
        'transportMode': transportMode.value,
        if (additionalRequest != null) 'additionalRequest': additionalRequest,
      };
}

enum BudgetRange {
  under10k('under_10k', '1만원 이하'),
  from10kTo30k('10k_30k', '1~3만원'),
  from30kTo50k('30k_50k', '3~5만원'),
  noLimit('no_limit', '상관없음');

  final String value;
  final String label;
  const BudgetRange(this.value, this.label);
}

enum TransportMode {
  driving('driving', '자가용'),
  transit('transit', '대중교통'),
  walking('walking', '도보');

  final String value;
  final String label;
  const TransportMode(this.value, this.label);
}
