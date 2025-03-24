// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CompletionSettingsAdapter extends TypeAdapter<CompletionSettings> {
  @override
  final int typeId = 2;

  @override
  CompletionSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CompletionSettings(
      boxName: fields[0] as String,
    )
      .._showCompleted = fields[1] as bool
      .._selectAllCompleted = fields[2] as bool;
  }

  @override
  void write(BinaryWriter writer, CompletionSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.boxName)
      ..writeByte(1)
      ..write(obj._showCompleted)
      ..writeByte(2)
      ..write(obj._selectAllCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompletionSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
