import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/welcome_controller.dart';
import '../widgets/social_auth_buttons.dart';
import '../widgets/welcome_actions.dart';
import '../widgets/welcome_background.dart';
import '../widgets/welcome_hero.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WelcomeController controller = Get.find<WelcomeController>();

    return Scaffold(
      body: Stack(
        children: [
          const WelcomeBackground(),
          SafeArea(
            child: Column(
              children: [
                // Top bar.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00685F).withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.air,
                              color: Color(0xFF00685F),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context)!.o2Clinic,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF00685F),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.help_outline,
                          color: Color(0xFF6E7977),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main content.
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        const WelcomeHero(),
                        const SizedBox(height: 28),
                        WelcomeActions(controller: controller),
                        const SizedBox(height: 24),
                        const SocialAuthButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

