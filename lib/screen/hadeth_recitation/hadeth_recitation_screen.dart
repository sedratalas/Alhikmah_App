/*import 'package:alhekmah_app/core/utils/asset_manager.dart';
import 'package:alhekmah_app/core/utils/color_manager.dart';
import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_bloc.dart';
import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/hadith_event.dart';
import 'bloc/tasmiya/tasmiya_bloc.dart';
import 'bloc/widget/hadith_loading.dart';
class HadethRecitationScreen extends StatelessWidget {
  const HadethRecitationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return BlocBuilder<HadithBloc, HadithState>(
      builder: (context, hadithState) {
        if (hadithState is HadithLoadingState) {
          return HadithLoadingScreen();
        } else if (hadithState is HadithLoadedState) {
          return BlocProvider<TasmiyaBloc>(
            create: (context) => TasmiyaBloc(targetMatn: hadithState.currentHadith.matn),
            child: _buildHadithContent(context, hadithState, screenWidth, screenHeight),
          );
        } else if (hadithState is HadithErrorState) {
          return Scaffold(
            body: Center(child: Text(hadithState.message)),
          );
        }
        return const Scaffold(body: Center(child: Text('خطأ غير معروف')));
      },
    );
  }

  Widget _buildHadithContent(BuildContext context, HadithLoadedState hadithState, double screenWidth, double screenHeight) {
    final currentHadith = hadithState.currentHadith;
    final currentIndex = hadithState.currentHadithIndex;
    final hadithBloc = context.read<HadithBloc>();
    final ahadithListLength = hadithBloc.ahadithList.length;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(currentHadith.title),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: "Cairo",
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: screenWidth * (30 / 390)),
            child: Image.asset(AssetManager.profile),
          ),
        ],
      ),
      body: BlocBuilder<TasmiyaBloc, TasmiyaState>(
        builder: (context, tasmiyaState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTopSection(context, screenWidth, screenHeight),
                  _buildHadithTextSection(context, tasmiyaState, currentHadith.sanad, currentHadith.matn, screenWidth, screenHeight),
                  _buildBottomResultSection(context, tasmiyaState, screenWidth, screenHeight),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<TasmiyaBloc, TasmiyaState>(
        builder: (context, tasmiyaState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tasmiyaState is TasmiyaRecording)
                _buildRecordingBar(tasmiyaState, screenWidth,screenHeight),
              _buildNormalNavBar(context, hadithBloc, currentIndex, ahadithListLength, tasmiyaState, screenWidth),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHadithTextSection(BuildContext context, TasmiyaState tasmiyaState, String sanad, String matn, double screenWidth, double screenHeight) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: screenHeight * (23 / 844), bottom: screenHeight * (11 / 844), left: screenWidth * (14 / 390), right: screenWidth * (14 / 390)),
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
              padding: const EdgeInsets.all(8.0),
              child: Text(
                sanad,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  fontFamily: "Aladin",
                  color: AppColors.green,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: screenWidth * (14 / 390), right: screenWidth * (14 / 390)),
          child: Container(
            width: screenWidth * (362 / 390),
            height: screenHeight * (324 / 844),
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
            child: _buildTextContent(tasmiyaState, matn),
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent(TasmiyaState tasmiyaState, String originalMatn) {
    if (tasmiyaState is TasmiyaRecording) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('جاري التسجيل...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 18,
              fontFamily: "Aladin",
              color: AppColors.black,
            ),
          ),
        ),
      );
    } else if (tasmiyaState is TasmiyaProcessing) {
      return const Center(child: CircularProgressIndicator());
    } else if (tasmiyaState is TasmiyaCompleted) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: RichText(
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          text: TextSpan(
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 18,
              fontFamily: "Aladin",
              color: AppColors.black,
            ),
            children: (tasmiyaState.highlightedText).map((wordData) {
              return TextSpan(
                text: "${wordData['text']} ",
                style: TextStyle(
                  color: wordData['isCorrect'] ? AppColors.green : Colors.red,
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        originalMatn,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 18,
          fontFamily: "Aladin",
          color: AppColors.black,
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildTopSection(BuildContext context, double screenWidth, double screenHeight) {
    return Padding(
      padding: EdgeInsets.only(right: screenWidth * (29 / 390), left: screenWidth * (29 / 390), top: screenWidth * (31 / 390)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _showWarningDialog(context);
            },
            child: Image.asset(AssetManager.website),
          ),
          Padding(
            padding: EdgeInsets.only(right: screenWidth * (8 / 390), left: screenWidth * (66 / 390)),
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
                  Text(
                    "500",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Cairo",
                      color: AppColors.orange,
                    ),
                  ),
                  Image.asset(AssetManager.feather),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomResultSection(BuildContext context, TasmiyaState tasmiyaState, double screenWidth, double screenHeight) {
    if (tasmiyaState is TasmiyaCompleted) {
      final score = tasmiyaState.score.toStringAsFixed(2);
      final isSuccess = tasmiyaState.score > 70;
      return Padding(
        padding: EdgeInsets.only(left: screenWidth * (200 / 390), right: screenWidth * (30 / 390), top: screenHeight * (37 / 844), bottom: screenHeight * (90 / 844)),
        child: Container(
          width: screenWidth * (160 / 390),
          height: screenHeight * (40 / 844),
          decoration: BoxDecoration(
            color: isSuccess ? AppColors.green : Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              isSuccess ? "تم التسميع بنجاح" : "النتيجة: $score%",
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
    } else if (tasmiyaState is TasmiyaError) {
      return Padding(
        padding: EdgeInsets.only(left: screenWidth * (200 / 390), right: screenWidth * (30 / 390), top: screenHeight * (37 / 844), bottom: screenHeight * (90 / 844)),
        child: Container(
          width: screenWidth * (160 / 390),
          height: screenHeight * (40 / 844),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              tasmiyaState.message,
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
    return Padding(
      padding: EdgeInsets.only(left: screenWidth * (200 / 390), right: screenWidth * (30 / 390), top: screenHeight * (37 / 844), bottom: screenHeight * (90 / 844)),
      child: Container(
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
      ),
    );
  }
  Widget _buildRecordingBar(TasmiyaRecording tasmiyaState, double screenWidth, double screenHeight) {
    final int minutes = (tasmiyaState.elapsedTimeInSeconds / 60).floor();
    final int seconds = (tasmiyaState.elapsedTimeInSeconds % 60);

    return Container(
      height: screenHeight*(43/840),
      decoration: const BoxDecoration(
        color: Color(0xffE4EBF0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$minutes:${seconds.toString().padLeft(2, '0')}",
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          SizedBox(
            width: screenWidth * 0.5,
            // يمكنك هنا وضع الموجة الصوتية
          ),
          const Icon(Icons.circle, color: Colors.red, size: 16),
        ],
      ),
    );
  }
  Widget _buildNormalNavBar(BuildContext context, HadithBloc hadithBloc, int currentIndex, int ahadithListLength, TasmiyaState tasmiyaState, double screenWidth) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black12, width: 1.0)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xff088395),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: currentIndex > 0 ? () => hadithBloc.add(const PreviousHadithEvent()) : null,
            ),
            label: 'السابق',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.headphones),
            label: 'استماع',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(tasmiyaState is TasmiyaRecording ? Icons.stop : Icons.mic),
              onPressed: () {
                if (tasmiyaState is TasmiyaRecording) {
                  context.read<TasmiyaBloc>().add(StopRecordingEvent());
                } else {
                  context.read<TasmiyaBloc>().add(StartRecordingEvent());
                }
              },
            ),
            label: tasmiyaState is TasmiyaRecording ? 'إيقاف' : 'تسميع',
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: currentIndex < ahadithListLength - 1 ? () => hadithBloc.add(const NextHadithEvent()) : null,
            ),
            label: 'التالي',
          ),
        ],
      ),
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
                      SizedBox(height: 10),
                      Text(
                        'استماع',
                        style: TextStyle(
                          color: Color(0xff442B0D),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Cairo",
                        ),
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
}*/