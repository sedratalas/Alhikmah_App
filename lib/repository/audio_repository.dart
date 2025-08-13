//
//
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:logger/logger.dart'; // ستحتاج إلى إضافة هذه المكتبة
//
// import '../service/assembly_ai_service.dart';
// import '../service/audio_service.dart';
//
//
// class HadithProcessingResult {
//   final Map<String, dynamic>? data;
//   final String? error;
//
//   HadithProcessingResult({this.data, this.error});
// }
//
// class HadithRepository {
//   final HadithUploadService uploadService;
//   final AssemblyAiService assemblyAiService;
//   final Logger _logger = Logger();
//
//   HadithRepository({required this.uploadService, required this.assemblyAiService});
//
//   Future<HadithProcessingResult> processHadithAudio({
//     required int hadithId,
//     required File audioFile,
//     required String targetHadithMatn,
//   }) async {
//     final connectivityResult = await (Connectivity().checkConnectivity());
//
//     if (connectivityResult == ConnectivityResult.none) {
//       return HadithProcessingResult(error: "لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى.");
//     }
//
//     final apiResponse = await uploadService.uploadHadithAudio(
//       hadithId: hadithId,
//       audioFile: audioFile,
//     );
//
//     if (apiResponse != null && !apiResponse.containsKey('error')) {
//       // إذا كانت النتيجة لا تحتوي على خطأ، يعني أن العملية نجحت
//       return HadithProcessingResult(data: apiResponse);
//     } else {
//       // إذا كانت النتيجة تحتوي على خطأ، قم بتسجيله
//       if (apiResponse != null && apiResponse.containsKey('error')) {
//         _logger.e("Server Error: ${apiResponse['error']}");
//       } else {
//         _logger.e("Unknown API failure, response was null.");
//       }
//
//       // بعد تسجيل الخطأ، قم بتفعيل الحل البديل
//       print("Starting AssemblyAI fallback...");
//       try {
//         final fallbackResult = await assemblyAiService.sendToAssemblyAI(audioFile, targetHadithMatn);
//         return HadithProcessingResult(data: fallbackResult);
//       } catch (fallbackError) {
//         _logger.e("AssemblyAI Fallback Error: $fallbackError");
//         return HadithProcessingResult(error: "فشل التفريغ الصوتي. يرجى المحاولة لاحقاً.");
//       }
//     }
//   }
// }
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';

import '../service/assembly_ai_service.dart';
import '../service/audio_service.dart';


class HadithProcessingResult {
  final Map<String, dynamic>? data;
  final String? error;

  HadithProcessingResult({this.data, this.error});
}

class HadithRepository {
  final HadithUploadService uploadService;
  final AssemblyAiService assemblyAiService;
  final Logger _logger = Logger();

  HadithRepository({required this.uploadService, required this.assemblyAiService});

  Future<HadithProcessingResult> processHadithAudio({
    required int hadithId,
    required File audioFile,
    required String targetHadithMatn,
  }) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      return HadithProcessingResult(error: "لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى.");
    }

    final apiResponse = await uploadService.uploadHadithAudio(
      hadithId: hadithId,
      audioFile: audioFile,
    );

    if (apiResponse != null && !apiResponse.containsKey('error')) {
      final String transcription = apiResponse['transcription'] as String;

      final matchResult = assemblyAiService.findClosestMatchWithScore(transcription, targetHadithMatn);
      final highlightedTexts = assemblyAiService.highlightMismatchedWords(transcription, targetHadithMatn);

      final processedResult = {
        'transcription': transcription,
        'matchScore': matchResult?['score'],
        'highlightedOriginal': highlightedTexts['original'],
        'highlightedUserTranscription': highlightedTexts['transcription'],
        'status': 'completed',
      };

      return HadithProcessingResult(data: processedResult);

    } else {
      if (apiResponse != null && apiResponse.containsKey('error')) {
        _logger.e("Server Error: ${apiResponse['error']}");
      } else {
        _logger.e("Unknown API failure, response was null.");
      }

      try {
        final fallbackResult = await assemblyAiService.sendToAssemblyAI(audioFile, targetHadithMatn);
        return HadithProcessingResult(data: fallbackResult);
      } catch (fallbackError) {
        _logger.e("AssemblyAI Fallback Error: $fallbackError");
        return HadithProcessingResult(error: "فشل التفريغ الصوتي. يرجى المحاولة لاحقاً.");
      }
    }
  }
}