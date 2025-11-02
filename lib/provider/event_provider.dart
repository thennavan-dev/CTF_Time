import 'package:flutter/material.dart';
import '../models/ctf_event.dart';

class EventProvider with ChangeNotifier {
  List<CtfEvent> _events = [];

  List<CtfEvent> get events => _events;

  void setEvents(List<CtfEvent> events) {
    _events = events;
    notifyListeners();
  }

  void addEvent(CtfEvent event) {
    _events.add(event);
    notifyListeners();
  }

  void removeEvent(CtfEvent event) {
    _events.remove(event);
    notifyListeners();
  }
}
