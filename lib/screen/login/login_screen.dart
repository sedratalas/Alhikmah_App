import 'package:flutter/material.dart';

import '../../core/utils/color_manager.dart';
import '../sign_up/widget/custum_buttom.dart';

class LoginScreen extends StatelessWidget {
   LoginScreen({super.key});
   late double screenWidth;
   late double screenHeight;
  @override
  Widget build(BuildContext context) {
    screenWidth =MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Container(
        width: screenWidth*(350/390),
        height: screenHeight*(700/840),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Padding(
              padding:  EdgeInsets.only(left: screenWidth*(19/390),right: screenWidth*(19/390), bottom: screenHeight*(27/840),),
              child: GestureDetector(
                child: CustomButton(
                  text: Text("تسجيل الدخول", style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600,fontFamily: "Cairo"),),
                ),
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(left: screenWidth*(56/390),right: screenWidth*(56/390),bottom: screenHeight*(54*840)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("إعادة تعيين كلمة المرور",style: TextStyle(fontFamily: "Cairo", fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.red,decoration: TextDecoration.underline,decorationColor: AppColors.red,),),
                  SizedBox(width: screenWidth*(21/390)),
                  Text("نسيت كلمة المرور ؟ ", style: TextStyle(fontFamily: "Cairo", fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),),
                ],
              ),
            ),
            GestureDetector(
              child: Padding(
                padding:  EdgeInsets.only(left: screenWidth*(19/390),right: screenHeight*(19/390) ),
                child: CustomButton(
                  text: Text("التالي", style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600,fontFamily: "Cairo"),),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
