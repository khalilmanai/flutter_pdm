import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@JsonSerializable()
class Event {
      final String? id; // Make id nullable
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final int capacity;
  final List<String> participants; // Assuming participant IDs are returned as strings
  final String imageUrl;

  Event({
        this.id, // id is optional

    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.capacity,
    required this.participants,
    required this.imageUrl,
  });

factory Event.fromJson(Map<String, dynamic> json) {
  return Event(
    id: json['_id'] ?? '', // Provide a default value if null
    title: json['title'] ?? 'Untitled',
    description: json['description'] ?? '',
    date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    location: json['location'] ?? 'Unknown',
    capacity: json['capacity'] ?? 0,
    participants: (json['participants'] as List<dynamic>?)
            ?.map((id) => id.toString())
            .toList() ??
        [],
    imageUrl: json['imageUrl'] ?? '',
  );
}

  Map<String, dynamic> toJson() => _$EventToJson(this);
}
