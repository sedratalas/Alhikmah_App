import 'dart:io';
import 'dart:async';
import 'package:alhekmah_app/core/utils/asset_manager.dart';
import 'package:alhekmah_app/core/utils/color_manager.dart';
import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_bloc.dart';
import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'bloc/hadith_event.dart';

class HadethRecitationScreen extends StatefulWidget {
  HadethRecitationScreen({super.key});

  @override
  State<HadethRecitationScreen> createState() => _HadethRecitationScreenState();
}

class _HadethRecitationScreenState extends State<HadethRecitationScreen> {
  late double screenWidth;
  late double screenHeight;
  final _audioRecorder = AudioRecorder();
  final Dio _dio = Dio();
  final String _apiKey = '3455ca05d79d4e57b68f97b6138cefa5';
  bool _isRecording = false;
  String? _audioFilePath;
  String? _transcription;
  String? _matchScore;
  bool _isProcessingTranscription = false;
  int _elapsedTimeInSeconds = 0;
  Timer? _timer;
  List<TextSpan> _highlightedOriginal = [];
  List<TextSpan> _highlightedUserTranscription = [];

  Future<bool> _requestPermissions() async {
    var status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startRecording() async {
    final hasPermission = await _requestPermissions();
    if (hasPermission) {
      final directory = await getApplicationDocumentsDirectory();
      _audioFilePath = '${directory.path}/recitation.m4a';
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _audioFilePath!,
      );
      setState(() {
        _isRecording = true;
        _transcription = null;
        _matchScore = null;
        _isProcessingTranscription = false;
        _elapsedTimeInSeconds = 0;
        _highlightedOriginal = [];
        _highlightedUserTranscription = [];
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _elapsedTimeInSeconds++;
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إعطاء إذن الوصول للميكروفون')),
      );
    }
  }

  Future<void> _stopRecording(String targetHadithMatn) async {
    await _audioRecorder.stop();
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _isProcessingTranscription = true;
    });
    if (_audioFilePath != null) {
      await _sendToAssemblyAI(File(_audioFilePath!), targetHadithMatn);
    }
  }

  Future<void> _sendToAssemblyAI(File audioFile, String targetHadithMatn) async {
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
          final text = pollingResponse.data['text'];
          final matchResult = findClosestMatchWithScore(text, targetHadithMatn);
          final highlightedTexts = highlightMismatchedWords(text, targetHadithMatn);

          setState(() {
            _transcription = text;
            _highlightedOriginal = highlightedTexts['original']!;
            _highlightedUserTranscription = highlightedTexts['transcription']!;

            if (matchResult != null) {
              _matchScore = matchResult['score'];
            } else {
              _matchScore = null;
            }
            _isProcessingTranscription = false;
          });
        } else if (status == 'error') {
          setState(() {
            _transcription = 'حدث خطأ أثناء التفريغ الصوتي.';
            _isProcessingTranscription = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _transcription = 'فشل إرسال التسجيل: $e';
        _isProcessingTranscription = false;
      });
    }
  }

  String preprocessArabicText(String text) {
    text = text.replaceAll(RegExp(r'[أإآ]'), 'ا');
    text = text.replaceAll('ى', 'ي');
    text = text.replaceAll('ة', 'ه');
    text = text.replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '');
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

    // مقارنة بسيطة: قارن كلمة بكلمة
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
          style: const TextStyle(
            color: AppColors.black,
          ),
        ),
      );

      transcriptionSpans.add(
        TextSpan(
          text: '$originalCurrentInputWord ',
          style: TextStyle(
            color: isMatched ? AppColors.black : Colors.red,
          ),
        ),
      );
    }
    return {'original': originalSpans, 'transcription': transcriptionSpans};
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Widget buildResultButton() {
    if (_isProcessingTranscription) {
      return Container(
        width: screenWidth * (160 / 390),
        height: screenHeight * (40 / 844),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    } else if (_matchScore != null) {
      return GestureDetector(
        onTap: () {},
        child: Container(
          width: screenWidth * (160 / 390),
          height: screenHeight * (40 / 844),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF09A3BA),
                Color(0xFF92D2DC),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              'النتيجة: ($_matchScore%)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: "Cairo",
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(
        width: screenWidth * (160 / 390),
        height: screenHeight * (40 / 844),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            "عرض النتيجة",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              fontFamily: "Cairo",
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
    return BlocBuilder<HadithBloc, HadithState>(
      builder: (context, state) {
        if (state is HadithLoadingState) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is HadithLoadedState) {
          final currentHadith = state.currentHadith;
          final currentIndex = state.currentHadithIndex;
          final hadithBloc = context.read<HadithBloc>();
          final ahadithListLength = hadithBloc.ahadithList.length;

          return Scaffold(
            backgroundColor: AppColors.lightBackground,
            appBar: AppBar(
              backgroundColor: AppColors.primaryBlue,
              title: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  state.currentHadith.title,
                ),
              ),
              titleTextStyle: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, fontFamily: "Cairo"),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: screenWidth * (30 / 390)),
                  child: Image.asset(AssetManager.profile),
                ),
              ],
            ),
            body: Stack(
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            right: screenWidth * (29 / 390),
                            left: screenWidth * (29 / 390),
                            top: screenWidth * (31 / 390)),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showWarningDialog(context);
                              },
                              child: Image.asset(AssetManager.website),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  right: screenWidth * (8 / 390),
                                  left: screenWidth * (66 / 390)),
                              child: const Text(
                                "سمّع الحديث النبوي !",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "Almarai",
                                  color: AppColors.gray,
                                ),
                              ),
                            ),
                            Container(
                              width: screenWidth * (74 / 390),
                              height: screenHeight * (35 / 844),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "500",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: "Cairo",
                                          color: AppColors.orange),
                                    ),
                                    Image.asset(AssetManager.feather),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: screenHeight * (23 / 844),
                            bottom: screenHeight * (11 / 844),
                            left: screenWidth * (14 / 390),
                            right: screenWidth * (14 / 390)),
                        child: Container(
                          width: screenWidth * (362 / 390),
                          height: screenHeight * (60 / 844),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            state.currentHadith.sanad,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              fontFamily: "Aladin",
                              color: AppColors.green,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: screenWidth * (14 / 390),
                            right: screenWidth * (14 / 390)),
                        child: Container(
                          width: screenWidth * (362 / 390),
                          height: screenHeight * (324 / 844),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Color(0xffE2E2E2),
                                  Colors.white
                                ]
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(15),
                          child: SingleChildScrollView(
                            child: _transcription != null
                                ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'النص الأصلي:',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    fontFamily: "Almarai",
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18,
                                      fontFamily: "Aladin",
                                      color: AppColors.black,
                                    ),
                                    children: _highlightedOriginal,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'تسميعك:',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    fontFamily: "Almarai",
                                    color: AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 18,
                                      fontFamily: "Aladin",
                                      color: AppColors.black,
                                    ),
                                    children: _highlightedUserTranscription,
                                  ),
                                ),
                              ],
                            )
                                : Text(
                              state.currentHadith.matn,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                                fontFamily: "Aladin",
                                color: AppColors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: screenHeight * (37 / 844),
                          bottom: screenHeight * (90 / 844),
                          right: screenWidth*(30/390),
                          left: screenWidth*(200/390),
                        ),
                        child: buildResultButton(),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: const Color(0xff088395),
                    iconSize: 16,
                    selectedItemColor: Colors.white,
                    unselectedItemColor: Colors.white,
                    showSelectedLabels: true,
                    showUnselectedLabels: true,
                    selectedLabelStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: const TextStyle(fontSize: 12),
                    items: [
                      BottomNavigationBarItem(
                        icon: GestureDetector(
                            onTap: currentIndex > 0
                                ? () {
                              setState(() {
                                _transcription = null;
                                _matchScore = null;
                                _highlightedOriginal = [];
                                _highlightedUserTranscription = [];
                              });
                              hadithBloc.add(const PreviousHadithEvent());
                            }
                                : null,
                            child: const Icon(Icons.arrow_back_ios)),
                        label: 'السابق',
                        backgroundColor: const Color(0xff076A78),
                      ),
                      const BottomNavigationBarItem(
                        icon: Icon(Icons.headphones),
                        label: 'استماع',
                      ),
                      BottomNavigationBarItem(
                        icon: GestureDetector(
                          onTap: () {
                            if (_isRecording) {
                              _stopRecording(currentHadith.matn);
                            } else {
                              _startRecording();
                            }
                          },
                          child: const Icon(Icons.mic),
                        ),
                        label: _isRecording ? 'إيقاف' : "تسميع",
                      ),
                      BottomNavigationBarItem(
                        icon: GestureDetector(
                            onTap: currentIndex < ahadithListLength - 1
                                ? () {
                              setState(() {
                                _transcription = null;
                                _matchScore = null;
                                _highlightedOriginal = [];
                                _highlightedUserTranscription = [];
                              });
                              hadithBloc.add(const NextHadithEvent());
                            }
                                : null,
                            child: const Icon(Icons.arrow_forward_ios)),
                        label: 'التالي',
                      ),
                    ],
                  ),
                ),
                if (_isRecording || _isProcessingTranscription)
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: screenWidth,
                      height: screenHeight * (43 / 840),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.babyBlue,
                              Colors.white,
                            ]
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * (43 / 390),
                          vertical: screenHeight * 0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatTime(_elapsedTimeInSeconds),
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 16,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: screenHeight * 0.04,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Image.asset(AssetManager.wave),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.circle,
                            color: Colors.red,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        } else if (state is HadithErrorState) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          );
        }
        return const Scaffold(body: Center(child: Text('خطأ غير معروف')));
      },
    );
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: const Text(
              'تنويه !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Cairo",
                fontWeight: FontWeight.w400,
                fontSize: 20,
                color: AppColors.primaryBlue,
              ),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'قد يرد في هذا الحديث مفردات\nلها عدة قراءات',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Aladin",
                    color: AppColors.gray,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'يرجى الاستماع للحديث',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Aladin",
                    color: AppColors.gray,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Column(
                    children: [
                      Divider(
                        color: AppColors.gray,
                      ),
                      SizedBox(height: 10,),
                      Text(
                        'استماع',
                        style: TextStyle(
                            color: Color(0xff442B0D),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Cairo"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
//without mistake

// import 'dart:io';
// import 'dart:async';
//
// import 'package:alhekmah_app/core/utils/asset_manager.dart';
// import 'package:alhekmah_app/core/utils/color_manager.dart';
// import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_bloc.dart';
// import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_state.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart';
// import 'bloc/hadith_event.dart';
//
// class HadethRecitationScreen extends StatefulWidget {
//   HadethRecitationScreen({super.key});
//
//   @override
//   State<HadethRecitationScreen> createState() => _HadethRecitationScreenState();
// }
//
// class _HadethRecitationScreenState extends State<HadethRecitationScreen> {
//   late double screenWidth;
//   late double screenHeight;
//   final _audioRecorder = AudioRecorder();
//   final Dio _dio = Dio();
//   final String _apiKey = '3455ca05d79d4e57b68f97b6138cefa5';
//   bool _isRecording = false;
//   String? _audioFilePath;
//   String? _transcription;
//   String? _matchedHadith;
//   String? _matchScore;
//   bool _isProcessingTranscription = false;
//   int _elapsedTimeInSeconds = 0;
//   Timer? _timer;
//
//   Future<bool> _requestPermissions() async {
//     var status = await Permission.microphone.request();
//     return status.isGranted;
//   }
//
//   Future<void> _startRecording() async {
//     final hasPermission = await _requestPermissions();
//     if (hasPermission) {
//       final directory = await getApplicationDocumentsDirectory();
//       _audioFilePath = '${directory.path}/recitation.m4a';
//       await _audioRecorder.start(
//         const RecordConfig(encoder: AudioEncoder.aacLc),
//         path: _audioFilePath!,
//       );
//       setState(() {
//         _isRecording = true;
//         _transcription = null;
//         _matchedHadith = null;
//         _matchScore = null;
//         _isProcessingTranscription = false;
//         _elapsedTimeInSeconds = 0;
//       });
//       _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//         setState(() {
//           _elapsedTimeInSeconds++;
//         });
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('الرجاء إعطاء إذن الوصول للميكروفون')),
//       );
//     }
//   }
//
//   Future<void> _stopRecording(String targetHadithMatn) async {
//     await _audioRecorder.stop();
//     _timer?.cancel();
//     setState(() {
//       _isRecording = false;
//       _isProcessingTranscription = true;
//     });
//     if (_audioFilePath != null) {
//       await _sendToAssemblyAI(File(_audioFilePath!), targetHadithMatn);
//     }
//   }
//
//   Future<void> _sendToAssemblyAI(File audioFile, String targetHadithMatn) async {
//     try {
//       final uploadResponse = await _dio.post(
//         'https://api.assemblyai.com/v2/upload',
//         data: audioFile.openRead(),
//         options: Options(
//           headers: {'authorization': _apiKey},
//           contentType: 'application/octet-stream',
//         ),
//       );
//       final audioUrl = uploadResponse.data['upload_url'];
//
//       final transcriptResponse = await _dio.post(
//         'https://api.assemblyai.com/v2/transcript',
//         data: {
//           'audio_url': audioUrl,
//           'language_code': 'ar',
//           'auto_chapters': false,
//         },
//         options: Options(headers: {'authorization': _apiKey}),
//       );
//
//       final transcriptId = transcriptResponse.data['id'];
//       String status = 'processing';
//
//       while (status == 'processing' || status == 'queued') {
//         await Future.delayed(const Duration(seconds: 3));
//         final pollingResponse = await _dio.get(
//           'https://api.assemblyai.com/v2/transcript/$transcriptId',
//           options: Options(headers: {'authorization': _apiKey}),
//         );
//
//         status = pollingResponse.data['status'];
//
//         if (status == 'completed') {
//           final text = pollingResponse.data['text'];
//           final matchResult = findClosestMatchWithScore(text, targetHadithMatn);
//
//           setState(() {
//             _transcription = text;
//             if (matchResult != null) {
//               _matchedHadith = matchResult['match'];
//               _matchScore = matchResult['score'];
//             } else {
//               _matchedHadith = null;
//               _matchScore = null;
//             }
//             _isProcessingTranscription = false;
//           });
//         } else if (status == 'error') {
//           setState(() {
//             _transcription = 'حدث خطأ أثناء التفريغ الصوتي.';
//             _isProcessingTranscription = false;
//           });
//         }
//       }
//     } catch (e) {
//       setState(() {
//         _transcription = 'فشل إرسال التسجيل: $e';
//         _isProcessingTranscription = false;
//       });
//     }
//   }
//
//   String preprocessArabicText(String text) {
//     text = text.replaceAll(RegExp(r'[أإآ]'), 'ا');
//     text = text.replaceAll('ى', 'ي');
//     text = text.replaceAll('ة', 'ه');
//     text = text.replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '');
//     text = text.replaceAll(RegExp(r'[؟،.؛:!"]'), '');
//     text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
//     return text;
//   }
//
//   Map<String, dynamic>? findClosestMatchWithScore(String input, String targetMatn) {
//     final cleanedInput = preprocessArabicText(input);
//     final cleanedTargetMatn = preprocessArabicText(targetMatn);
//
//     if (cleanedTargetMatn.isEmpty) {
//       return null;
//     }
//
//     final distance = levenshtein(cleanedInput, cleanedTargetMatn);
//     int maxLength = cleanedTargetMatn.length > cleanedInput.length ? cleanedTargetMatn.length : cleanedInput.length;
//     if (maxLength == 0) {
//       return {
//         'match': targetMatn,
//         'score': '0.00',
//       };
//     }
//
//     double similarity = 1 - (distance / maxLength);
//     double percentage = similarity * 100;
//
//     return {
//       'match': targetMatn,
//       'score': percentage.toStringAsFixed(2),
//     };
//   }
//
//   int levenshtein(String s1, String s2) {
//     List<List<int>> dp = List.generate(
//       s1.length + 1,
//           (_) => List.filled(s2.length + 1, 0),
//     );
//
//     for (int i = 0; i <= s1.length; i++) dp[i][0] = i;
//     for (int j = 0; j <= s2.length; j++) dp[0][j] = j;
//
//     for (int i = 1; i <= s1.length; i++) {
//       for (int j = 1; j <= s2.length; j++) {
//         int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
//         dp[i][j] = [
//           dp[i - 1][j] + 1,
//           dp[i][j - 1] + 1,
//           dp[i - 1][j - 1] + cost,
//         ].reduce((a, b) => a < b ? a : b);
//       }
//     }
//
//     return dp[s1.length][s2.length];
//   }
//
//   String _formatTime(int seconds) {
//     final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
//     final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
//     return '$minutes:$remainingSeconds';
//   }
//
//   Widget buildResultButton() {
//     if (_isProcessingTranscription) {
//       return Container(
//         width: screenWidth * (160 / 390),
//         height: screenHeight * (40 / 844),
//         decoration: BoxDecoration(
//           color: AppColors.lightGray,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: const Center(
//           child: CircularProgressIndicator(
//             color: Colors.white,
//           ),
//         ),
//       );
//     } else if (_matchScore != null) {
//       return GestureDetector(
//         onTap: () {},
//         child: Container(
//           width: screenWidth * (160 / 390),
//           height: screenHeight * (40 / 844),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: [
//                 Color(0xFF09A3BA),
//                 Color(0xFF92D2DC),
//               ],
//             ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Center(
//             child: Text(
//               'النتيجة: ($_matchScore%)',
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 fontFamily: "Cairo",
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       );
//     } else {
//       return Container(
//         width: screenWidth * (160 / 390),
//         height: screenHeight * (40 / 844),
//         decoration: BoxDecoration(
//           color: AppColors.lightGray,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: const Center(
//           child: Text(
//             "عرض النتيجة",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//               fontFamily: "Cairo",
//               color: Colors.white,
//             ),
//           ),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     screenWidth = MediaQuery.sizeOf(context).width;
//     screenHeight = MediaQuery.sizeOf(context).height;
//     return BlocBuilder<HadithBloc, HadithState>(
//       builder: (context, state) {
//         if (state is HadithLoadingState) {
//           return const Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         } else if (state is HadithLoadedState) {
//           final currentHadith = state.currentHadith;
//           final currentIndex = state.currentHadithIndex;
//           final hadithBloc = context.read<HadithBloc>();
//           final ahadithListLength = hadithBloc.ahadithList.length;
//
//           return Scaffold(
//             backgroundColor: AppColors.lightBackground,
//             appBar: AppBar(
//               backgroundColor: AppColors.primaryBlue,
//               title: Align(
//                 alignment: Alignment.centerRight,
//                 child: Text(
//                   state.currentHadith.title,
//                 ),
//               ),
//               titleTextStyle: const TextStyle(
//                   fontSize: 20, fontWeight: FontWeight.w700, fontFamily: "Cairo"),
//               actions: [
//                 Padding(
//                   padding: EdgeInsets.only(right: screenWidth * (30 / 390)),
//                   child: Image.asset(AssetManager.profile),
//                 ),
//               ],
//             ),
//             body: Stack(
//               children: [
//                 Directionality(
//                   textDirection: TextDirection.rtl,
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.only(
//                             right: screenWidth * (29 / 390),
//                             left: screenWidth * (29 / 390),
//                             top: screenWidth * (31 / 390)),
//                         child: Row(
//                           children: [
//                             GestureDetector(
//                               onTap: () {
//                                 _showWarningDialog(context);
//                               },
//                               child: Image.asset(AssetManager.website),
//                             ),
//                             Padding(
//                               padding: EdgeInsets.only(
//                                   right: screenWidth * (8 / 390),
//                                   left: screenWidth * (66 / 390)),
//                               child: const Text(
//                                 "سمّع الحديث النبوي !",
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w700,
//                                   fontFamily: "Almarai",
//                                   color: AppColors.gray,
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               width: screenWidth * (74 / 390),
//                               height: screenHeight * (35 / 844),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Center(
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     const Text(
//                                       "500",
//                                       style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w700,
//                                           fontFamily: "Cairo",
//                                           color: AppColors.orange),
//                                     ),
//                                     Image.asset(AssetManager.feather),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(
//                             top: screenHeight * (23 / 844),
//                             bottom: screenHeight * (11 / 844),
//                             left: screenWidth * (14 / 390),
//                             right: screenWidth * (14 / 390)),
//                         child: Container(
//                           width: screenWidth * (362 / 390),
//                           height: screenHeight * (60 / 844),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 spreadRadius: 1,
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Text(
//                             state.currentHadith.sanad,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w400,
//                               fontSize: 18,
//                               fontFamily: "Aladin",
//                               color: AppColors.green,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(
//                             left: screenWidth * (14 / 390),
//                             right: screenWidth * (14 / 390)),
//                         child: Container(
//                           width: screenWidth * (362 / 390),
//                           height: screenHeight * (324 / 844),
//                           decoration: BoxDecoration(
//                             //  color: Colors.white,
//                             gradient: const LinearGradient(
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                                 colors: [
//                                   Colors.white,
//                                   Color(0xffE2E2E2),
//                                   Colors.white
//                                 ]
//                             ),
//                             borderRadius: BorderRadius.circular(10),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 spreadRadius: 1,
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           padding: const EdgeInsets.all(15),
//                           child: SingleChildScrollView(
//                             child: Text(
//                               _isRecording
//                                   ? ''
//                                   : (_transcription ?? state.currentHadith.matn),
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w400,
//                                 fontSize: 18,
//                                 fontFamily: "Aladin",
//                                 color: AppColors.black,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(
//                           top: screenHeight * (37 / 844),
//                           bottom: screenHeight * (90 / 844),
//                           right: screenWidth*(30/390),
//                           left: screenWidth*(200/390),
//                         ),
//                         child: buildResultButton(),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: BottomNavigationBar(
//                     type: BottomNavigationBarType.fixed,
//                     backgroundColor: const Color(0xff088395),
//                     iconSize: 16,
//                     selectedItemColor: Colors.white,
//                     unselectedItemColor: Colors.white,
//                     showSelectedLabels: true,
//                     showUnselectedLabels: true,
//                     selectedLabelStyle: const TextStyle(
//                         fontSize: 12, fontWeight: FontWeight.bold),
//                     unselectedLabelStyle: const TextStyle(fontSize: 12),
//                     items: [
//                       BottomNavigationBarItem(
//                         icon: GestureDetector(
//                             onTap: currentIndex > 0
//                                 ? () {
//                               setState(() {
//                                 _transcription = null;
//                                 _matchScore = null;
//                               });
//                               hadithBloc.add(const PreviousHadithEvent());
//                             }
//                                 : null,
//                             child: const Icon(Icons.arrow_back_ios)),
//                         label: 'السابق',
//                         backgroundColor: const Color(0xff076A78),
//                       ),
//                       const BottomNavigationBarItem(
//                         icon: Icon(Icons.headphones),
//                         label: 'استماع',
//                       ),
//                       BottomNavigationBarItem(
//                         icon: GestureDetector(
//                           onTap: () {
//                             if (_isRecording) {
//                               _stopRecording(currentHadith.matn);
//                             } else {
//                               _startRecording();
//                             }
//                           },
//                           child: const Icon(Icons.mic),
//                         ),
//                         label: _isRecording ? 'إيقاف' : "تسميع",
//                       ),
//                       BottomNavigationBarItem(
//                         icon: GestureDetector(
//                             onTap: currentIndex < ahadithListLength - 1
//                                 ? () {
//                               setState(() {
//                                 _transcription = null;
//                                 _matchScore = null;
//                               });
//                               hadithBloc.add(const NextHadithEvent());
//                             }
//                                 : null,
//                             child: const Icon(Icons.arrow_forward_ios)),
//                         label: 'التالي',
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (_isRecording || _isProcessingTranscription)
//                   Positioned(
//                     bottom: 50,
//                     left: 0,
//                     right: 0,
//                     child: Container(
//                       width: screenWidth,
//                       height: screenHeight * (43 / 840),
//                       decoration: BoxDecoration(
//                         // color: AppColors.babyBlue,
//                         gradient: const LinearGradient(
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                             colors: [
//                               AppColors.babyBlue,
//                               Colors.white,
//                             ]
//                         ),
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20),
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             spreadRadius: 1,
//                             blurRadius: 10,
//                             offset: const Offset(0, -4),
//                           ),
//                         ],
//                       ),
//                       padding: EdgeInsets.symmetric(
//                           horizontal: screenWidth * (43 / 390),
//                           vertical: screenHeight * 0.01),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             _formatTime(_elapsedTimeInSeconds),
//                             style: const TextStyle(
//                               color: AppColors.primaryBlue,
//                               fontSize: 16,
//                             ),
//                           ),
//                           Expanded(
//                             child: Container(
//                               height: screenHeight * 0.04,
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Center(
//                                 child: Image.asset(AssetManager.wave),
//                               ),
//                             ),
//                           ),
//                           const Icon(
//                             Icons.circle,
//                             color: Colors.red,
//                             size: 14,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           );
//         } else if (state is HadithErrorState) {
//           return Scaffold(
//             body: Center(child: Text(state.message)),
//           );
//         }
//         return const Scaffold(body: Center(child: Text('خطأ غير معروف')));
//       },
//     );
//   }
//
//   void _showWarningDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Directionality(
//           textDirection: TextDirection.rtl,
//           child: AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15.0),
//             ),
//             title: const Text(
//               'تنويه !',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontFamily: "Cairo",
//                 fontWeight: FontWeight.w400,
//                 fontSize: 20,
//                 color: AppColors.primaryBlue,
//               ),
//             ),
//             content: const Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'قد يرد في هذا الحديث مفردات\nلها عدة قراءات',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontFamily: "Aladin",
//                     color: AppColors.gray,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   'يرجى الاستماع للحديث',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontFamily: "Aladin",
//                     color: AppColors.gray,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               Center(
//                 child: TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: const Column(
//                     children: [
//                       Divider(
//                         color: AppColors.gray,
//                       ),
//                       SizedBox(height: 10,),
//                       Text(
//                         'استماع',
//                         style: TextStyle(
//                             color: Color(0xff442B0D),
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: "Cairo"),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }




// import 'package:alhekmah_app/core/utils/asset_manager.dart';
// import 'package:alhekmah_app/core/utils/color_manager.dart';
// import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_bloc.dart';
// import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import 'bloc/hadith_event.dart';
//
// class HadethRecitationScreen extends StatefulWidget {
//    HadethRecitationScreen({super.key});
//
//   @override
//   State<HadethRecitationScreen> createState() => _HadethRecitationScreenState();
// }
//
// class _HadethRecitationScreenState extends State<HadethRecitationScreen> {
//    late double screenWidth;
//    late double screenHeight;
//    bool _isReciting = false;
//
//
//   @override
//   Widget build(BuildContext context) {
//     screenWidth =MediaQuery.sizeOf(context).width;
//     screenHeight = MediaQuery.sizeOf(context).height;
//     return BlocBuilder<HadithBloc, HadithState>(
//       builder: (context, state) {
//         if (state is HadithLoadingState) {
//           return Scaffold(body: Center(child:  CircularProgressIndicator(),),);
//         } else if (state is HadithLoadedState) {
//           final currentHadith = state.currentHadith;
//           final currentIndex = state.currentHadithIndex;
//           final hadithBloc = context.read<HadithBloc>();
//           final ahadithListLength = hadithBloc.ahadithList.length;
//
//           return Scaffold(
//             backgroundColor: AppColors.lightBackground,
//             appBar: AppBar(
//               backgroundColor: AppColors.primaryBlue,
//               title: Align(
//                 alignment: Alignment.centerRight,
//                 child: Text(state.currentHadith.title,
//                 ),
//               ),
//               titleTextStyle: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                   fontFamily: "Cairo"
//               ),
//               actions: [
//                 Padding(
//                   padding:  EdgeInsets.only(right: screenWidth*(30/390)),
//                   child: Image.asset(AssetManager.profile),
//                 ),
//               ],
//             ),
//             body: Stack(
//               children: [
//                 Directionality(
//                   textDirection: TextDirection.rtl,
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding:  EdgeInsets.only(right: screenWidth*(29/390),left: screenWidth*(29/390),top: screenWidth*(31/390)),
//                         child: Row(
//                           children: [
//                             GestureDetector(
//                               onTap: (){
//                                 _showWarningDialog(context);
//                               },
//                               child: Image.asset(AssetManager.website),
//                             ),
//                             Padding(
//                               padding:  EdgeInsets.only(right: screenWidth*(8/390),left: screenWidth*(66/390)),
//                               child: Text("سمّع الحديث النبوي !",
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w700,
//                                   fontFamily: "Almarai",
//                                   color: AppColors.gray,
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               width: screenWidth*(74/390),
//                               height: screenHeight*(35/844),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Center(
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text("500",style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.w700,
//                                         fontFamily: "Cairo",
//                                         color: AppColors.orange
//                                     ),
//                                     ),
//                                     Image.asset(AssetManager.feather),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Padding(
//                         padding:  EdgeInsets.only(top: screenHeight*(23/844),bottom: screenHeight*(11/844), left: screenWidth*(14/390),right: screenWidth*(14/390)),
//                         child: Container(
//                           width: screenWidth*(362/390),
//                           height: screenHeight*(60/844),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 spreadRadius: 1,
//                                 blurRadius: 10,
//                                 offset: Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Text(state.currentHadith.sanad,
//                             style: TextStyle(
//                               fontWeight: FontWeight.w400,
//                               fontSize: 18,
//                               fontFamily: "Aladin",
//                               color: AppColors.green ,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding:  EdgeInsets.only(left: screenWidth*(14/390),right: screenWidth*(14/390)),
//                         child: Container(
//                           width: screenWidth*(362/390),
//                           height: screenHeight*(324/844),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(10),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 spreadRadius: 1,
//                                 blurRadius: 10,
//                                 offset: Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Text(state.currentHadith.matn,
//                             style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18, fontFamily: "Aladin", color: AppColors.black ,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(left: screenWidth*(200/390),right: screenHeight*(30/390),top: screenHeight*(37/844) ,bottom: screenHeight*(90/844)),
//                         child: Container(
//                           width: screenWidth*(160/390),
//                           height: screenHeight*(40/844),
//                           decoration: BoxDecoration(
//                             color: AppColors.lightGray,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Center(
//                             child: Text("عرض النتيجة",
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: "Cairo", color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//
//                     ],
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: BottomNavigationBar(
//                     type: BottomNavigationBarType.fixed,
//                     backgroundColor: Color(0xff088395),
//                     iconSize: 16,
//                     selectedItemColor: Colors.white,
//                     unselectedItemColor: Colors.white,
//                     showSelectedLabels: true,
//                     showUnselectedLabels: true,
//                     selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                     unselectedLabelStyle: TextStyle(fontSize: 12),
//                     items: [
//                       BottomNavigationBarItem(
//                         icon: GestureDetector(
//                             child: Icon(Icons.arrow_back_ios)),
//                         label: 'السابق',
//                         backgroundColor: Color(0xff076A78),
//                       ),
//                       BottomNavigationBarItem(
//                         icon: Icon(
//                             Icons.headphones
//                         ),
//                         label: 'استماع',
//                       ),
//                       BottomNavigationBarItem(
//                         icon: GestureDetector(
//                         onTap: (){
//                         setState(() {
//                           _isReciting = !_isReciting;
//                         });
//                         },
//                         child: Icon(Icons.mic)),
//                         label: 'تسميع',
//                       ),
//                       BottomNavigationBarItem(
//                         icon: GestureDetector(
//                           onTap: currentIndex < ahadithListLength - 1 ? () => hadithBloc.add(const NextHadithEvent()) : null,
//                             child: Icon(Icons.arrow_forward_ios)),
//                         label: 'التالي',
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (_isReciting)
//                   Positioned(
//                     bottom: 50,
//                     left: 0,
//                     right: 0,
//                     child: Container(
//                       width: screenWidth,
//                       height: screenHeight*(43/840),
//                       decoration: BoxDecoration(
//                         color: AppColors.babyBlue,
//                         borderRadius: BorderRadius.only(
//                             topLeft: Radius.circular(20),
//                             topRight: Radius.circular(20),
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.1),
//                             spreadRadius: 1,
//                             blurRadius: 10,
//                             offset: Offset(0, -4),
//                           ),
//                         ],
//                       ),
//                       padding: EdgeInsets.symmetric(horizontal: screenWidth * (43/390), vertical: screenHeight * 0.01),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // IconButton(
//                           //   icon: Icon(Icons.close, color: AppColors.primaryBlue),
//                           //   onPressed: () {
//                           //     setState(() {
//                           //       _isReciting = false;
//                           //     });
//                           //   },
//                           // ),
//                           Text(
//                             '0:03',
//                             style: TextStyle(
//                               color: AppColors.primaryBlue,
//                               fontSize: 16,
//                             ),
//                           ),
//                           Container(
//                             width: screenWidth * 0.4,
//                             height: screenHeight * 0.04,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                           ),
//                           Icon(Icons.circle, color: Colors.red,size: 14,),
//                         ],
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             /*bottomNavigationBar: Container(
//               decoration: const BoxDecoration(
//                 border: Border(top: BorderSide(color: Colors.black12, width: 1.0)),
//               ),
//               child: BottomNavigationBar(
//                 type: BottomNavigationBarType.fixed,
//                 backgroundColor:  Color(0xff088395),
//                 selectedItemColor: Colors.white,
//                 unselectedItemColor: Colors.white,
//                 showSelectedLabels: true,
//                 showUnselectedLabels: true,
//                 selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                 unselectedLabelStyle: TextStyle(fontSize: 12),
//                 items: [
//                   BottomNavigationBarItem(
//                     icon: IconButton(
//                       icon: const Icon(Icons.arrow_back_ios),
//                       onPressed: currentIndex > 0 ? () => hadithBloc.add(const PreviousHadithEvent()) : null,
//                     ),
//                     label: 'السابق',
//                     backgroundColor: Color(0xff076A78),
//                   ),
//                   BottomNavigationBarItem(
//                     icon: Icon(Icons.headphones),
//                     label: 'استماع',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: IconButton(
//                       onPressed: (){
//                         setState(() {
//                           _isReciting = !_isReciting;
//                         });
//                     }, icon: Icon(Icons.mic),
//                     ),
//                     label: 'تسميع',
//                   ),
//                   BottomNavigationBarItem(
//                     icon: IconButton(
//                       icon: const Icon(Icons.arrow_forward_ios),
//                       onPressed: currentIndex < ahadithListLength - 1 ? () => hadithBloc.add(const NextHadithEvent()) : null,
//                     ),
//                     label: 'التالي',
//                   ),
//                 ],
//               ),
//             ),*/
//           );
//         } else if (state is HadithErrorState) {
//           return Scaffold(
//             body: Center(child: Text(state.message)),
//           );
//         }
//         return const Scaffold(body: Center(child: Text('خطأ غير معروف')));
//       },
//     );
//
//   }
//
//    void _showWarningDialog(BuildContext context) {
//      showDialog(
//        context: context,
//        builder: (BuildContext context) {
//          return Directionality(
//            textDirection: TextDirection.rtl,
//            child: AlertDialog(
//              shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.circular(15.0),
//              ),
//              title: const Text(
//                'تنويه !',
//                textAlign: TextAlign.center,
//                style: TextStyle(
//                  fontFamily: "Cairo",
//                  fontWeight: FontWeight.w400,
//                  fontSize: 20,
//                  color: AppColors.primaryBlue,
//                ),
//              ),
//              content: const Column(
//                mainAxisSize: MainAxisSize.min,
//                children: [
//                  Text(
//                    'قد يرد في هذا الحديث مفردات\nلها عدة قراءات',
//                    textAlign: TextAlign.center,
//                    style: TextStyle(
//                      fontSize: 20,
//                      fontFamily: "Aladin",
//                      color: AppColors.gray,
//                      fontWeight: FontWeight.w400,
//                    ),
//                  ),
//                  SizedBox(height: 10),
//                  Text(
//                    'يرجى الاستماع للحديث',
//                    textAlign: TextAlign.center,
//                    style: TextStyle(
//                      fontSize: 20,
//                      fontFamily: "Aladin",
//                      color: AppColors.gray,
//                      fontWeight: FontWeight.w400,
//                    ),
//                  ),
//                ],
//              ),
//              actions: [
//                Center(
//                  child: TextButton(
//                    onPressed: () {
//                      Navigator.of(context).pop();
//                    },
//                    child: Column(
//                      children: [
//                        Divider(
//                          color: AppColors.gray,
//                        ),
//                        SizedBox(height: 10,),
//                        const Text(
//                          'استماع',
//                          style: TextStyle(
//                              color: Color(0xff442B0D),
//                              fontSize: 16,
//                              fontWeight: FontWeight.bold,
//                              fontFamily: "Cairo"
//                          ),
//                        ),
//                      ],
//                    ),
//                  ),
//                ),
//              ],
//            ),
//          );
//        },
//      );
//    }
// }
