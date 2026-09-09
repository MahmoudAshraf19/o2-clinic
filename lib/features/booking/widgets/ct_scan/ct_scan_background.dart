import 'package:flutter/material.dart';

class CTScanBackground extends StatelessWidget {
  const CTScanBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xffF9FBFF),
                    Color(0xffF4F7FC),
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
