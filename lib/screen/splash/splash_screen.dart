import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lanternScaleController;
  late Animation<double> _lanternScale;

  late AnimationController _lanternMoveController;
  late Animation<Offset> _lanternOffset;

  late AnimationController _textFadeController;
  late Animation<double> _textOpacity;

  bool showFirstGradient = true;

  @override
  void initState() {
    super.initState();

    _lanternScaleController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _lanternScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _lanternScaleController,
      curve: Curves.easeInOut,
    ));

    _lanternMoveController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _lanternOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0),
    ).animate(CurvedAnimation(
      parent: _lanternMoveController,
      curve: Curves.easeInOut,
    ));

    _textFadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _textFadeController,
      curve: Curves.easeIn,
    ));

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // المرحلة الأولى: عرض الخلفية الأولى لمدة ثانية
    await Future.delayed(const Duration(seconds: 2));
    setState(() => showFirstGradient = false);

    // المرحلة الثانية: تكبير/تصغير الفانوس
    await _lanternScaleController.forward();

    // المرحلة الثالثة: تحريك الفانوس وظهور النص معاً + تغيير الخلفية
    await Future.wait([
      _lanternMoveController.forward(),
      _textFadeController.forward(),
    ]);
    setState(() => showFirstGradient = true);
  }

  @override
  void dispose() {
    _lanternScaleController.dispose();
    _lanternMoveController.dispose();
    _textFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient1 = const LinearGradient(
      colors: [
        Color(0xFF088395),
        Color(0xFF30A5B0),
        Color(0xffD7FFBB),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final gradient2 = const LinearGradient(
      colors: [Color(0xFF003844), Color(0xFF003844)],
    );

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        decoration: BoxDecoration(
          gradient: showFirstGradient ? gradient1 : gradient2,
        ),
        child: Center(
          child: SlideTransition(
            position: _lanternOffset,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _lanternScale,
                  child: Image.asset(
                    "assets/images/lantern 1.png",
                    width: 80,
                    height: 80,
                  ),
                ),
                const SizedBox(width: 12),
                FadeTransition(
                  opacity: _textOpacity,
                  child: Center(
                    child: Text(
                      "الحكمة",
                      style: const TextStyle(
                        fontFamily: "Cairo",
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
