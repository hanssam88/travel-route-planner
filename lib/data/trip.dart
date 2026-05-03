import 'collaborator.dart';

class TripDay {
  final String label; // e.g., 'Day 1'
  final List<String> spotIds;
  final bool optimized;

  const TripDay({
    required this.label,
    required this.spotIds,
    this.optimized = false,
  });

  TripDay copyWith({List<String>? spotIds, bool? optimized}) => TripDay(
        label: label,
        spotIds: spotIds ?? this.spotIds,
        optimized: optimized ?? this.optimized,
      );
}

class Trip {
  final String id;
  final String title;
  final String region;
  final String coverEmoji;
  final List<TripDay> days;
  final List<Collaborator> collaborators;
  final DateTime updatedAt;

  const Trip({
    required this.id,
    required this.title,
    required this.region,
    required this.coverEmoji,
    required this.days,
    required this.collaborators,
    required this.updatedAt,
  });

  int get totalSpots => days.fold(0, (sum, d) => sum + d.spotIds.length);
  bool get isOptimized => days.every((d) => d.optimized || d.spotIds.isEmpty);

  Trip copyWith({String? title, String? region, String? coverEmoji, List<TripDay>? days, List<Collaborator>? collaborators}) =>
      Trip(
        id: id,
        title: title ?? this.title,
        region: region ?? this.region,
        coverEmoji: coverEmoji ?? this.coverEmoji,
        days: days ?? this.days,
        collaborators: collaborators ?? this.collaborators,
        updatedAt: DateTime.now(),
      );
}
