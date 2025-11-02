// lib/screens/event_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/event_controller.dart';
import '../widgets/detail_view.dart';

class EventScreen extends StatelessWidget {
  final int eventId;

  const EventScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EventController>(
      create: (_) => EventController(eventId: eventId),
      child: Consumer<EventController>(
        builder: (context, controller, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(controller.eventDetail?.title ?? 'Event Details'),
            ),
            body: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.errorMessage != null
                ? Center(child: Text(controller.errorMessage!))
                : controller.eventDetail != null
                ? DetailView(event: controller.eventDetail!)
                : const Center(child: Text("No event found")),
          );
        },
      ),
    );
  }
}
