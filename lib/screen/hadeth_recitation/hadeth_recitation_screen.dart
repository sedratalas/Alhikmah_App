import 'package:alhekmah_app/core/utils/asset_manager.dart';
import 'package:alhekmah_app/core/utils/color_manager.dart';
import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_bloc.dart';
import 'package:alhekmah_app/screen/hadeth_recitation/bloc/hadith_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'bloc/hadith_event.dart';

class HadethRecitationScreen extends StatelessWidget {
   HadethRecitationScreen({super.key});
   late double screenWidth;
   late double screenHeight;
  @override
  Widget build(BuildContext context) {
    screenWidth =MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
    return BlocBuilder<HadithBloc, HadithState>(
      builder: (context, state) {
        if (state is HadithLoadingState) {
          return _buildLoadingScreen(context);
        } else if (state is HadithLoadedState) {
          return _buildHadithContent(context, state);
        } else if (state is HadithErrorState) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          );
        }
        return const Scaffold(body: Center(child: Text('خطأ غير معروف')));
      },
    );

  }
   Widget _buildLoadingScreen(BuildContext context) {
     return Shimmer.fromColors(
       baseColor: Colors.grey[300]!,
       highlightColor: Colors.grey[100]!,
       child: Scaffold(
         backgroundColor: AppColors.lightBackground,
         appBar: AppBar(
           backgroundColor: AppColors.primaryBlue,
           title: Align(
             alignment: Alignment.centerRight,
             child: Container(
               width: 150,
               height: 20,
               color: Colors.white,
             ),
           ),
           titleTextStyle: const TextStyle(
             fontSize: 20,
             fontWeight: FontWeight.w700,
             fontFamily: "Cairo",
           ),
           actions: [
             Padding(
               padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * (30 / 390)),
               child: Image.asset(AssetManager.profile),
             ),
           ],
         ),
         body: Directionality(
           textDirection: TextDirection.rtl,
           child: SingleChildScrollView(
             child: Column(
               children: [
                 Padding(
                   padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * (29 / 390), left: MediaQuery.sizeOf(context).width * (29 / 390), top: MediaQuery.sizeOf(context).width * (31 / 390)),
                   child: Row(
                     children: [
                       Container(width: 30, height: 30, color: Colors.white),
                       Padding(
                         padding: EdgeInsets.only(right: MediaQuery.sizeOf(context).width * (8 / 390), left: MediaQuery.sizeOf(context).width * (66 / 390)),
                         child: Container(width: 150, height: 20, color: Colors.white),
                       ),
                       Container(width: 74, height: 35, color: Colors.white),
                     ],
                   ),
                 ),
                 Padding(
                   padding: EdgeInsets.only(top: MediaQuery.sizeOf(context).height * (23 / 844), bottom: MediaQuery.sizeOf(context).height * (11 / 844), left: MediaQuery.sizeOf(context).width * (14 / 390), right: MediaQuery.sizeOf(context).width * (14 / 390)),
                   child: Container(
                     width: MediaQuery.sizeOf(context).width * (362 / 390),
                     height: 50,
                     color: Colors.white,
                   ),
                 ),
                 Padding(
                   padding: EdgeInsets.only(left: MediaQuery.sizeOf(context).width * (14 / 390), right: MediaQuery.sizeOf(context).width * (14 / 390)),
                   child: Container(
                     width: MediaQuery.sizeOf(context).width * (362 / 390),
                     height: 200,
                     color: Colors.white,
                   ),
                 ),
                 Padding(
                   padding: EdgeInsets.only(left: MediaQuery.sizeOf(context).width * (200 / 390), right: MediaQuery.sizeOf(context).height * (30 / 390), top: MediaQuery.sizeOf(context).height * (37 / 844), bottom: MediaQuery.sizeOf(context).height * (90 / 844)),
                   child: Container(
                     width: MediaQuery.sizeOf(context).width * (160 / 390),
                     height: MediaQuery.sizeOf(context).height * (40 / 844),
                     color: Colors.white,
                   ),
                 ),
               ],
             ),
           ),
         ),
         bottomNavigationBar: BottomNavigationBar(
           type: BottomNavigationBarType.fixed,
           backgroundColor: const Color(0xff088395),
           selectedItemColor: Colors.white,
           unselectedItemColor: Colors.white,
           showSelectedLabels: true,
           showUnselectedLabels: true,
           selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
           unselectedLabelStyle: const TextStyle(fontSize: 12),
           items: const [
             BottomNavigationBarItem(icon: Icon(Icons.arrow_back_ios), label: 'السابق'),
             BottomNavigationBarItem(icon: Icon(Icons.headphones), label: 'استماع'),
             BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'تسميع'),
             BottomNavigationBarItem(icon: Icon(Icons.arrow_forward_ios), label: 'التالي'),
           ],
         ),
       ),
     );
   }

  Widget _buildHadithContent(BuildContext context, HadithLoadedState state){
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
          child: Text(state.currentHadith.title,
          ),
        ),
        titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: "Cairo"
        ),
        actions: [
          Padding(
            padding:  EdgeInsets.only(right: screenWidth*(30/390)),
            child: Image.asset(AssetManager.profile),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:  EdgeInsets.only(right: screenWidth*(29/390),left: screenWidth*(29/390),top: screenWidth*(31/390)),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: (){
                        _showWarningDialog(context);
                      },
                      child: Image.asset(AssetManager.website),
                    ),
                    Padding(
                      padding:  EdgeInsets.only(right: screenWidth*(8/390),left: screenWidth*(66/390)),
                      child: Text("سمّع الحديث النبوي !",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Almarai",
                          color: AppColors.gray,
                        ),
                      ),
                    ),
                    Container(
                      width: screenWidth*(74/390),
                      height: screenHeight*(35/844),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("500",style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: "Cairo",
                                color: AppColors.orange
                            ),
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
                padding:  EdgeInsets.only(top: screenHeight*(23/844),bottom: screenHeight*(11/844), left: screenWidth*(14/390),right: screenWidth*(14/390)),
                child: Container(
                  width: screenWidth*(362/390),
                  height: screenHeight*(60/844),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(state.currentHadith.sanad,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      fontFamily: "Aladin",
                      color: AppColors.green ,
                    ),
                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.only(left: screenWidth*(14/390),right: screenWidth*(14/390)),
                child: Container(
                  width: screenWidth*(362/390),
                  height: screenHeight*(324/844),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(state.currentHadith.matn,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      fontFamily: "Aladin",
                      color: AppColors.black ,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: screenWidth*(200/390),right: screenHeight*(30/390),top: screenHeight*(37/844) ,bottom: screenHeight*(90/844)),
                child: Container(
                  width: screenWidth*(160/390),
                  height: screenHeight*(40/844),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text("عرض النتيجة",
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black12, width: 1.0)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor:  Color(0xff088395),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 12),

          items: [
            BottomNavigationBarItem(
              icon: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: currentIndex > 0 ? () => hadithBloc.add(const PreviousHadithEvent()) : null,
              ),
              label: 'السابق',
              backgroundColor: Color(0xff076A78),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.headphones),
              label: 'استماع',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mic),
              label: 'تسميع',
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
                   child: Column(
                     children: [
                       Divider(
                         color: AppColors.gray,
                       ),
                       SizedBox(height: 10,),
                       const Text(
                         'استماع',
                         style: TextStyle(
                             color: Color(0xff442B0D),
                             fontSize: 16,
                             fontWeight: FontWeight.bold,
                             fontFamily: "Cairo"
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


}





