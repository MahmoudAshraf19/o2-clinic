import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';

import '../controllers/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _bgAsset = 'assets/images/onboarding/splash.png';
  static const _logoAsset =
      'assets/images/logos/O2_Clinic_Logo_without_background.png';

  late final AnimationController _anim;
  late final Animation<double> _bgOpacity;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    Get.find<SplashController>(); // registered through SplashBinding

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _bgOpacity = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _logoOpacity = CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(_logoOpacity);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _prepareAndPlay();
  }

  Future<void> _prepareAndPlay() async {
    try {
      await Future.wait([
        precacheImage(const AssetImage(_bgAsset), context),
        precacheImage(const AssetImage(_logoAsset), context),
      ]);
    } catch (_) {}

    if (!mounted) return;

    await WidgetsBinding.instance.endOfFrame;
    FlutterNativeSplash.remove();

    if (!mounted) return;
    await _anim.forward();

    if (!mounted) return;
    Get.find<SplashController>().start();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _bgOpacity,
              child: Image.asset(_bgAsset, fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _logoOpacity,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Image.asset(_logoAsset, width: 220),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}