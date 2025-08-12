import 'dart:io';
import 'dart:async';
import 'package:alhekmah_app/core/utils/asset_manager.dart';
import 'package:alhekmah_app/core/utils/color_manager.dart';
import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_bloc.dart';
import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'bloc/hadith_event.dart';

class WordInfo {
  String text;
  bool isMatched;
  String originalText;

  WordInfo(this.text, this.isMatched, this.originalText);
}

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

  List<WordInfo> _userTranscriptionWords = [];
  List<WordInfo> _originalHadithWords = [];
  bool _hasShownResult = false;

  final Map<int, JustTheController> _tooltipControllers = {};
  final TextEditingController _editingController = TextEditingController();
  int? _editingWordIndex;

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _editingController.dispose();
    _tooltipControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _hideAllTooltips() {
    _tooltipControllers.values.forEach((controller) => controller.hideTooltip());
    _editingWordIndex = null;
  }

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
        _userTranscriptionWords = [];
        _originalHadithWords = [];
        _hasShownResult = false;
        _hideAllTooltips();
        _tooltipControllers.clear();
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
          final highlightedTexts = highlightMismatchedWords(text, targetHadithMatn);

          setState(() {
            _transcription = text;
            _originalHadithWords = highlightedTexts['original']!;
            _userTranscriptionWords = highlightedTexts['transcription']!;
            _isProcessingTranscription = false;
            // يتم مسح controllers القديمة هنا وإعادة إنشائها حسب الكلمات الجديدة
            _tooltipControllers.values.forEach((controller) => controller.dispose());
            _tooltipControllers.clear();
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
    text = text.replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '');
    text = text.replaceAll(RegExp(r'[؟،.؛:!"]'), '');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
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

  Map<String, List<WordInfo>> highlightMismatchedWords(String input, String targetMatn) {
    final inputWords = preprocessArabicText(input).split(' ');
    final targetWords = preprocessArabicText(targetMatn).split(' ');
    final originalTargetWords = targetMatn.split(' ');
    final originalInputWords = input.split(' ');

    List<WordInfo> originalList = [];
    List<WordInfo> transcriptionList = [];

    for (int i = 0; i < targetWords.length; i++) {
      final targetWord = targetWords[i];
      final originalTargetWord = originalTargetWords.length > i ? originalTargetWords[i] : '';

      bool isMatched = false;
      String currentInputWord = '';
      String originalCurrentInputWord = '';

      if (i < inputWords.length) {
        currentInputWord = inputWords[i];
        originalCurrentInputWord = originalInputWords.length > i ? originalInputWords[i] : '';

        final distance = levenshtein(currentInputWord, targetWord);
        final similarity = 1 - (distance / (currentInputWord.length > targetWord.length ? currentInputWord.length : targetWord.length));

        if (similarity > 0.8) {
          isMatched = true;
        }
      }
      originalList.add(WordInfo(originalTargetWord, true, originalTargetWord));
      transcriptionList.add(WordInfo(originalCurrentInputWord, isMatched, originalCurrentInputWord));
    }
    return {'original': originalList, 'transcription': transcriptionList};
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _updateWord(int index, String newText) {
    setState(() {
      _userTranscriptionWords[index].text = newText;
      final originalWord = preprocessArabicText(_originalHadithWords[index].text);
      final correctedWord = preprocessArabicText(newText);
      _userTranscriptionWords[index].isMatched = originalWord.trim() == correctedWord.trim();

      // لا يتم حساب النتيجة هنا، فقط تحديث الكلمة
      // _calculateFinalScore();
    });
  }

  void _calculateFinalScore() {
    if (_userTranscriptionWords.isEmpty || _originalHadithWords.isEmpty) {
      _matchScore = '0.00';
      return;
    }
    int matchedWordsCount = 0;
    for (int i = 0; i < _userTranscriptionWords.length && i < _originalHadithWords.length; i++) {
      final originalWord = preprocessArabicText(_originalHadithWords[i].text);
      final userWord = preprocessArabicText(_userTranscriptionWords[i].text);
      if (originalWord == userWord) {
        matchedWordsCount++;
      }
    }
    double percentage = (_userTranscriptionWords.isEmpty || _originalHadithWords.isEmpty || _originalHadithWords.length == 0) ? 0 : (matchedWordsCount / _originalHadithWords.length) * 100;
    _matchScore = percentage.toStringAsFixed(2);
  }

  Widget buildResultButton() {
    bool isProcessing = _isProcessingTranscription;
    bool hasTranscription = _transcription != null;

    if (isProcessing || !hasTranscription) {
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

    return GestureDetector(
      onTap: () {
        if (!_hasShownResult) {
          setState(() {
            _hasShownResult = true;
            _calculateFinalScore();
          });
        }
      },
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
            _hasShownResult && _matchScore != null
                ? 'النتيجة: ($_matchScore%)'
                : "عرض النتيجة",
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
  }

  List<Widget> _buildInteractiveWords(BuildContext context) {
    List<Widget> wordWidgets = [];
    _userTranscriptionWords.asMap().forEach((index, wordInfo) {
      if (wordInfo.text.isEmpty || wordInfo.isMatched) {
        wordWidgets.add(Text(
          '${wordInfo.text} ',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
            fontSize: 18,
            fontFamily: "Aladin",
          ),
        ));
      } else {
        if (!_tooltipControllers.containsKey(index)) {
          _tooltipControllers[index] = JustTheController();
        }

        wordWidgets.add(
          JustTheTooltip(
            key: ValueKey(index),
            controller: _tooltipControllers[index]!,
            triggerMode: TooltipTriggerMode.manual,
            tailLength: 10,
            backgroundColor: Colors.transparent,
            content: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _editingController,
                    autofocus: true,
                    onSubmitted: (newValue) {
                      _updateWord(index, newValue);
                      _tooltipControllers[index]!.hideTooltip();
                      setState(() {
                        _editingWordIndex = null;
                      });
                    },
                  ),
                ),
              ),
            ),
            child: GestureDetector(
              onTap: () {
                setState(() { // يجب أن تكون setState هنا لتحديث الواجهة
                  _hideAllTooltips(); // إخفاء أي tooltip آخر مفتوح

                  if (_editingWordIndex != index) {
                    _editingWordIndex = index;
                    _editingController.text = wordInfo.text;
                    _tooltipControllers[index]!.showTooltip();
                  } else {
                    _editingWordIndex = null;
                  }
                });
              },
              child: Text(
                '${wordInfo.text} ',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  fontFamily: "Aladin",
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        );
      }
    });
    return wordWidgets;
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
         // final ahadithListLength = hadithBloc.ahadithList.length;
          final String hadithSanadOrRaawi = currentHadith.sanad ?? currentHadith.raawi ?? "لا يوجد سند";
          final String hadithMatnOrContent = currentHadith.matn ?? currentHadith.content ?? "لا يوجد متن";

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
                          hadithSanadOrRaawi,
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
                            child: _userTranscriptionWords.isNotEmpty
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
                                    children: _originalHadithWords.map((wordInfo) {
                                      return TextSpan(
                                        text: '${wordInfo.text} ',
                                      );
                                    }).toList(),
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
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  textDirection: TextDirection.rtl,
                                  children: _buildInteractiveWords(context),
                                ),
                              ],
                            )
                                : Text(
                                hadithMatnOrContent,
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
                                _userTranscriptionWords = [];
                                _originalHadithWords = [];
                                _hasShownResult = false;
                                _hideAllTooltips();
                                _tooltipControllers.clear();
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
                              _stopRecording(hadithMatnOrContent);
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
                            onTap: currentIndex < state.totalHadiths - 1
                                ? () {
                              setState(() {
                                _transcription = null;
                                _matchScore = null;
                                _userTranscriptionWords = [];
                                _originalHadithWords = [];
                                _hasShownResult = false;
                                _hideAllTooltips();
                                _tooltipControllers.clear();
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
                color: AppColors.black,
              ),
            ),
            content: const Text(
              'هذه الأداة تستخدم فقط للتدريب والمساعدة في التسميع، ولا تغني عن تصحيح المختصين للحديث.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Cairo",
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: AppColors.gray,
              ),
            ),
            actions: <Widget>[
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: screenWidth * (132 / 390),
                    height: screenHeight * (35 / 844),
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
                    child: const Center(
                      child: Text(
                        "تم",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Cairo",
                          color: Colors.white,
                        ),
                      ),
                    ),
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