// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_configuration.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TabConfigurationAdapter extends TypeAdapter<TabConfiguration> {
  @override
  final int typeId = 2;

  @override
  TabConfiguration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TabConfiguration(
      title: fields[0] as String,
      itemType: fields[1] as String,
    )
      .._iconCodePoint = fields[2] as int
      .._hasCount = fields[3] as bool
      .._moveTo = fields[4] as String?
      .._sort = fields[6] as int?
      .._fontFamily = fields[7] as String?;
  }

  @override
  void write(BinaryWriter writer, TabConfiguration obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.itemType)
      ..writeByte(2)
      ..write(obj._iconCodePoint)
      ..writeByte(3)
      ..write(obj._hasCount)
      ..writeByte(4)
      ..write(obj._moveTo)
      ..writeByte(6)
      ..write(obj._sort)
      ..writeByte(7)
      ..write(obj._fontFamily);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabConfigurationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
