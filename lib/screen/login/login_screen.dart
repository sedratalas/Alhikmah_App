import 'package:alhekmah_app/screen/all_books/all_books_screen.dart';
import 'package:alhekmah_app/screen/login/bloc/login_bloc.dart';
import 'package:alhekmah_app/screen/sign_up/widget/custum_buttom.dart';
import 'package:alhekmah_app/screen/sign_up/widget/custum_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/color_manager.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  late double screenWidth;
  late double screenHeight;
  late TextEditingController userNameController;
  late TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;
    userNameController = TextEditingController();
    passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: Container(
          width: screenWidth * (350 / 390),
          height: screenHeight * (700 / 840),
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
                    padding: EdgeInsets.only(
                      left: screenWidth * (111 / 390),
                      right: screenWidth * (111 / 390),
                      top: screenHeight * (40 / 840),
                      bottom: screenHeight * (127 / 840),
                    ),
                    child: Text(
                      "تسجيل الدخول",
                      style: TextStyle(
                        fontFamily: "Cairo",
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * (25 / 390),
                      right: screenWidth * (25 / 390),
                      bottom: screenHeight * (33 / 840),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "الاسم",
                          style: TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.gray,
                          ),
                        ),
                        CustomTextField(controller: userNameController),
                        Text(
                          "كلمة المرور",
                          style: TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColors.gray,
                          ),
                        ),
                        CustomTextField(controller: passwordController),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: screenWidth * (50 / 390),
                      right: screenWidth * (50 / 390),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "إدخال الرمز الخاص",
                          style: TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.red,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.red,
                          ),
                        ),
                        SizedBox(width: screenWidth * (21 / 390)),
                        Text(
                          "منتسب لمعهد ما ؟",
                          style: TextStyle(
                            fontFamily: "Cairo",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BlocConsumer<LoginBloc, LoginState>(
                    listener: (context, state) {
                      if (state is LoginSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("تم تسجيل الدخول بنجاح"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => AllBooksScreen()),
                              (Route<dynamic> route) => false,
                        );
                      } else if (state is LoginFailed) {
                        print(state.message);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("فشل في تسجيل الدخول. ${state.message}"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return GestureDetector(
                        onTap: () {
                          if (state is! LoginLoading) {
                            BlocProvider.of<LoginBloc>(context).add(
                              TryLogin(
                                username: userNameController.text,
                                password: passwordController.text,
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: screenWidth * (19 / 390),
                            right: screenWidth * (19 / 390),
                            top: screenHeight * (56 / 840),
                          ),
                          child: CustomButton(
                            text: state is LoginLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "تسجيل الدخول",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Cairo",
                              ),
                            ),
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