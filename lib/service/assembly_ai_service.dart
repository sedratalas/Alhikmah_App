import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AssemblyAiService {
  final Dio _dio;
  final String _apiKey = '3455ca05d79d4e57b68f97b6138cefa5';

  AssemblyAiService({required Dio dio}) : _dio = dio;

  Future<Map<String, dynamic>> sendToAssemblyAI(File audioFile, String targetHadithMatn) async {
    try {
      print("hi from assemble");
      final uploadResponse = await _dio.post(
        'https://api.assemblyai.com/v2/upload',
        data: audioFile.openRead(),
        options: Options(
          headers: {'authorization': _apiKey},
          contentType: 'application/octet-stream',
        ),
      );
      final audioUrl = uploadResponse.data['upload_url'];

      final transcriptResponse = await _dio.post(
        'https://api.assemblyai.com/v2/transcript',
        data: {
          'audio_url': audioUrl,
          'language_code': 'ar',
          'auto_chapters': false,
        },
        options: Options(headers: {'authorization': _apiKey}),
      );

      final transcriptId = transcriptResponse.data['id'];
      String status = 'processing';

      while (status == 'processing' || status == 'queued') {
        await Future.delayed(const Duration(seconds: 3));
        final pollingResponse = await _dio.get(
          'https://api.assemblyai.com/v2/transcript/$transcriptId',
          options: Options(headers: {'authorization': _apiKey}),
        );

        status = pollingResponse.data['status'];

        if (status == 'completed') {
          final text = pollingResponse.data['text'];
          final matchResult = findClosestMatchWithScore(text, targetHadithMatn);
          final highlightedTexts = highlightMismatchedWords(text, targetHadithMatn);

          return {
            'transcription': text,
            'matchScore': matchResult?['score'],
            'highlightedOriginal': highlightedTexts['original'],
            'highlightedUserTranscription': highlightedTexts['transcription'],
            'status': 'completed',
          };
          print("hi from assemble");
        } else if (status == 'error') {
          return {
            'error': 'حدث خطأ أثناء التفريغ الصوتي.',
            'status': 'error',
          };
        }
      }
      return {'status': 'error'};
    } catch (e) {
      return {
        'error': 'فشل إرسال التسجيل: $e',
        'status': 'error',
      };
    }
  }

  String preprocessArabicText(String text) {
    text = text.replaceAll(RegExp(r'[أإآ]'), 'ا');
    text = text.replaceAll('ى', 'ي');
    text = text.replaceAll('ة', 'ه');
    text = text.replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '');
    text = text.replaceAll(RegExp(r'[؟،.؛:!"]'), '');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  Map<String, dynamic>? findClosestMatchWithScore(String input, String targetMatn) {
    final cleanedInput = preprocessArabicText(input);
    final cleanedTargetMatn = preprocessArabicText(targetMatn);

    if (cleanedTargetMatn.isEmpty) {
      return null;
    }

    final distance = levenshtein(cleanedInput, cleanedTargetMatn);
    int maxLength = cleanedTargetMatn.length > cleanedInput.length ? cleanedTargetMatn.length : cleanedInput.length;
    if (maxLength == 0) {
      return {
        'match': targetMatn,
        'score': '0.00',
      };
    }

    double similarity = 1 - (distance / maxLength);
    double percentage = similarity * 100;

    return {
      'match': targetMatn,
      'score': percentage.toStringAsFixed(2),
    };
  }

  int levenshtein(String s1, String s2) {
    List<List<int>> dp = List.generate(
      s1.length + 1,
          (_) => List.filled(s2.length + 1, 0),
    );

    for (int i = 0; i <= s1.length; i++) dp[i][0] = i;
    for (int j = 0; j <= s2.length; j++) dp[0][j] = j;

    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return dp[s1.length][s2.length];
  }

  Map<String, List<TextSpan>> highlightMismatchedWords(String input, String targetMatn) {
    final inputWords = preprocessArabicText(input).split(' ');
    final targetWords = preprocessArabicText(targetMatn).split(' ');
    final originalTargetWords = targetMatn.split(' ');
    final originalInputWords = input.split(' ');

    List<TextSpan> originalSpans = [];
    List<TextSpan> transcriptionSpans = [];

    for (int i = 0; i < targetWords.length; i++) {
      final targetWord = targetWords[i];
      final originalTargetWord = originalTargetWords.length > i ? originalTargetWords[i] : '';

      bool isMatched = false;
      String currentInputWord = '';
      String originalCurrentInputWord = '';

      if (i < inputWords.length) {
        currentInputWord = inputWords[i];
        originalCurrentInputWord = originalInputWords[i];

        final distance = levenshtein(currentInputWord, targetWord);
        final similarity = 1 - (distance / (currentInputWord.length > targetWord.length ? currentInputWord.length : targetWord.length));

        if (similarity > 0.8) {
          isMatched = true;
        }
      }

      originalSpans.add(
        TextSpan(
          text: '$originalTargetWord ',
          style: TextStyle(
            color: isMatched ? Colors.black : Colors.red,
          ),
        ),
      );

      transcriptionSpans.add(
        TextSpan(
          text: '$originalCurrentInputWord ',
          style: TextStyle(
            color: isMatched ? Colors.black : Colors.red,
          ),
        ),
      );
    }
    return {'original': originalSpans, 'transcription': transcriptionSpans};
  }
}