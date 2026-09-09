import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';
import '../widgets/splash_background.dart';
import '../widgets/splash_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The controller is registered through SplashBinding.
    Get.find<SplashController>();

    return Scaffold(
      body: Stack(
        children: [
          const SplashBackground(),
          SafeArea(
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.85, end: 1.0),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(scale: value, child: child),
                  );
                },
                child: const SplashLogo(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
