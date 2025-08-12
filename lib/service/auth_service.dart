import 'package:dio/dio.dart';

import '../model/signup_model.dart';

class AuthenticationService {
  Dio dio = Dio();
  late Response response;
  String baseUrl = 'https://alhekmah-server-side.onrender.com/auth/register';

  Future<void> register({required SignupModel user}) async {
    try {
      final response = await dio.post(
        baseUrl,
        data: user.toMap(),
      );
      print(response);
    } catch (e) {
      print(e);
    }
  }
}