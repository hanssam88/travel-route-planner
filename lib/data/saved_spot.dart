import 'import_source.dart';

enum Congestion { low, mid, high }

extension CongestionX on Congestion {
  String get label => switch (this) {
        Congestion.low => '여유',
        Congestion.mid => '보통',
        Congestion.high => '혼잡',
      };
}

class SavedSpot {
  final String id;
  final String name;
  final String region;
  final String category;
  final ImportSource source;
  final double lat;
  final double lng;
  final List<String> moodTags;
  final int? waitingMinutes;
  final Congestion congestion;
  final String emoji;
  final String? note;
  final int? estimatedBudget;

  const SavedSpot({
    required this.id,
    required this.name,
    required this.region,
    required this.category,
    required this.source,
    required this.lat,
    required this.lng,
    required this.moodTags,
    required this.waitingMinutes,
    required this.congestion,
    required this.emoji,
    this.note,
    this.estimatedBudget,
  });

  SavedSpot copyWith({Congestion? congestion, int? waitingMinutes}) => SavedSpot(
        id: id,
        name: name,
        region: region,
        category: category,
        source: source,
        lat: lat,
        lng: lng,
        moodTags: moodTags,
        waitingMinutes: waitingMinutes ?? this.waitingMinutes,
        congestion: congestion ?? this.congestion,
        emoji: emoji,
        note: note,
        estimatedBudget: estimatedBudget,
      );
}
