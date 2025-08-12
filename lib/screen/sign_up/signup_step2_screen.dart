import 'package:alhekmah_app/screen/login/login_screen.dart';
import 'package:alhekmah_app/screen/sign_up/bloc/signup_bloc.dart';
import 'package:alhekmah_app/screen/sign_up/widget/custum_buttom.dart';
import 'package:alhekmah_app/screen/sign_up/widget/custum_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/color_manager.dart';
import '../../../model/signup_model.dart';

class SignupStep2Screen extends StatelessWidget {
  SignupStep2Screen({super.key});
  late double screenWidth;
  late double screenHeight;
  late TextEditingController userNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  Widget build(BuildContext context) {
    screenWidth =MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
    userNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
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
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding:  EdgeInsets.only(left: screenWidth*(123/390),right: screenWidth*(118/390), top: screenHeight*(40/840), bottom: screenHeight*(39/840),),
                    child: Text("إنشاء حساب", style: TextStyle(fontFamily: "Cairo", fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(left: screenWidth*(25/390), right: screenWidth*(25/390),bottom: screenHeight*(33/840) ,),
                    child: Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("الاسم", style: TextStyle(fontFamily: "Cairo", fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.gray),),
                        CustomTextField(controller: userNameController),
                        Text("البريد الإلكتروني", style: TextStyle(fontFamily: "Cairo", fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.gray),),
                        CustomTextField(controller: emailController),
                        Text("كلمة المرور", style: TextStyle(fontFamily: "Cairo", fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.gray),),
                        CustomTextField(controller: passwordController),
                      ],
                    ),
                  ),

                  Padding(
                    padding:  EdgeInsets.only(left: screenWidth*(50/390),right: screenWidth*(50/390),),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("إدخال الرمز الخاص",style: TextStyle(fontFamily: "Cairo", fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.red,decoration: TextDecoration.underline,decorationColor: AppColors.red,),),
                        SizedBox(width: screenWidth*(21/390)),
                        Text("منتسب لمعهد ما ؟", style: TextStyle(fontFamily: "Cairo", fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),),
                      ],
                    ),
                  ),
                  BlocConsumer<SignupBloc, SignupState>(
                    listener: (context, state) {
                      if(state is SignupSuccess){
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("تم إنشاء الحساب بنجاح!"), backgroundColor: Colors.green),
                        );
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginScreen(),
                        )
                        );
                      } else if (state is SignupFailed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("فشل في إنشاء الحساب. الرجاء المحاولة مرة أخرى."), backgroundColor: Colors.red),
                        );
                      }
                    },
                    builder: (context, state) {
                      return GestureDetector(
                        onTap: (){
                          if(state is! SignupLoading){
                            BlocProvider.of<SignupBloc>(context).add(
                              TrySignup(
                                signupModel: SignupModel(
                                  username: userNameController.text,
                                  email: emailController.text,
                                  password: passwordController.text,
                                ),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding:  EdgeInsets.only(left: screenWidth*(19/390),right: screenWidth*(19/390),top: screenHeight*(56/840)),
                          child: CustomButton(
                            text: state is SignupLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text("إنشاء الحساب", style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600,fontFamily: "Cairo"),),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}