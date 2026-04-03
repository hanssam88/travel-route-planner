class Place {
  final String slot;
  final String name;
  final String address;
  final String roadAddress;
  final String category;
  final double lat;
  final double lng;
  final String reason;
  final int estimatedBudget;
  final String? reviewSummary;

  const Place({
    required this.slot,
    required this.name,
    required this.address,
    required this.roadAddress,
    required this.category,
    required this.lat,
    required this.lng,
    required this.reason,
    required this.estimatedBudget,
    this.reviewSummary,
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
        slot: json['slot'] as String,
        name: json['name'] as String,
        address: json['address'] as String? ?? '',
        roadAddress: json['roadAddress'] as String? ?? '',
        category: json['category'] as String? ?? '',
        lat: (json['coordinates']?['lat'] as num?)?.toDouble() ?? 0,
        lng: (json['coordinates']?['lng'] as num?)?.toDouble() ?? 0,
        reason: json['reason'] as String? ?? '',
        estimatedBudget: (json['estimatedBudget'] as num?)?.toInt() ?? 0,
        reviewSummary: json['reviewSummary'] as String?,
      );

  String get slotLabel => switch (slot) {
        'breakfast' => '아침',
        'morning_cafe' => '오전 카페',
        'lunch' => '점심',
        'afternoon_cafe' => '오후 카페',
        'dinner' => '저녁',
        _ => slot,
      };

  bool get isCafe =>
      slot == 'morning_cafe' || slot == 'afternoon_cafe';
}
