import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../models/ctf_event.dart';
import '../widgets/add_applied.dart';

class EventDetailsScreen extends StatefulWidget {
  final CtfEvent event;

  const EventDetailsScreen({Key? key, required this.event}) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isApplied = false;

  @override
  void initState() {
    super.initState();
    _checkApplied();
  }

  Future<void> _checkApplied() async {
    final box = await Hive.openBox<CtfEvent>('applied_events');
    setState(() {
      _isApplied = box.containsKey(widget.event.id);
    });
  }

  String _formatDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString).toLocal();
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  Widget _buildLabelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white70,
            fontSize: 15,
          ),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.white54,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1F1F),
        title: Text(
          event.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isApplied)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade700,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.shade700.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Applied',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            if (event.logo != null && event.logo!.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    event.logo!,
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image_not_supported, size: 120, color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              event.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            _buildLabelValue('Start', _formatDateTime(event.start)),
            _buildLabelValue('Finish', _formatDateTime(event.finish)),
            _buildLabelValue('Location', event.location.isNotEmpty ? event.location : 'Online'),
            _buildLabelValue('Format', event.format),
            _buildLabelValue('Onsite', event.onsite ? 'Yes' : 'No'),

            const Divider(
              height: 40,
              thickness: 1,
              color: Colors.white24,
            ),

            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description.isNotEmpty ? event.description : 'No description available.',
              style: const TextStyle(fontSize: 15, color: Colors.white54),
            ),

            const SizedBox(height: 32),

            Center(
              child: _isApplied
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade700,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.shade700.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Already Applied',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : AddAppliedButton(
                      event: event,
                      onApplied: () {
                        setState(() {
                          _isApplied = true;
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
