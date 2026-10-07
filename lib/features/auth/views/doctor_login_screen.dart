import '../../../../common/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import '../../../common/widgets/common_button.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../controllers/doctor_login_controller.dart';
import 'package:o2_clinic/core/theme/app_colors.dart';

class DoctorLoginScreen extends GetView<DoctorLoginController> {
  const DoctorLoginScreen({super.key});

  static const primary = AppColors.colorFF00685F;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorFFF4F8F7,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.doctorLogin,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: primary,
                      fontFamily: 'Poppins',
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    AppLocalizations.of(context)!.welcomeBackDoctor,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.grey600,
                      fontFamily: 'Inter',
                    ),
                  ),

                  const SizedBox(height: 34),

                  // ================= CARD =================
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      children: [
                        _inputField(
                          controller: controller.email,
                          hint: 'Email Address',
                          icon: Icons.mail_outline_rounded,
                        ),

                        const SizedBox(height: 18),

                        Obx(
                          () => _inputField(
                            controller: controller.password,
                            hint: 'Password',
                            icon: Icons.lock_outline_rounded,
                            obscure: controller.obscurePassword.value,
                            suffix: IconButton(
                              splashRadius: 20,
                              onPressed: () {
                                controller.obscurePassword.toggle();
                              },
                              icon: Icon(
                                controller.obscurePassword.value
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: AppColors.grey500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ================= FORGOT =================
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              AppLocalizations.of(context)!.forgotPassword,
                              style: const TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ================= LOGIN BUTTON =================
                        Obx(
                          () => CommonButton(
                            text: AppLocalizations.of(context)!.login,
                            onPressed: controller.login,
                            isLoading: controller.isLoading.value,
                            icon: Icons.login_rounded,
                            iconPosition: IconPosition.left,
                            type: CommonButtonType.primary,
                            backgroundColor: primary,
                            borderRadius: BorderRadius.circular(18),
                            width: double.infinity,
                            height: 56,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
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
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return CommonTextField(
      controller: controller,
      obscureText: obscure,
      hint: hint,
      prefixIcon: icon,
      suffixWidget: suffix,
    );
  }
}
