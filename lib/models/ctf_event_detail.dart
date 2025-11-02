import 'package:hive/hive.dart';
import 'organizer.dart';

part 'ctf_event_detail.g.dart';

@HiveType(typeId: 1)
class CtfEventDetail extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int? ctfId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String? url;

  @HiveField(5)
  final String? ctftimeUrl;

  @HiveField(6)
  final String? logo;

  @HiveField(7)
  final String? format;

  @HiveField(8)
  final int? formatId;

  @HiveField(9)
  final bool? onsite;

  @HiveField(10)
  final String? restrictions;

  @HiveField(11)
  final double? weight;

  @HiveField(12)
  final int? participants;

  @HiveField(13)
  final String? location;

  @HiveField(14)
  final String? liveFeed;

  @HiveField(15)
  final bool? isVotableNow;

  @HiveField(16)
  final bool? publicVotable;

  @HiveField(17)
  final String? prizes;

  @HiveField(18)
  final DateTime? start;

  @HiveField(19)
  final DateTime? finish;

  @HiveField(20)
  final int? durationSeconds;

  @HiveField(21)
  final List<Organizer> organizers;

  @HiveField(22)
  bool isReminderSet;

  CtfEventDetail({
    required this.id,
    this.ctfId,
    required this.title,
    this.description,
    this.url,
    this.ctftimeUrl,
    this.logo,
    this.format,
    this.formatId,
    this.onsite,
    this.restrictions,
    this.weight,
    this.participants,
    this.location,
    this.liveFeed,
    this.isVotableNow,
    this.publicVotable,
    this.prizes,
    this.start,
    this.finish,
    this.durationSeconds,
    required this.organizers,
    this.isReminderSet = false,
  });

  factory CtfEventDetail.fromJson(Map<String, dynamic> json) {
    return CtfEventDetail(
      id: json['id'] ?? 0,
      ctfId: json['ctf_id'],
      title: json['title'] ?? '',
      description: json['description'],
      url: json['url'],
      ctftimeUrl: json['ctftime_url'],
      logo: json['logo'],
      format: json['format'],
      formatId: json['format_id'],
      onsite: json['onsite'],
      restrictions: json['restrictions'],
      weight: (json['weight'] as num?)?.toDouble(),
      participants: json['participants'],
      location: json['location'],
      liveFeed: json['live_feed'],
      isVotableNow: json['is_votable_now'],
      publicVotable: json['public_votable'],
      prizes: json['prizes'],
      start: json['start'] != null ? DateTime.parse(json['start']) : null,
      finish: json['finish'] != null ? DateTime.parse(json['finish']) : null,
      durationSeconds: json['duration'] != null
          ? (((json['duration']['days'] ?? 0) as int) * 24 +
                    ((json['duration']['hours'] ?? 0) as int)) *
                3600
          : null,
      organizers: json['organizers'] != null
          ? (json['organizers'] as List)
                .map((e) => Organizer.fromJson(e))
                .toList()
          : [],
      isReminderSet: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ctf_id': ctfId,
      'title': title,
      'description': description,
      'url': url,
      'ctftime_url': ctftimeUrl,
      'logo': logo,
      'format': format,
      'format_id': formatId,
      'onsite': onsite,
      'restrictions': restrictions,
      'weight': weight,
      'participants': participants,
      'location': location,
      'live_feed': liveFeed,
      'is_votable_now': isVotableNow,
      'public_votable': publicVotable,
      'prizes': prizes,
      'start': start?.toIso8601String(),
      'finish': finish?.toIso8601String(),
      'duration': durationSeconds != null
          ? {
              'days': durationSeconds! ~/ 86400,
              'hours': (durationSeconds! % 86400) ~/ 3600,
            }
          : null,
      'organizers': organizers.map((e) => e.toJson()).toList(),
      'isReminderSet': isReminderSet,
    };
  }
}
