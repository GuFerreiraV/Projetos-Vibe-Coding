// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_wave.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudyWaveAdapter extends TypeAdapter<StudyWave> {
  @override
  final int typeId = 2;

  @override
  StudyWave read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudyWave(
      workDuration: fields[0] as int,
      breakDuration: fields[1] as int,
      name: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, StudyWave obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.workDuration)
      ..writeByte(1)
      ..write(obj.breakDuration)
      ..writeByte(2)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudyWaveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
