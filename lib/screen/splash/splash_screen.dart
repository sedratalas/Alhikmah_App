import 'package:alhekmah_app/screen/sign_up/signup_step1_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _widthAnimation = TweenSequence([
      TweenSequenceItem(tween: ConstantTween<double>(50), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 50, end: 71), weight: 35),
      TweenSequenceItem(tween: Tween<double>(begin: 71, end: 50), weight: 35),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _heightAnimation = TweenSequence([
      TweenSequenceItem(tween: ConstantTween<double>(46), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 46, end: 74), weight: 35),
      TweenSequenceItem(tween: Tween<double>(begin: 74, end: 46), weight: 35),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SignupStep1Screen()));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003C46),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SizedBox(
              width: _widthAnimation.value,
              height: _heightAnimation.value,
              child: Image.asset(
                "assets/images/lantern 1.png",
                fit: BoxFit.contain,
              ),
            );
          },
        ),
      ),
    );
  }
}
