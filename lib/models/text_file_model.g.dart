// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_file_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TextFileAdapter extends TypeAdapter<TextFile> {
  @override
  final int typeId = 0;

  @override
  TextFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TextFile(
      id: fields[0] as String,
      icerik: fields[1] as String,
      timeCreated: fields[2] as DateTime,
      targetLanguage: fields[3] as String,
      textLanguage: fields[4] as String,
      title: fields[5] as String,
      offset: fields[6] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TextFile obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.icerik)
      ..writeByte(2)
      ..write(obj.timeCreated)
      ..writeByte(3)
      ..write(obj.targetLanguage)
      ..writeByte(4)
      ..write(obj.textLanguage)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.offset);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
