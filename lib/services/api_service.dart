import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class ApiService {
  static const String eventsUrl = 'https://hestia-admin.vercel.app/api/events';

  Future<Map<String, List<Event>>> fetchAndGroupEvents() async {
    try {
      final response = await http.get(Uri.parse(eventsUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<String, List<Event>> groupedEvents = {};

        for (var item in data) {
          final event = Event.fromJson(item);
          if (!groupedEvents.containsKey(event.category)) {
            groupedEvents[event.category] = [];
          }
          groupedEvents[event.category]!.add(event);
        }

        return groupedEvents;
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }
}
