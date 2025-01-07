import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class EventService {
  final String baseUrl;

  EventService(this.baseUrl);

  Future<List<Event>> fetchEvents() async {
    final response = await http.get(Uri.parse('$baseUrl/events'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<Event> fetchEventById(String eventId) async {
    final url = Uri.parse('$baseUrl/events/$eventId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Event.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load event');
    }
  }

  Future<String> deleteEvent(String eventId) async {
    final url = Uri.parse('$baseUrl/events/$eventId');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete event');
    }

    // Return success message
    return 'Event deleted successfully';
  }

  Future<void> createEvent(Event event) async {
    final url = Uri.parse('$baseUrl/events');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': event.title,
        'description': event.description,
        'location': event.location,
        'capacity': event.capacity,
        'imageUrl': event.imageUrl,
        'date': event.date.toIso8601String(),
        'participants': event.participants,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create event: ${response.body}');
    }
  }

  Future<void> participateInEvent(String eventId, String userId) async {
    final url = Uri.parse('$baseUrl/events/$eventId/participate');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'userId': userId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to participate in event');
    }
  }
}
