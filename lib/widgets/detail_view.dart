// lib/widgets/detail_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/ctf_event_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/event_controller.dart';

class DetailView extends StatelessWidget {
  final CtfEventDetail event;

  const DetailView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Provider.of<EventController>(context, listen: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.calendar_today,
                    "Start",
                    _formatDate(event.start),
                  ),
                  _buildInfoRow(
                    Icons.calendar_today,
                    "Finish",
                    _formatDate(event.finish),
                  ),
                  _buildInfoRow(
                    Icons.location_on,
                    "Location",
                    event.location ?? "TBA",
                  ),
                  _buildInfoRow(
                    Icons.people,
                    "Participants",
                    "${event.participants ?? 'N/A'}",
                  ),
                  _buildInfoRow(
                    Icons.score,
                    "Weight",
                    "${event.weight?.toStringAsFixed(2) ?? '0.00'}",
                  ),
                  if (event.restrictions != null)
                    _buildInfoRow(
                      Icons.warning,
                      "Restrictions",
                      event.restrictions!,
                    ),
                  if (event.prizes != null)
                    _buildInfoRow(Icons.card_giftcard, "Prizes", event.prizes!),
                  if (event.format != null)
                    _buildInfoRow(Icons.category, "Format", event.format!),
                  const SizedBox(height: 6),
                  if (event.ctftimeUrl != null)
                    _buildInfoRow(Icons.link, "CTFTime", event.ctftimeUrl!),
                  if (event.url != null)
                    _buildInfoRow(Icons.link, "Official", event.url!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (event.description != null && event.description!.isNotEmpty) ...[
            Text("Description", style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              _stripHtml(event.description!),
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 16),
          if (event.organizers.isNotEmpty) _buildOrganizers(theme),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              icon: Icon(event.isReminderSet ? Icons.alarm_on : Icons.alarm),
              label: Text(
                event.isReminderSet ? 'Reminder Set' : 'Set Reminder',
              ),
              onPressed: () async {
                await controller.toggleReminderAndSync();
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.logo != null && event.logo!.isNotEmpty)
          CachedNetworkImage(
            imageUrl: event.logo!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (_, __, ___) =>
                const Icon(Icons.image_not_supported, size: 50),
          ),
        const SizedBox(height: 12),
        Text(
          event.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          event.format ?? "Unknown format",
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              "$title:",
              style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildOrganizers(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Organizers", style: theme.textTheme.titleMedium),
        const SizedBox(height: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: event.organizers
              .map(
                (org) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(org.name, style: theme.textTheme.bodyMedium),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "TBA";
    final local = date.toLocal();
    final df = DateFormat.yMMMd().add_jm();
    return df.format(local);
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
