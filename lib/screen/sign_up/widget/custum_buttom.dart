import 'package:alhekmah_app/core/utils/color_manager.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  CustomButton(
      {Key? key,
        required this.text,
        this.width,
        this.height,
      }) : super(key: key,);
  late double? width;
  double? height;
  Widget text;
  late double ScreenWidth;
  late double ScreenHeight;
  @override
  Widget build(BuildContext context) {
    ScreenWidth = MediaQuery.sizeOf(context).width;
    ScreenHeight = MediaQuery.sizeOf(context).height;
    return Container(
      width: ScreenWidth*(312/375),
      height: ScreenHeight*(54/812),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: text,
      ),
    );
  }
}
