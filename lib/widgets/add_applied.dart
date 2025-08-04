import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/ctf_event.dart';
import '../models/user_settings.dart';
import '../service/notification_service.dart';

class AddAppliedButton extends StatelessWidget {
  final CtfEvent event;
  final VoidCallback onApplied;

  const AddAppliedButton({
    Key? key,
    required this.event,
    required this.onApplied,
  }) : super(key: key);

  Future<void> _applyToEvent(BuildContext context) async {
    final appliedBox = await Hive.openBox<CtfEvent>('applied_events');
    final settingsBox = await Hive.openBox<UserSettings>('settingsBox');

    await appliedBox.put(event.id, event);

    int minutesBefore = 60;
    if (settingsBox.isNotEmpty) {
      minutesBefore = settingsBox.getAt(0)!.reminderMinutes;
    }

    final startTime = DateTime.parse(event.start).toLocal();
    final notifyTime = startTime.subtract(Duration(minutes: minutesBefore));

    if (notifyTime.isAfter(DateTime.now())) {
      await NotificationService.scheduleNotification(
        id: event.id,
        title: "CTF Reminder",
        body: "Your CTF '${event.title}' is starting soon!",
        scheduledTime: notifyTime,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Event applied and notification set!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );

    onApplied();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add_alert, color: Colors.black),
      label: const Text(
        "Apply & Notify Me",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.tealAccent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 8,
        shadowColor: Colors.tealAccent.withOpacity(0.6),
      ),
      onPressed: () => _applyToEvent(context),
    );
  }
}
