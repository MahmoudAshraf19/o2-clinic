import '../../../../../../common/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../controllers/doctor_login_controller.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';

class DoctorLoginScreen extends GetView<DoctorLoginController> {
  const DoctorLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppColors.white : AppColors.brandBlue;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryColor,
          ),
          onPressed: () => Get.back(),
        ),
      ),
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
                      width: 130,
                    ),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    AppLocalizations.of(context)!.doctorLogin,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    AppLocalizations.of(context)!.welcomeBackDoctor,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? AppColors.white70
                          : AppColors.brandBlue.withValues(alpha: 0.7),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Email Label
                  Text(
                    AppLocalizations.of(context)!.email,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  _inputField(
                    controller: controller.email,
                    hint: 'Email Address',
                    iconPath: 'assets/icons/mail.png',
                    isDarkMode: isDarkMode,
                  ),

                  const SizedBox(height: 20),

                  // Password Label
                  Text(
                    AppLocalizations.of(context)!.password,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Obx(
                    () => _inputField(
                      controller: controller.password,
                      hint: 'Password',
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
                          color: isDarkMode
                              ? AppColors.white54
                              : AppColors.brandBlue.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ================= LOGIN BUTTON =================
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: CommonButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.login,
                        text: AppLocalizations.of(context)!.login,
                        type: CommonButtonType.primary,
                        backgroundColor: AppColors.brandBlue,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        borderRadius: BorderRadius.circular(28),
                        isLoading: controller.isLoading.value,
                        icon: Directionality.of(context) == TextDirection.rtl
                            ? Icons.arrow_back_rounded
                            : Icons.arrow_forward_rounded,
                        iconColor: AppColors.white,
                        iconPosition: IconPosition.end,
                        textStyle: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= INPUT =================

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required String iconPath,
    required bool isDarkMode,
    bool obscure = false,
    Widget? suffix,
  }) {
    final iconColor = isDarkMode
        ? AppColors.white54
        : AppColors.brandBlue.withValues(alpha: 0.5);

    return CommonTextField(
      controller: controller,
      obscureText: obscure,
      hint: hint,
      prefixWidget: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Image.asset(iconPath, width: 20, height: 20, color: iconColor),
      ),
      suffixWidget: suffix,
    );
  }
}
