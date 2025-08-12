// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TokenResponseModelAdapter extends TypeAdapter<TokenResponseModel> {
  @override
  final int typeId = 0;

  @override
  TokenResponseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TokenResponseModel(
      accessToken: fields[0] as String,
      refreshToken: fields[1] as String,
      tokenType: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TokenResponseModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(1)
      ..write(obj.refreshToken)
      ..writeByte(2)
      ..write(obj.tokenType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenResponseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
