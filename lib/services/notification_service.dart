import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:hive/hive.dart';
import '../models/ctf_event_detail.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static const String _scheduledBox = 'scheduled_notifications';

  Future<void> init() async {
    tzdata.initializeTimeZones();

    tz.setLocalLocation(tz.local);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: iOS);

    await _plugin.initialize(initSettings);
  }

  Future<void> scheduleForEvent(
    CtfEventDetail event,
    List<int> offsetsMinutes,
  ) async {
    if (event.start == null) return;
    final start = event.start!.toLocal();

    final box = await Hive.openBox<List<int>>(_scheduledBox);
    final List<int> scheduledIds = [];

    for (var i = 0; i < offsetsMinutes.length; i++) {
      final offset = offsetsMinutes[i];
      final scheduledTime = start.subtract(Duration(minutes: offset));

      if (scheduledTime.isAfter(DateTime.now())) {
        final id = event.id * 100 + (i + 1);
        scheduledIds.add(id);

        final details = NotificationDetails(
          android: AndroidNotificationDetails(
            'ctf_channel',
            'CTF Reminders',
            channelDescription: 'Reminders for CTF events',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        );

        await _plugin.zonedSchedule(
          id,
          'CTF starting: ${event.title}',
          offset >= 60
              ? 'Starts in ${offset ~/ 60} hour(s)'
              : 'Starts in $offset minute(s)',
          tz.TZDateTime.from(scheduledTime, tz.local),
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
      }
    }

    if (scheduledIds.isNotEmpty) {
      await box.put(event.id.toString(), scheduledIds);
    }
  }

  Future<void> cancelForEvent(int eventId) async {
    final box = await Hive.openBox<List<int>>(_scheduledBox);
    final key = eventId.toString();

    if (box.containsKey(key)) {
      final ids = box.get(key) ?? [];
      for (var id in ids) {
        try {
          await _plugin.cancel(id);
        } catch (_) {}
      }
      await box.delete(key);
    }
  }

  Future<void> cancelAllScheduled() async {
    final box = await Hive.openBox<List<int>>(_scheduledBox);

    for (var key in box.keys) {
      final ids = box.get(key) ?? [];
      for (var id in ids) {
        try {
          await _plugin.cancel(id);
        } catch (_) {}
      }
    }

    await box.clear();
  }
}
