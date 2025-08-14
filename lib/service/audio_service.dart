// // lib/service/hadith_upload_service.dart
//
// import 'dart:io';
// import 'package:dio/dio.dart';
//
// class HadithUploadService {
//   final Dio dio;
//
//   HadithUploadService({required this.dio});
//
//   Future<Map<String, dynamic>?> uploadHadithAudio({
//     required int hadithId,
//     required File audioFile,
//   }) async {
//     try {
//       final formData = FormData.fromMap({
//         'hadith_id': hadithId,
//         'file': await MultipartFile.fromFile(
//           audioFile.path,
//           filename: audioFile.path.split('/').last,
//         ),
//       });
//
//       final response = await dio.post(
//         '/audio/upload',
//         data: formData,
//         options: Options(
//           contentType: 'multipart/form-data',
//         ),
//       );
//
//       return response.data;
//     } on DioException {
//       // بدلاً من رمي استثناء، قم بإرجاع null.
//       return null;
//     } catch (e) {
//       // التعامل مع الأخطاء الأخرى بنفس الطريقة.
//       return null;
//     }
//   }
// }
// lib/service/hadith_upload_service.dart

import 'dart:io';
import 'package:dio/dio.dart';

class HadithUploadService {
  final Dio dio;

  HadithUploadService({required this.dio});

  Future<Map<String, dynamic>?> uploadHadithAudio({
    required int hadithId,
    required File audioFile,
  }) async {
    try {
      print("hi from api");
      final formData = FormData.fromMap({
        'hadith_id': hadithId,
        'file': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.path.split('/').last,
          contentType: DioMediaType("audio","mpeg"),
        ),
      });

      final response = await dio.post(
        '/audio/upload',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        return {'error': e.response!.data};
      }
      return {'error': 'حدث خطأ غير معروف في الاتصال: ${e.message}'};
    } catch (e) {
      return {'error': 'حدث خطأ غير متوقع: $e'};
    }
  }
}