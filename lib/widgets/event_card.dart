import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../models/ctf_event.dart';

class EventCard extends StatelessWidget {
  final CtfEvent event;
  final VoidCallback? onTap;
  final Widget? bottomWidget;

  final bool showCheckbox;
  final bool? isSelected;
  final ValueChanged<bool?>? onCheckboxChanged;

  const EventCard({
    Key? key,
    required this.event,
    this.onTap,
    this.bottomWidget,
    this.showCheckbox = false,
    this.isSelected,
    this.onCheckboxChanged,
  }) : super(key: key);

  String _formatShortDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString).toLocal();
    return DateFormat('d MMM, h:mm a').format(dateTime);
  }

  Future<bool> _isApplied(int eventId) async {
    final box = await Hive.openBox<CtfEvent>('applied_events');
    return box.containsKey(eventId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isApplied(event.id),
      builder: (context, snapshot) {
        final isApplied = snapshot.data ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          color: const Color(0xFF1E1E1E),
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.6),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  event.logo != null && event.logo!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            event.logo!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.flag_outlined,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : const Icon(Icons.flag_outlined,
                          size: 50, color: Colors.grey),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isApplied && !showCheckbox)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.greenAccent,
                                  size: 20,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Time
                        Text(
                          '${_formatShortDateTime(event.start)} → ${_formatShortDateTime(event.finish)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 2),

                        // Format + Checkbox Row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Format: ${event.format}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ),
                            if (showCheckbox && isSelected != null)
                              Checkbox(
                                value: isSelected,
                                onChanged: onCheckboxChanged,
                                activeColor: Colors.tealAccent,
                                checkColor: Colors.black87,
                                side: const BorderSide(color: Colors.tealAccent, width: 1.5),
                              ),
                          ],
                        ),

                        if (bottomWidget != null) ...[
                          const SizedBox(height: 8),
                          bottomWidget!,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
