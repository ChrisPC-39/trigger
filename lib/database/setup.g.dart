// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SetupAdapter extends TypeAdapter<Setup> {
  @override
  final int typeId = 0;

  @override
  Setup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Setup(
      isFirstTime: fields[0] as bool,
      isSystemThemeSelected: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Setup obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.isFirstTime)
      ..writeByte(1)
      ..write(obj.isSystemThemeSelected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
