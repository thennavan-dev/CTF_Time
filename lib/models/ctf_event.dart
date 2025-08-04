import 'package:hive/hive.dart';

part 'ctf_event.g.dart';

@HiveType(typeId: 0)
class CtfEvent extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String start;

  @HiveField(3)
  final String finish;

  @HiveField(4)
  final String url;

  @HiveField(5)
  final String ctftimeUrl;

  @HiveField(6)
  final String format;

  @HiveField(7)
  final bool onsite;

  @HiveField(8)
  final String location;

  @HiveField(9)
  final String? logo;

  @HiveField(10)
  final String description;

  CtfEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.finish,
    required this.url,
    required this.ctftimeUrl,
    required this.format,
    required this.onsite,
    required this.location,
    this.logo,
    required this.description,
  });

  factory CtfEvent.fromJson(Map<String, dynamic> json) {
    return CtfEvent(
      id: json['id'],
      title: json['title'] ?? 'Unknown CTF',
      start: json['start'] ?? '',
      finish: json['finish'] ?? '',
      url: json['url'] ?? '',
      ctftimeUrl: json['ctftime_url'] ?? '',
      format: json['format'] ?? 'Unknown',
      onsite: json['onsite'] ?? false,
      location: json['location'] ?? (json['onsite'] == true ? 'Unknown' : 'Online'),
      logo: json['logo'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'start': start,
    'finish': finish,
    'url': url,
    'ctftime_url': ctftimeUrl,
    'format': format,
    'onsite': onsite,
    'location': location,
    'logo': logo,
    'description': description,
  };
}