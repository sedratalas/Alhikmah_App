import 'dart:async';
import 'dart:io';

import 'package:alhekmah_app/core/utils/color_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:string_similarity/string_similarity.dart';

part 'tasmiya_event.dart';
part 'tasmiya_state.dart';

class TasmiyaBloc extends Bloc<TasmiyaEvent, TasmiyaState> {
  final String targetMatn;
  final _audioRecorder = AudioRecorder();
  final _dio = Dio();
  final String _apiKey = '3455ca05d79d4e57b68f97b6138cefa5';

  String? _audioFilePath;
  // إضافة متغير لتخزين الـ Timer
  Timer? _timer;

  TasmiyaBloc({required this.targetMatn}) : super(TasmiyaInitial()) {
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<UpdateRecordingTimeEvent>(_onUpdateRecordingTime);
  }

  Future<void> _onStartRecording(StartRecordingEvent event, Emitter<TasmiyaState> emit) async {
    final hasPermission = await _requestPermissions();
    if (hasPermission) {
      final directory = await getApplicationDocumentsDirectory();
      _audioFilePath = '${directory.path}/recitation.m4a';
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _audioFilePath!,
      );
      // بدء الـ Timer وتحديث الحالة كل ثانية
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(const UpdateRecordingTimeEvent());
      });
      emit(const TasmiyaRecording());
    } else {
      emit(const TasmiyaError('الرجاء إعطاء إذن الوصول للميكروفون'));
    }
  }

  Future<void> _onStopRecording(StopRecordingEvent event, Emitter<TasmiyaState> emit) async {
    // إيقاف الـ Timer
    _timer?.cancel();
    await _audioRecorder.stop();
    emit(TasmiyaProcessing());
    if (_audioFilePath != null) {
      await _sendToAssemblyAI(File(_audioFilePath!));
    }
  }

  // دالة لمعالجة حدث تحديث الوقت
  void _onUpdateRecordingTime(UpdateRecordingTimeEvent event, Emitter<TasmiyaState> emit) {
    final currentState = state;
    if (currentState is TasmiyaRecording) {
      // قم بإصدار حالة جديدة مع زيادة الوقت بثانية واحدة
      emit(TasmiyaRecording(elapsedTimeInSeconds: currentState.elapsedTimeInSeconds + 1));
    }
  }

  Future<bool> _requestPermissions() async {
    var status = await Permission.microphone.request();
    return status.isGranted;
  }

  String normalizeArabic(String text) {
    text = text.replaceAll(RegExp(r'[\u064B-\u065F]'), '');
    text = text.replaceAll(RegExp(r'[أإآ]'), 'ا');
    text = text.replaceAll('ى', 'ي');
    text = text.replaceAll('ة', 'ه');
    text = text.replaceAll(RegExp(r'[.,:;؟!]'), '');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  void _compareWithHadith(String transcribedText) {
    List<String> originalWords = normalizeArabic(targetMatn).split(' ');
    List<String> transcribedWords = normalizeArabic(transcribedText).split(' ');

    List<Map<String, dynamic>> highlightedWords = [];

    for (int i = 0; i < transcribedWords.length; i++) {
      String transcribedWord = transcribedWords[i];
      bool isCorrect = false;

      if (i < originalWords.length) {
        String originalWord = originalWords[i];
        if (transcribedWord.similarityTo(originalWord) > 0.7) {
          isCorrect = true;
        }
      }

      highlightedWords.add({'text': transcribedWord, 'isCorrect': isCorrect});
    }

    double score = (highlightedWords.where((word) => word['isCorrect']).length / originalWords.length) * 100;

    if (score > 70) {
      emit(TasmiyaCompleted(highlightedText: highlightedWords, score: score));
    } else {
      emit(const TasmiyaError("نسبة التسميع غير كافية. يرجى المحاولة مرة أخرى."));
    }
  }

  Future<void> _sendToAssemblyAI(File audioFile) async {
    try {
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
          _compareWithHadith(pollingResponse.data['text']);
          return;
        } else if (status == 'error') {
          emit(const TasmiyaError('حدث خطأ أثناء التفريغ الصوتي.'));
          return;
        }
      }
    } catch (e) {
      emit(TasmiyaError('فشل إرسال التسجيل: $e'));
    }
  }

  @override
  Future<void> close() {
    _audioRecorder.dispose();
    _timer?.cancel(); // تأكد من إيقاف الـ Timer عند إغلاق الـ Bloc
    return super.close();
  }
}