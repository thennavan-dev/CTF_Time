// lib/controllers/event_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import '../models/ctf_event_detail.dart';
import '../models/ctf_event.dart';
import '../services/notification_service.dart';
import '../services/reminder_prefs.dart';
import '../utils/env.dart';

class EventController extends ChangeNotifier {
  final int eventId;
  CtfEventDetail? eventDetail;
  bool isLoading = true;
  String? errorMessage;

  late Box<CtfEventDetail> _eventBox;

  EventController({required this.eventId}) {
    _init();
  }

  Future<void> _init() async {
    _eventBox = await Hive.openBox<CtfEventDetail>('ctf_event_details');
    await fetchEventDetail();
  }

  Future<void> fetchEventDetail() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    if (_eventBox.containsKey(eventId)) {
      eventDetail = _eventBox.get(eventId);
      isLoading = false;
      notifyListeners();
      return;
    }

    final url =
        Env.apiBaseUrl +
        Env.eventInfoEndpoint.replaceFirst("{event_id}", eventId.toString());

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        eventDetail = CtfEventDetail.fromJson(jsonData);

        await _eventBox.put(eventId, eventDetail!);

        isLoading = false;
        notifyListeners();
      } else {
        errorMessage = "Failed to load event: ${response.statusCode}";
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = "Error: $e";
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshEvent() async {
    await _eventBox.delete(eventId);
    await fetchEventDetail();
  }

  Future<void> toggleReminder() async {
    if (eventDetail == null) return;
    eventDetail!.isReminderSet = !(eventDetail!.isReminderSet);
    await _eventBox.put(eventId, eventDetail!);
    notifyListeners();
  }

  Future<void> toggleReminderAndSync() async {
    await toggleReminder();

    try {
      Box<CtfEvent> boxCtf;
      if (Hive.isBoxOpen('ctf_events')) {
        boxCtf = Hive.box<CtfEvent>('ctf_events');
      } else {
        boxCtf = await Hive.openBox<CtfEvent>('ctf_events');
      }

      if (boxCtf.containsKey(eventId)) {
        final item = boxCtf.get(eventId);
        if (item != null) {
          try {
            (item as dynamic).reminder = eventDetail!.isReminderSet;
            await boxCtf.put(eventId, item);
          } catch (_) {
            // ignore
          }
        }
      }
    } catch (_) {
      // ignore
    }

    try {
      if (eventDetail != null) {
        if (eventDetail!.isReminderSet) {
          final offsets = await ReminderPrefs.getOffsets();
          await NotificationService().scheduleForEvent(eventDetail!, offsets);
        } else {
          await NotificationService().cancelForEvent(eventId);
        }
      }
    } catch (_) {
      // ignore
    }
  }
}
