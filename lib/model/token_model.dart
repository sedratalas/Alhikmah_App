import 'package:hive/hive.dart';

part 'token_model.g.dart';

@HiveType(typeId: 0)
class TokenResponseModel extends HiveObject {
  @HiveField(0)
  final String accessToken;
  @HiveField(1)
  final String refreshToken;
  @HiveField(2)
  final String tokenType;

  TokenResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory TokenResponseModel.fromMap(Map<String, dynamic> map) {
    return TokenResponseModel(
      accessToken: map['access_token'] as String,
      refreshToken: map['refresh_token'] as String,
      tokenType: map['token_type'] as String,
    );
  }
}