// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ctf_event.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CtfEventAdapter extends TypeAdapter<CtfEvent> {
  @override
  final int typeId = 0;

  @override
  CtfEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CtfEvent(
      id: fields[0] as int,
      title: fields[1] as String,
      description: fields[2] as String?,
      url: fields[3] as String?,
      ctftimeUrl: fields[4] as String?,
      logo: fields[5] as String?,
      format: fields[6] as String?,
      formatId: fields[7] as int?,
      onsite: fields[8] as bool?,
      restrictions: fields[9] as String?,
      weight: fields[10] as double?,
      participants: fields[11] as int?,
      location: fields[12] as String?,
      liveFeed: fields[13] as String?,
      isVotableNow: fields[14] as bool?,
      publicVotable: fields[15] as bool?,
      prizes: fields[16] as String?,
      start: fields[17] as DateTime?,
      finish: fields[18] as DateTime?,
      durationSeconds: fields[19] as int?,
      organizers: (fields[20] as List).cast<Organizer>(),
      reminder: fields[21] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CtfEvent obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.ctftimeUrl)
      ..writeByte(5)
      ..write(obj.logo)
      ..writeByte(6)
      ..write(obj.format)
      ..writeByte(7)
      ..write(obj.formatId)
      ..writeByte(8)
      ..write(obj.onsite)
      ..writeByte(9)
      ..write(obj.restrictions)
      ..writeByte(10)
      ..write(obj.weight)
      ..writeByte(11)
      ..write(obj.participants)
      ..writeByte(12)
      ..write(obj.location)
      ..writeByte(13)
      ..write(obj.liveFeed)
      ..writeByte(14)
      ..write(obj.isVotableNow)
      ..writeByte(15)
      ..write(obj.publicVotable)
      ..writeByte(16)
      ..write(obj.prizes)
      ..writeByte(17)
      ..write(obj.start)
      ..writeByte(18)
      ..write(obj.finish)
      ..writeByte(19)
      ..write(obj.durationSeconds)
      ..writeByte(20)
      ..write(obj.organizers)
      ..writeByte(21)
      ..write(obj.reminder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CtfEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
