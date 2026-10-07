import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/doctors_controller.dart';
import '../widgets/doctor_card.dart';

class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorsController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.white),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Obx(() {
            return ListView(
              children: [
                const SizedBox(height: 10),

                Text(
                  AppLocalizations.of(context)!.chestDiseases,
                  style: AppTextStyles.textTheme.headlineMedium!.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  AppLocalizations.of(
                    context,
                  )!.exceptionalCareFromLeadingSpecialists,
                  style: AppTextStyles.textTheme.bodyMedium,
                ),

                const SizedBox(height: 30),

                if (controller.doctors.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        Image.asset(
                          'assets/images/no_doctors_found.png',
                          width: 250,
                          height: 250,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.noDoctorsFound,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...controller.doctors.map(
                    (doc) => Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: DoctorCard(doctor: doc),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
