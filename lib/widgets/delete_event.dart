import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/ctf_event.dart';

class DeleteEventScreen extends StatefulWidget {
  final Box<CtfEvent> appliedBox;

  const DeleteEventScreen({Key? key, required this.appliedBox}) : super(key: key);

  @override
  State<DeleteEventScreen> createState() => _DeleteEventScreenState();
}

class _DeleteEventScreenState extends State<DeleteEventScreen> {
  final Set<int> _selectedKeys = {};

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
    if (_selectedKeys.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${_selectedKeys.length} selected events?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    for (var key in _selectedKeys) {
      await widget.appliedBox.delete(key);
    }

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedKeys.length} events deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.appliedBox.toMap();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: Text(_selectedKeys.isEmpty
            ? 'Select Events to Delete'
            : '${_selectedKeys.length} Selected'),
        actions: [
          if (_selectedKeys.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              onPressed: _deleteSelected,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: events.entries.map((entry) {
          final key = entry.key;
          final event = entry.value;
          final selected = _selectedKeys.contains(key);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: selected ? Colors.tealAccent : Colors.white12),
            ),
            color: const Color(0xFF1E1E1E),
            elevation: selected ? 8 : 4,
            shadowColor: selected ? Colors.tealAccent : Colors.black54,
            child: ListTile(
              leading: Checkbox(
                value: selected,
                onChanged: (_) => _toggleSelection(key),
                activeColor: Colors.tealAccent,
              ),
              title: Text(event.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${event.start} → ${event.finish}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              onTap: () => _toggleSelection(key),
            ),
          );
        }).toList(),
      ),
    );
  }
}
