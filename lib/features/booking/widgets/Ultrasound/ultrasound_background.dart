// lib/features/booking/widgets/Ultrasound/ultrasound_background.dart

import 'package:flutter/material.dart';

class UltrasoundBackground extends StatelessWidget {
  const UltrasoundBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffF6FAF8), Color(0xffF4F7FC)],
          ),
        ),
      ),
    );
  }
}
