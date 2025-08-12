// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standard_hadith_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HadithAdapter extends TypeAdapter<Hadith> {
  @override
  final int typeId = 1;

  @override
  Hadith read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Hadith(
      id: fields[0] as int,
      title: fields[1] as String,
      sanad: fields[2] as String?,
      matn: fields[3] as String?,
      content: fields[4] as String?,
      raawi: fields[5] as String?,
      bookId: fields[6] as int?,
      createdAt: fields[7] as DateTime?,
      updatedAt: fields[8] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, Hadith obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.sanad)
      ..writeByte(3)
      ..write(obj.matn)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.raawi)
      ..writeByte(6)
      ..write(obj.bookId)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
