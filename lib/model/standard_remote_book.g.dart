// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'standard_remote_book.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RemotBookAdapter extends TypeAdapter<RemotBook> {
  @override
  final int typeId = 2;

  @override
  RemotBook read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RemotBook(
      title: fields[0] as String,
      description: fields[1] as String,
      author: fields[2] as String,
      id: fields[3] as int,
      createdAt: fields[4] as DateTime?,
      updatedAt: fields[5] as dynamic,
      hadiths: (fields[6] as List).cast<Hadith>(),
    );
  }

  @override
  void write(BinaryWriter writer, RemotBook obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt)
      ..writeByte(6)
      ..write(obj.hadiths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemotBookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
