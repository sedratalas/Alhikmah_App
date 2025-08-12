import 'package:alhekmah_app/screen/sign_up/widget/custum_buttom.dart';
import 'package:flutter/material.dart';

import '../../core/utils/color_manager.dart';

class SignupStep3Screen extends StatelessWidget {
  SignupStep3Screen({super.key});
  late double screenWidth;
  late double screenHeight;
  @override
  Widget build(BuildContext context) {
    screenWidth =MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Container(
        width: screenWidth*(350/390),
        height: screenHeight*(700/840),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:  EdgeInsets.only(left: screenWidth*(123/390),right: screenWidth*(118/390), top: screenHeight*(40/840), bottom: screenHeight*(39/840),),
              child: Text("إنشاء الحساب", style: TextStyle(fontFamily: "Cairo", fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),),
            ),
            Padding(
              padding:  EdgeInsets.only(left: screenWidth*(56/390),right: screenWidth*(56/390),bottom: screenHeight*(54*840)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("إدخال الرمز الخاص",style: TextStyle(fontFamily: "Cairo", fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.red,decoration: TextDecoration.underline,decorationColor: AppColors.red,),),
                  SizedBox(width: screenWidth*(21/390)),
                  Text("منتسب لمعهد ما ؟", style: TextStyle(fontFamily: "Cairo", fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),),
                ],
              ),
            ),
            GestureDetector(
              child: Padding(
                padding:  EdgeInsets.only(left: screenWidth*(19/390),right: screenHeight*(19/390) ),
                child: CustomButton(
                  text: Text("إنشاء الحساب", style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600,fontFamily: "Cairo"),),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
