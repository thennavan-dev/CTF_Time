import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ctf_event.dart';

class ApiService {
  static const String baseUrl = 'https://ctftime.org/api/v1/events/';

  static Future<List<CtfEvent>> fetchUpcomingEvents({int weeksAhead = 4}) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final finish = DateTime.now()
        .add(Duration(days: weeksAhead * 7))
        .millisecondsSinceEpoch ~/ 1000;

    final url = Uri.parse('$baseUrl?limit=100&start=$now&finish=$finish');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CtfEvent.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load events: ${response.statusCode}');
    }
  }

  static Future<CtfEvent> fetchEventDetails(int eventId) async {
    final url = Uri.parse('$baseUrl$eventId/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return CtfEvent.fromJson(data);
    } else {
      throw Exception('Failed to load event $eventId: ${response.statusCode}');
    }
  }
}
