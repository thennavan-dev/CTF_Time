import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/ctf_event.dart';
import '../models/ctf_event_detail.dart';
import 'package:provider/provider.dart';
import '../controllers/card_controller.dart';
import '../services/reminder_prefs.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String appVersion = '1.0.0+1';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Information about this app'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'CTF Events',
              applicationVersion: appVersion,
              children: const [
                Text('A simple app to browse and remind CTF events.'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.alarm_add_outlined),
            title: const Text('Reminder times'),
            subtitle: const Text(
              'Manage default reminder offsets applied to all reminders',
            ),
            onTap: () async {
              final current = await ReminderPrefs.getOffsets();
              List<int> offsets = List<int>.from(current);

              await showDialog<void>(
                context: context,
                builder: (context) {
                  final controller = TextEditingController();
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: const Text(
                          'Reminder times (minutes before start)',
                        ),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                spacing: 8,
                                children: offsets
                                    .map(
                                      (m) => Chip(
                                        label: Text(
                                          m >= 60 ? '${m ~/ 60}h' : '$m min',
                                        ),
                                        onDeleted: () async {
                                          offsets.remove(m);
                                          setState(() {});
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter minutes (e.g. 15)',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      final v = int.tryParse(controller.text);
                                      if (v != null && v > 0) {
                                        if (!offsets.contains(v)) {
                                          offsets.add(v);
                                          offsets.sort(
                                            (a, b) => b.compareTo(a),
                                          );
                                          controller.clear();
                                          setState(() {});
                                        }
                                      }
                                    },
                                    child: const Text('Add'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await ReminderPrefs.setOffsets(offsets);

                              try {
                                final Box<CtfEvent> eventsBox =
                                    Hive.isBoxOpen('ctf_events')
                                    ? Hive.box<CtfEvent>('ctf_events')
                                    : await Hive.openBox<CtfEvent>(
                                        'ctf_events',
                                      );

                                final Box<CtfEventDetail> detailsBox =
                                    Hive.isBoxOpen('ctf_event_details')
                                    ? Hive.box<CtfEventDetail>(
                                        'ctf_event_details',
                                      )
                                    : await Hive.openBox<CtfEventDetail>(
                                        'ctf_event_details',
                                      );

                                for (var ev in eventsBox.values) {
                                  try {
                                    if ((ev as dynamic).reminder == true) {
                                      await NotificationService()
                                          .cancelForEvent(ev.id);

                                      CtfEventDetail? detail;
                                      if (detailsBox.containsKey(ev.id)) {
                                        detail = detailsBox.get(ev.id);
                                      } else {
                                        detail = CtfEventDetail(
                                          id: ev.id,
                                          title: ev.title,
                                          organizers: ev.organizers,
                                          ctfId: null,
                                          description: ev.description,
                                          url: ev.url,
                                          ctftimeUrl: ev.ctftimeUrl,
                                          logo: ev.logo,
                                          format: ev.format,
                                          formatId: ev.formatId,
                                          onsite: ev.onsite,
                                          restrictions: ev.restrictions,
                                          weight: ev.weight,
                                          participants: ev.participants,
                                          location: ev.location,
                                          liveFeed: ev.liveFeed,
                                          isVotableNow: ev.isVotableNow,
                                          publicVotable: ev.publicVotable,
                                          prizes: ev.prizes,
                                          start: ev.start,
                                          finish: ev.finish,
                                          durationSeconds: ev.durationSeconds,
                                          isReminderSet: true,
                                        );
                                      }

                                      if (detail != null) {
                                        await NotificationService()
                                            .scheduleForEvent(detail, offsets);
                                      }
                                    }
                                  } catch (_) {}
                                }
                              } catch (_) {}

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reminder times updated'),
                                ),
                              );
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text(
              'Delete cached data',
              style: TextStyle(color: Colors.redAccent),
            ),
            subtitle: const Text(
              'Clear all saved Hive data (events & details)',
            ),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete all data?'),
                  content: const Text(
                    'This will remove all cached events and details. This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                try {
                  if (Hive.isBoxOpen('ctf_events')) {
                    final Box<CtfEvent> b = Hive.box<CtfEvent>('ctf_events');
                    await b.clear();
                  } else {
                    final Box<CtfEvent> b = await Hive.openBox<CtfEvent>(
                      'ctf_events',
                    );
                    await b.clear();
                  }

                  if (Hive.isBoxOpen('ctf_event_details')) {
                    final Box<CtfEventDetail> b2 = Hive.box<CtfEventDetail>(
                      'ctf_event_details',
                    );
                    await b2.clear();
                  } else {
                    final Box<CtfEventDetail> b2 =
                        await Hive.openBox<CtfEventDetail>('ctf_event_details');
                    await b2.clear();
                  }

                  try {
                    await NotificationService().cancelAllScheduled();
                  } catch (_) {}

                  Provider.of<CardController>(
                    context,
                    listen: false,
                  ).loadFromHive();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cached data deleted')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete data: $e')),
                  );
                }
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Version'),
            subtitle: const Text(appVersion),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
