import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/ctf_event.dart';
import '../screens/event_screen.dart';

class AnimatedEventCard extends StatefulWidget {
  final CtfEvent event;
  final int index;
  final bool showReminderTick;
  final Future<void> Function(CtfEvent)? onToggleReminder;

  const AnimatedEventCard({
    super.key,
    required this.event,
    required this.index,
    this.showReminderTick = false,
    this.onToggleReminder,
  });

  @override
  State<AnimatedEventCard> createState() => _AnimatedEventCardState();
}

class _AnimatedEventCardState extends State<AnimatedEventCard>
    with SingleTickerProviderStateMixin {
  static bool _introShown = false;
  static const int _introCount = 5;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _shouldAnimate = false;

  @override
  void initState() {
    super.initState();

    _shouldAnimate = !_introShown && widget.index < _introCount;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    if (_shouldAnimate) {
      Future.delayed(Duration(milliseconds: widget.index * 150), () {
        if (mounted) {
          _controller.forward();

          if (widget.index >= _introCount - 1) {
            _introShown = true;
          }
        }
      });
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final type = widget.event.format ?? 'Unknown';
    final visibility = widget.event.publicVotable == true
        ? 'Public'
        : 'Private';
    final start = widget.event.start?.toLocal();
    final end = widget.event.finish?.toLocal();
    final remaining = _timeLeft(end);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black38,
          color: theme.cardColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventScreen(eventId: widget.event.id),
                ),
              );
            },
            splashColor: theme.primaryColor.withOpacity(0.1),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildThumbnail(theme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.event.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _tag(context, visibility),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$type  •  By: ${widget.event.organizers.map((e) => e.name).join(", ")}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.7),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: theme.iconTheme.color,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${_shortDate(start)} → ${_shortDate(end)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withOpacity(0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _info(
                              Icons.access_time,
                              remaining,
                              theme.primaryColor,
                            ),
                            _buildModeInfo(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.showReminderTick &&
                      widget.event.reminder == true) ...[
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Reminded',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 28,
                              minHeight: 28,
                            ),
                            icon: Icon(
                              Icons.cancel,
                              size: 18,
                              color: theme.iconTheme.color,
                            ),
                            tooltip: 'Cancel reminder',
                            onPressed: widget.onToggleReminder == null
                                ? null
                                : () async {
                                    try {
                                      await widget.onToggleReminder!(
                                        widget.event,
                                      );
                                    } catch (_) {}
                                  },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(ThemeData theme) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: widget.event.logo != null && widget.event.logo!.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: widget.event.logo!,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            placeholder: (_, __) => _placeholder(theme),
            errorWidget: (_, __, ___) => _placeholder(theme),
          )
        : _placeholder(theme),
  );

  Widget _placeholder(ThemeData theme) => Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: theme.dividerColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(Icons.image_not_supported, color: Colors.grey),
  );

  Widget _tag(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: text == 'Public' ? Colors.green.shade700 : Colors.red.shade700,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: text == 'Public' ? Colors.green.shade900 : Colors.red.shade900,
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text, Color color) => Row(
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(text, style: GoogleFonts.robotoMono(fontSize: 12, color: color)),
    ],
  );

  Widget _buildModeInfo() {
    final onsite = widget.event.onsite;
    final bool? isOnline = onsite == null ? null : !onsite;

    final String label = isOnline == null
        ? 'Mode: TBA'
        : (isOnline ? 'Online' : 'Offline');

    final IconData icon = isOnline == null
        ? Icons.help_outline
        : (isOnline ? Icons.wifi_tethering : Icons.apartment);

    final Color color = isOnline == null
        ? Colors.grey
        : (isOnline ? Colors.teal.shade700 : Colors.deepOrange.shade700);

    return _info(icon, label, color);
  }

  String _shortDate(DateTime? d) {
    if (d == null) return 'TBA';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final m = months[d.month - 1];
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '$m ${d.day}, $hour:${d.minute.toString().padLeft(2, '0')} $ampm';
  }

  String _timeLeft(DateTime? end) {
    if (end == null) return 'TBA';
    final now = DateTime.now();
    final diff = end.difference(now);
    if (diff.isNegative) return 'Ended';

    final days = diff.inDays;
    final hours = diff.inHours.remainder(24);
    final minutes = max(diff.inMinutes.remainder(60), 1);

    if (days > 0) return '${days}d ${hours}h left';
    if (hours > 0) return '${hours}h ${minutes}m left';
    return '${minutes}m left';
  }
}
