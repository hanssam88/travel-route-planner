class DiscoverGuide {
  final String id;
  final String title;
  final String author;
  final String authorEmoji;
  final String region;
  final String coverEmoji;
  final int spotCount;
  final int days;
  final List<String> moodTags;
  final int saves;

  const DiscoverGuide({
    required this.id,
    required this.title,
    required this.author,
    required this.authorEmoji,
    required this.region,
    required this.coverEmoji,
    required this.spotCount,
    required this.days,
    required this.moodTags,
    required this.saves,
  });
}
