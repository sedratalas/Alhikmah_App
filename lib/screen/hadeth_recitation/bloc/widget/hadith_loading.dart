import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/utils/asset_manager.dart';
import '../../../../core/utils/color_manager.dart';

class HadithLoadingScreen extends StatefulWidget {
  const HadithLoadingScreen({super.key});

  @override
  State<HadithLoadingScreen> createState() => _HadithLoadingScreenState();
}

class _HadithLoadingScreenState extends State<HadithLoadingScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
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
              padding: EdgeInsets.only(right: screenWidth * (30 / 390)),
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
                  padding: EdgeInsets.only(right: screenWidth * (29 / 390), left: screenWidth * (29 / 390), top: screenWidth * (31 / 390)),
                  child: Row(
                    children: [
                      Container(width: 30, height: 30, color: Colors.white),
                      Padding(
                        padding: EdgeInsets.only(right: screenWidth * (8 / 390), left: screenWidth * (66 / 390)),
                        child: Container(width: 150, height: 20, color: Colors.white),
                      ),
                      Container(width: 74, height: 35, color: Colors.white),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * (23 / 844), bottom: screenHeight * (11 / 844), left: screenWidth * (14 / 390), right: screenWidth * (14 / 390)),
                  child: Container(
                    width: screenWidth * (362 / 390),
                    height: 50,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * (14 / 390), right: screenWidth * (14 / 390)),
                  child: Container(
                    width: screenWidth * (362 / 390),
                    height: 200,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * (200 / 390), right: screenWidth * (30 / 390), top: screenHeight * (37 / 844), bottom: screenHeight * (90 / 844)),
                  child: Container(
                    width: screenWidth * (160 / 390),
                    height: screenHeight * (40 / 844),
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
}
