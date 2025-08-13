import 'package:alhekmah_app/model/audio_model.dart';
import 'package:dio/dio.dart';

class AudioService{
  final Dio dio;
  AudioService({required this.dio});
  late Response response;
  String baseUrl = "/audio/";

  Future<AudioModel?> uploadAudio()async{

  }
}