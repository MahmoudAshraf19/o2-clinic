import '../../../../common/widgets/common_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/login_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Logic for showing Apple button
    final showApple = kIsWeb || Theme.of(context).platform != TargetPlatform.android;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/logos/O₂_Clinic_Logo_without_background.png',
                      width: 140,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Welcome Back
                  Text(
                    l10n.welcomeBack,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDarkMode ? Colors.white : AppColors.brandBlue,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sign in to continue
                  Text(
                    l10n.loginToContinueYourMedical, 
                    textAlign: TextAlign.start,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white70 : AppColors.brandBlue.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Field Label
                  Text(
                    l10n.emailOrPhone,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : AppColors.brandBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: controller.email,
                    hint: l10n.emailHint,
                    iconPath: 'assets/icons/mail.png',
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 20),

                  // Password Field Label
                  Text(
                    l10n.password,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : AppColors.brandBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => _inputField(
                      controller: controller.password,
                      hint: l10n.passwordHint,
                      iconPath: 'assets/icons/padlock.png',
                      isDarkMode: isDarkMode,
                      obscure: controller.obscurePassword.value,
                      suffix: IconButton(
                        splashRadius: 20,
                        onPressed: () => controller.obscurePassword.toggle(),
                        icon: Image.asset(
                          controller.obscurePassword.value
                              ? 'assets/icons/hidden.png'
                              : 'assets/icons/eye.png',
                          width: 22,
                          height: 22,
                          color: isDarkMode ? Colors.white54 : AppColors.brandBlue.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Forgot Password
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        l10n.forgotPassword,
                        style: GoogleFonts.cairo(
                          color: AppColors.vibrantCyan,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Log In Button
                  Obx(
                    () => SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.login,
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: isDarkMode ? Colors.white24 : Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.or,
                          style: GoogleFonts.cairo(
                            color: isDarkMode ? Colors.white54 : AppColors.brandBlue.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: isDarkMode ? Colors.white24 : Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Google Button
                  _socialButton(
                    text: l10n.continueWithGoogle,
                    iconPath: 'assets/icons/google.png',
                    isDarkMode: isDarkMode,
                    onPressed: () {},
                  ),

                  // Apple Button (conditionally)
                  if (showApple) ...[
                    const SizedBox(height: 16),
                    _socialButton(
                      text: l10n.continueWithApple,
                      iconPath: 'assets/icons/apple-logo.png',
                      isDarkMode: isDarkMode,
                      onPressed: () {}, 
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${l10n.dontHaveAnAccount} ',
                        style: GoogleFonts.cairo(
                          color: isDarkMode ? Colors.white70 : AppColors.brandBlue.withValues(alpha: 0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.register);
                        },
                        child: Text(
                          l10n.signUp,
                          style: GoogleFonts.cairo(
                            color: AppColors.vibrantCyan,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Bottom buttons (Doctor / Guest) stacked
                  _outlinedButton(
                    text: l10n.loginAsDoctor,
                    isDarkMode: isDarkMode,
                    onPressed: () {
                      Get.toNamed(AppRoutes.doctorLogin);
                    },
                  ),
                  const SizedBox(height: 16),
                  _outlinedButton(
                    text: l10n.continueAsGuest,
                    isDarkMode: isDarkMode,
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('user_role', 'guest');
                      Get.offAllNamed(AppRoutes.mainNavigation);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required String iconPath,
    required bool isDarkMode,
    bool obscure = false,
    Widget? suffix,
  }) {
    final iconColor = isDarkMode ? Colors.white54 : AppColors.brandBlue.withValues(alpha: 0.5);

    return CommonTextField(
      controller: controller,
      obscureText: obscure,
      hint: hint,
      prefixWidget: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Image.asset(
          iconPath,
          width: 20,
          height: 20,
          color: iconColor,
        ),
      ),
      suffixWidget: suffix,
    );
  }

  Widget _socialButton({
    required String text,
    required String iconPath,
    required bool isDarkMode,
    required VoidCallback onPressed,
  }) {
    // Determine if the icon should be colored dynamically (like apple logo in dark mode) 
    // or kept original (like google logo). We'll assume google.png is full color, 
    // but apple-logo.png needs to be white in dark mode.
    Color? imageColor;
    if (iconPath.contains('apple')) {
      imageColor = isDarkMode ? Colors.white : Colors.black;
    }

    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDarkMode ? Colors.white38 : AppColors.brandBlue, 
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: isDarkMode ? Colors.transparent : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 24,
              height: 24,
              color: imageColor,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : AppColors.brandBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _outlinedButton({
    required String text,
    required bool isDarkMode,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDarkMode ? Colors.white38 : AppColors.brandBlue.withValues(alpha: 0.5), 
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.transparent,
        ),
        child: Text(
          text,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white70 : AppColors.brandBlue,
          ),
        ),
      ),
    );
  }
}

