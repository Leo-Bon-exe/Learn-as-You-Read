// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_file_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WordFileAdapter extends TypeAdapter<WordFile> {
  @override
  final int typeId = 1;

  @override
  WordFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WordFile(
      id: fields[0] as String,
      word: fields[1] as String,
      wordExplanation: fields[2] as String,
      timeCreated: fields[3] as DateTime,
      targetLanguage: fields[4] as String,
      wordLanguage: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WordFile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.word)
      ..writeByte(2)
      ..write(obj.wordExplanation)
      ..writeByte(3)
      ..write(obj.timeCreated)
      ..writeByte(4)
      ..write(obj.targetLanguage)
      ..writeByte(5)
      ..write(obj.wordLanguage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
