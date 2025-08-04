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
      start: fields[2] as String,
      finish: fields[3] as String,
      url: fields[4] as String,
      ctftimeUrl: fields[5] as String,
      format: fields[6] as String,
      onsite: fields[7] as bool,
      location: fields[8] as String,
      logo: fields[9] as String?,
      description: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CtfEvent obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.start)
      ..writeByte(3)
      ..write(obj.finish)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.ctftimeUrl)
      ..writeByte(6)
      ..write(obj.format)
      ..writeByte(7)
      ..write(obj.onsite)
      ..writeByte(8)
      ..write(obj.location)
      ..writeByte(9)
      ..write(obj.logo)
      ..writeByte(10)
      ..write(obj.description);
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
