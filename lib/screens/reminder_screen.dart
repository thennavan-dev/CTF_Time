import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/ctf_event_detail.dart';
import 'package:provider/provider.dart';
import '../controllers/card_controller.dart';
import '../models/ctf_event.dart';
import '../widgets/event_card.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cardController = Provider.of<CardController>(context);

    return FutureBuilder<Box<CtfEventDetail>>(
      future: Hive.openBox<CtfEventDetail>('ctf_event_details'),
      builder: (context, snap) {
        final reminders = cardController.events
            .where((e) => e.reminder == true)
            .toList();
        if (snap.connectionState == ConnectionState.done && snap.hasData) {
          final Box<CtfEventDetail> box = snap.data!;
          final detailsReminders = box.values
              .where((d) => d.isReminderSet == true)
              .toList();

          for (var d in detailsReminders) {
            try {
              final id = d.id;
              if (!reminders.any((r) => r.id == id)) {
                final ev = CtfEvent(
                  id: d.id,
                  title: d.title,
                  description: d.description,
                  url: d.url,
                  ctftimeUrl: d.ctftimeUrl,
                  logo: d.logo,
                  format: d.format,
                  formatId: d.formatId,
                  onsite: d.onsite,
                  restrictions: d.restrictions,
                  weight: d.weight,
                  participants: d.participants,
                  location: d.location,
                  liveFeed: d.liveFeed,
                  isVotableNow: d.isVotableNow,
                  publicVotable: d.publicVotable,
                  prizes: d.prizes,
                  start: d.start,
                  finish: d.finish,
                  durationSeconds: d.durationSeconds,
                  organizers: [],
                  reminder: true,
                );
                reminders.add(ev);
              }
            } catch (_) {}
          }
        }

        reminders.sort(
          (a, b) =>
              (a.start ?? DateTime.now()).compareTo(b.start ?? DateTime.now()),
        );

        if (reminders.isEmpty) {
          return const Center(child: Text('No reminders set'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final ev = reminders[index];
            return AnimatedEventCard(event: ev, index: index);
          },
        );
      },
    );
  }
}
