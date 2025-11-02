import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/card_controller.dart';
import '../widgets/event_card.dart';
import '../widgets/custom_navbar.dart';
import 'reminder_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cardController = Provider.of<CardController>(context);

    if (cardController.isLoading && cardController.events.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      _buildHome(cardController),
      const ReminderScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'CTF Events' : _currentIndex == 1 ? 'Reminders' : 'Settings'),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              tooltip: 'Reload events',
              onPressed: cardController.isLoading
                  ? null
                  : () async {
                      await cardController.fetchUpcomingEvents(reset: true, showLoading: true);
                    },
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
      ),
    );
  }

  Widget _buildHome(CardController cardController) {
    if (cardController.events.isEmpty) {
      return const Center(
        child: Text(
          "No data available",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(

      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: cardController.events.length,
        itemBuilder: (context, index) {
        final event = cardController.events[index];

        return AnimatedEventCard(
          event: event,
          index: index,
          showReminderTick: true,
          onToggleReminder: (ev) async {
            await cardController.setReminder(ev.id, false);
          },
        );
      },
    );
  }
}
