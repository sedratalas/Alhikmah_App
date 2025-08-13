import 'package:alhekmah_app/core/utils/asset_manager.dart';
import 'package:alhekmah_app/core/utils/color_manager.dart';
import 'package:alhekmah_app/screen/sign_up/signup_step2_screen.dart';
import 'package:alhekmah_app/screen/sign_up/widget/custum_buttom.dart';
import 'package:flutter/material.dart';

import 'signup_step3_screen.dart';

class SignupStep1Screen extends StatelessWidget {
   SignupStep1Screen({super.key});
  late double screenWidth;
  late double screenHeight;
  @override
  Widget build(BuildContext context) {
    screenWidth =MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: Container(
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
                padding:  EdgeInsets.only(left: screenWidth*(91/390),right: screenWidth*(91/390), top: screenHeight*(40/840), bottom: screenHeight*(35/840),),
                child: Text("جاهز لتعلم المزيد ؟", style: TextStyle(fontFamily: "Cairo", fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),),
              ),
              Padding(
              padding:  EdgeInsets.only(left: screenWidth*(75/390),right: screenWidth*(75/390), bottom: screenHeight*(62/840),),
                child: Image.asset("assets/icons/781a79800560828fb4a659849ea917ba5e6f13ac.gif"),
              ),
              Padding(
                padding:  EdgeInsets.only(left: screenWidth*(19/390),right: screenWidth*(19/390), bottom: screenHeight*(27/840),),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> SignupStep2Screen())
                    );
                  },
                  child: CustomButton(
                    text: Text("إنشاء حساب", style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600,fontFamily: "Cairo"),),
                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.only(left: screenWidth*(53/390),right: screenWidth*(40/390), bottom: screenHeight*(18/840),),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("تسجيل دخول",style: TextStyle(fontFamily: "Cairo", fontSize: 17, fontWeight: FontWeight.w400, color: AppColors.red,decoration: TextDecoration.underline,decorationColor: AppColors.red,),),
                    SizedBox(width: screenWidth*(21/390)),
                    Text("لديك حساب بالفعل؟ ", style: TextStyle(fontFamily: "Cairo", fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),),

                  ],
                ),
              ),
              Padding(
                padding:  EdgeInsets.only(left: screenWidth*(63/390),right: screenWidth*(63/390), bottom: screenHeight*(24/840)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Divider(
                      color: Color(0xff8C8C8C),
                      height: 1,
                      thickness: 10,
                    ),
                    Text("أو", style: TextStyle(fontFamily: "Cairo", fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xff8C8C8C)),),
                    Divider(
                      color: Color(0xff8C8C8C),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:  EdgeInsets.only(left: screenWidth*(19/390),right: screenWidth*(19/390), bottom: screenHeight*(27/840)),
                child: GestureDetector(
                  child: Container(
                    width: screenWidth*(312/375),
                    height: screenHeight*(54/812),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    child: Center(
                      child: Text("تصفح التطبيق",style: TextStyle(fontFamily: "Cairo", fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.only(left: screenWidth*(53/390),right: screenWidth*(40/390),),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("إدخال الرمز الخاص",style: TextStyle(fontFamily: "Cairo", fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.red,decoration: TextDecoration.underline,decorationColor: AppColors.red,),),
                    SizedBox(width: screenWidth*(21/390)),
                    Text("منتسب لمعهد ما ؟", style: TextStyle(fontFamily: "Cairo", fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
