import 'package:dio/dio.dart';

import '../model/login_model.dart';
import '../model/signup_model.dart';
import '../model/token_model.dart';

class AuthenticationService {
  Dio dio = Dio();
  late Response response;
  String baseUrl = 'https://alhekmah-server-side.onrender.com/auth/';

  Future<void> register({required SignupModel user}) async {
    try {
      final response = await dio.post(
        baseUrl+"register",
        data: user.toMap(),
      );
      print(response);
    } catch (e) {
      print(e);
    }
  }

  Future<TokenResponseModel> login({required LoginRequestModel user}) async {
    try {
      final response = await dio.post(baseUrl+"login", data: user.toMap());
      return TokenResponseModel.fromMap(response.data);
    } catch (e) {
      throw Exception("فشل في تسجيل الدخول: $e");
    }
  }

  Future<TokenResponseModel> refreshToken({required String refreshToken}) async {
    try {
      final response = await dio.post(
        baseUrl+"refresh",
        data: {"refresh_token": refreshToken},
      );
      return TokenResponseModel.fromMap(response.data);
    } catch (e) {
      throw Exception("فشل في تجديد التوكن: $e");
    }
  }
}