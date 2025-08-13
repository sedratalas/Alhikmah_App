import 'package:alhekmah_app/model/profile_model.dart';
import 'package:alhekmah_app/model/scores_model.dart';
import 'package:alhekmah_app/model/wallet_model.dart';
import 'package:dio/dio.dart';

class ProfileService {
  final Dio dio;

  ProfileService({required this.dio});

  late Response response;
  String baseUrl = 'user/';

  Future<ProfileModel?> getProfile() async {
    try {
      print("hi from profile");
      response = await dio.get(baseUrl+"profile");
      return ProfileModel.fromMap(response.data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<WalletModel?> getWallet() async {
    try {
      print("hi from wallet");
      response = await dio.get(baseUrl+"wallet");
      return WalletModel.fromMap(response.data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<ScoresModel>> getAllBooks()async{
    try{
      response = await dio.get(baseUrl);
      List<ScoresModel> scores = [];
      for(int i=0; i< response.data.length ;i++){
        scores.add(ScoresModel.fromJson(response.data[i]));
      }
      return scores;
    }catch(e){
      throw Exception("فشل جلب النقاط من السيرفر: $e");
    }
  }
}