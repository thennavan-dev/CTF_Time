import 'package:hive/hive.dart';

part 'organizer.g.dart';

@HiveType(typeId: 2)
class Organizer extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  Organizer({required this.id, required this.name});

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
