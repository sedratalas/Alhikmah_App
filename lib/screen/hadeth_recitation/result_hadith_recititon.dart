import 'dart:io';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../core/app_service.dart';
import '../../core/utils/asset_manager.dart';
import '../../core/utils/color_manager.dart';
import '../../model/standard_hadith_model.dart';
import '../widget/app_drawer.dart';
import '../widget/bloc/profile_bloc.dart';
import 'bloc/hadith_bloc.dart';
import 'bloc/hadith_event.dart';
import 'bloc/hadith_state.dart';


class HadethRecitationScreen extends StatefulWidget {
  final Hadith hadith;
  HadethRecitationScreen({super.key, required this.hadith});

  @override
  State<HadethRecitationScreen> createState() => _HadethRecitationScreenState();
}

class _HadethRecitationScreenState extends State<HadethRecitationScreen> {
  late double screenWidth;
  late double screenHeight;
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isListening = false;
  bool _isPlaying = false;
  String? _audioFilePath;
  bool _hasRecording = false;
  bool _isPlayingRecorded = false;
  String? _transcriptionResult;
  String? _matchScore;
  bool _isSending = false;
  List<TextSpan> _highlightedOriginal = [];
  List<TextSpan> _highlightedUserTranscription = [];
  int _elapsedTimeInSeconds = 0;
  Timer? _timer;

