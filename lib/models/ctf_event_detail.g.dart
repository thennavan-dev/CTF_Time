// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ctf_event_detail.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CtfEventDetailAdapter extends TypeAdapter<CtfEventDetail> {
  @override
  final int typeId = 1;

  @override
  CtfEventDetail read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CtfEventDetail(
      id: fields[0] as int,
      ctfId: fields[1] as int?,
      title: fields[2] as String,
      description: fields[3] as String?,
      url: fields[4] as String?,
      ctftimeUrl: fields[5] as String?,
      logo: fields[6] as String?,
      format: fields[7] as String?,
      formatId: fields[8] as int?,
      onsite: fields[9] as bool?,
      restrictions: fields[10] as String?,
      weight: fields[11] as double?,
      participants: fields[12] as int?,
      location: fields[13] as String?,
      liveFeed: fields[14] as String?,
      isVotableNow: fields[15] as bool?,
      publicVotable: fields[16] as bool?,
      prizes: fields[17] as String?,
      start: fields[18] as DateTime?,
      finish: fields[19] as DateTime?,
      durationSeconds: fields[20] as int?,
      organizers: (fields[21] as List).cast<Organizer>(),
      isReminderSet: fields[22] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CtfEventDetail obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ctfId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.ctftimeUrl)
      ..writeByte(6)
      ..write(obj.logo)
      ..writeByte(7)
      ..write(obj.format)
      ..writeByte(8)
      ..write(obj.formatId)
      ..writeByte(9)
      ..write(obj.onsite)
      ..writeByte(10)
      ..write(obj.restrictions)
      ..writeByte(11)
      ..write(obj.weight)
      ..writeByte(12)
      ..write(obj.participants)
      ..writeByte(13)
      ..write(obj.location)
      ..writeByte(14)
      ..write(obj.liveFeed)
      ..writeByte(15)
      ..write(obj.isVotableNow)
      ..writeByte(16)
      ..write(obj.publicVotable)
      ..writeByte(17)
      ..write(obj.prizes)
      ..writeByte(18)
      ..write(obj.start)
      ..writeByte(19)
      ..write(obj.finish)
      ..writeByte(20)
      ..write(obj.durationSeconds)
      ..writeByte(21)
      ..write(obj.organizers)
      ..writeByte(22)
      ..write(obj.isReminderSet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CtfEventDetailAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
