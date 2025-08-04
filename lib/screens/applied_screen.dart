import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/ctf_event.dart';
import '../widgets/event_card.dart';
import 'event_details.dart';

class AppliedScreen extends StatefulWidget {
  const AppliedScreen({Key? key}) : super(key: key);

  @override
  State<AppliedScreen> createState() => _AppliedScreenState();
}

class _AppliedScreenState extends State<AppliedScreen> {
  Box<CtfEvent>? _appliedBox;
  bool _deleteMode = false;
  final Set<int> _selectedKeys = {};

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _appliedBox = await Hive.openBox<CtfEvent>('applied_events');
    setState(() {});
  }

  void _toggleDeleteMode() {
    setState(() {
      _deleteMode = !_deleteMode;
      _selectedKeys.clear();
    });
  }

  void _toggleSelection(int key) {
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
    });
  }

  void _deleteSelected() async {
    if (_appliedBox == null || _selectedKeys.isEmpty) return;

    final deletedCount = _selectedKeys.length;

    for (var key in _selectedKeys) {
      await _appliedBox!.delete(key);
    }

    setState(() {
      _deleteMode = false;
      _selectedKeys.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$deletedCount event${deletedCount > 1 ? "s" : ""} deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_appliedBox == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
    }

    final keys = _appliedBox!.keys.cast<int>().toList();
    final appliedEvents = _appliedBox!.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF272727),
        elevation: 4,
        title: Text(
          _deleteMode ? 'Select Events' : 'Applied Events',
          style: const TextStyle(
            color: Colors.tealAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.7,
          ),
        ),
        actions: [
          if (_deleteMode)
            IconButton(
              icon: Icon(
                Icons.delete,
                color: _selectedKeys.isNotEmpty ? Colors.redAccent : Colors.grey,
              ),
              onPressed: _selectedKeys.isNotEmpty ? _deleteSelected : null,
              tooltip: 'Delete selected events',
            ),
          IconButton(
            icon: Icon(
              _deleteMode ? Icons.close : Icons.delete_sweep,
              color: Colors.tealAccent,
            ),
            onPressed: _toggleDeleteMode,
            tooltip: _deleteMode ? 'Cancel selection' : 'Delete events',
          ),
        ],
      ),
      body: appliedEvents.isEmpty
          ? const Center(
              child: Text(
                'No applied events yet.',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: appliedEvents.length,
              itemBuilder: (context, index) {
                final event = appliedEvents[index];
                final key = keys[index];
                final isSelected = _selectedKeys.contains(key);

                return EventCard(
                  event: event,
                  onTap: () {
                    if (_deleteMode) {
                      _toggleSelection(key);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailsScreen(event: event),
                        ),
                      );
                    }
                  },
                  showCheckbox: _deleteMode,
                  isSelected: isSelected,
                  onCheckboxChanged: (_) => _toggleSelection(key),
                );
              },
            ),
    );
  }
}