  Future<bool> _requestPermissions() async {
    var status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _startRecording() async {
    final hasPermission = await _requestPermissions();
    if (hasPermission) {
      final directory = await getApplicationDocumentsDirectory();
      _audioFilePath = '${directory.path}/recitation.mp3';
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _audioFilePath!,
      );
      setState(() {
        _isRecording = true;
        _hasRecording = false;
        _isPlayingRecorded = false;
        _transcriptionResult = null;
        _matchScore = null;
        _isSending = false;
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

  Future<void> _stopRecording() async {
    if (_isRecording) {
      await _audioRecorder.stop();
      _timer?.cancel();
      setState(() {
        _isRecording = false;
        _hasRecording = true;
      });
    }
  }

  Future<void> _sendTranscription(String hadithMatn) async {
    if (_audioFilePath == null) return;

    setState(() {
      _isSending = true;
    });

    final result = await AppServices.hadithRepository.processHadithAudio(
      hadithId: widget.hadith.id,
      audioFile: File(_audioFilePath!),
      targetHadithMatn: hadithMatn,
    );

    if (result.error != null) {
      setState(() {
        _transcriptionResult = "حدث خطأ: ${result.error}";
        _isSending = false;
        _matchScore = null;
        _highlightedOriginal = [
          TextSpan(
            text: "حدث خطأ: ${result.error}",
            style: const TextStyle(color: Colors.red),
          )
        ];
        _highlightedUserTranscription = [];
      });
    } else if (result.data != null) {
      setState(() {
        _transcriptionResult = result.data!['transcription'];
        _matchScore = result.data!['matchScore'];
        _highlightedOriginal = result.data!['highlightedOriginal'] as List<TextSpan>;
        _highlightedUserTranscription = result.data!['highlightedUserTranscription'] as List<TextSpan>;
        _isSending = false;
      });
    }
  }

  Future<void> _playRecordedAudio() async {
    if (_audioFilePath != null) {
      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(_audioFilePath!));
      setState(() {
        _isPlayingRecorded = true;
      });
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          setState(() {
            _isPlayingRecorded = false;
          });
        }
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  Widget buildResultButton(String hadithMatnOrContent) {
    if (_isSending) {
      return Container(
        width: screenWidth * (160 / 390),
        height: screenHeight * (40 / 844),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
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
              colors: [Color(0xFF09A3BA), Color(0xFF92D2DC)],
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
    } else if (_hasRecording) {
      return GestureDetector(
        onTap: () {
          _sendTranscription(hadithMatnOrContent);
        },
        child: Container(
          width: screenWidth * (160 / 390),
          height: screenHeight * (40 / 844),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF09A3BA), Color(0xFF92D2DC)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              "إرسال التسجيل",
              style: TextStyle(
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
            "إرسال التسجيل",
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

  Future<void> _playAudio(int hadithId) async {
    await _audioPlayer.play(
      AssetSource('audio/hadith_$hadithId.ogg'),
    );

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        setState(() {
          _isPlaying = true;
        });
      } else {
        setState(() {
          _isPlaying = false;
        });
      }
      if (state == PlayerState.completed) {
        setState(() {
          _isListening = false;
          _isPlaying = false;
        });
      }
    });
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _disposeAudio() async {
    await _audioPlayer.dispose();
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              "تنبيه",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: "Almarai",
                color: AppColors.primaryBlue,
              ),
            ),
            content: const Text(
              "هذه الميزة مازالت قيد التطوير و قد تتسبب في بعض الأخطاء في التطبيق.",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: "Almarai",
                color: AppColors.black,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "فهمت",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: "Almarai",
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _disposeAudio();
    _timer?.cancel();
    super.dispose();
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
          final String hadithSanadOrRaawi = currentHadith.sanad ?? currentHadith.raawi ?? "لا يوجد سند";
          final String hadithMatnOrContent = currentHadith.matn ?? currentHadith.content ?? "لا يوجد متن";

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              drawer:  AppDrawer(),
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
                leading: Builder(
                  builder: (context) {
                    return GestureDetector(
                      onTap: () {
                        BlocProvider.of<ProfileBloc>(context).add(FetchUserProfile());
                        Scaffold.of(context).openDrawer();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: screenWidth * (20 / 390)),
                        child: Image.asset(AssetManager.profile),
                      ),
                    );
                  },
                ),
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
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
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
                                  ]),
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
                              child: _transcriptionResult != null
                                  ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                            right: screenWidth * (30 / 390),
                            left: screenWidth * (200 / 390),
                          ),
                          child: buildResultButton(hadithMatnOrContent),
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
                              onTap: currentIndex < state.totalHadiths - 1
                                  ? () {
                                setState(() {
                                  _transcriptionResult = null;
                                  _matchScore = null;
                                  _highlightedOriginal = [];
                                  _highlightedUserTranscription = [];
                                  _isListening = false;
                                  _isPlaying = false;
                                  _pauseAudio();
                                });
                                hadithBloc.add(const NextHadithEvent());
                              }
                                  : null,
                              child: const Icon(Icons.arrow_back_ios)),
                          label: 'التالي',
                        ),
                        BottomNavigationBarItem(
                          icon: GestureDetector(
                            onTap: _isListening ? null : () {
                              if (_isRecording) {
                                _stopRecording();
                              } else {
                                _startRecording();
                              }
                            },
                            child: Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                            ),
                          ),
                          label: _isRecording ? 'إيقاف' : "تسميع",
                        ),
                        BottomNavigationBarItem(
                          icon: GestureDetector(
                            onTap: _isRecording ? null : () {
                              setState(() {
                                _isListening = !_isListening;
                                if (_isListening) {
                                  _playAudio(currentHadith.id);
                                } else {
                                  _pauseAudio();
                                }
                              });
                            },
                            child: const Icon(Icons.headphones),
                          ),
                          label: 'استماع',
                        ),
                        BottomNavigationBarItem(
                          icon: GestureDetector(
                              onTap: currentIndex > 0
                                  ? () {
                                setState(() {
                                  _transcriptionResult = null;
                                  _matchScore = null;
                                  _highlightedOriginal = [];
                                  _highlightedUserTranscription = [];
                                  _isListening = false;
                                  _isPlaying = false;
                                  _pauseAudio();
                                });
                                hadithBloc.add(const PreviousHadithEvent());
                              }
                                  : null,
                              child: const Icon(Icons.arrow_forward_ios)),
                          label: 'السابق',
                          backgroundColor: const Color(0xff076A78),
                        ),
                      ],
                    ),
                  ),
                  if (_isRecording || _isSending)
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
                              ]),
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
                            const Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 14,
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
                            Text(
                              _formatTime(_elapsedTimeInSeconds),
                              style: const TextStyle(
                                color: AppColors.primaryBlue,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_hasRecording && !_isRecording && !_isSending)
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
                              ]),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _playRecordedAudio,
                              child: Icon(
                                _isPlayingRecorded ? Icons.pause : Icons.play_arrow,
                                color: AppColors.primaryBlue,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 30,),
                            Center(child: Image.asset(AssetManager.wave)),
                          ],
                        ),
                      ),
                    ),
                  if (_isListening)
                    Positioned(
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: screenWidth,
                        height: screenHeight * (43 / 840),
                        decoration: BoxDecoration(
                          color: const Color(0xff4EA2B1),
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
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (_isPlaying) {
                                    _pauseAudio();
                                  } else {
                                    _playAudio(state.currentHadith.id);
                                  }
                                });
                              },
                              child: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
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
}