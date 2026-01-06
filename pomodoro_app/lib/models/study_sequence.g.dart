// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_sequence.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StudySequenceAdapter extends TypeAdapter<StudySequence> {
  @override
  final int typeId = 1;

  @override
  StudySequence read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StudySequence(
      id: fields[0] as int?,
      name: fields[1] as String,
      waves: (fields[2] as List).cast<StudyWave>(),
      isDefault: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, StudySequence obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.waves)
      ..writeByte(3)
      ..write(obj.isDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudySequenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
