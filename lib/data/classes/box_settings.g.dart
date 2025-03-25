// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'box_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BoxSettingsAdapter extends TypeAdapter<BoxSettings> {
  @override
  final int typeId = 1;

  @override
  BoxSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoxSettings(
      boxName: fields[0] as String,
      lastUpdated: fields[2] as DateTime?,
    )
      .._syncLocation = fields[1] as String?
      .._showCompleted = fields[3] as bool
      .._selectAllCompleted = fields[4] as bool
      .._tags = (fields[5] as List?)?.cast<String>();
  }

  @override
  void write(BinaryWriter writer, BoxSettings obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.boxName)
      ..writeByte(1)
      ..write(obj._syncLocation)
      ..writeByte(2)
      ..write(obj.lastUpdated)
      ..writeByte(3)
      ..write(obj._showCompleted)
      ..writeByte(4)
      ..write(obj._selectAllCompleted)
      ..writeByte(5)
      ..write(obj._tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoxSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
