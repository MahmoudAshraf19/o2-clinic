import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The controller is registered through SplashBinding.
    Get.find<SplashController>();
    

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Bottom image with fade-in
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/onboarding/splash.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Center content (Logo + Text)
          SafeArea(
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    // scale goes from 0.85 to 1.0
                    child: Transform.scale(scale: 0.85 + (value * 0.15), child: child),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logos/O₂_Clinic_Logo_without_background.png',
                      width: 220,
                    ),

                    // Push content up slightly to match screenshot
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

