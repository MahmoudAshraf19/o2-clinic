import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/models/dashboard_profile_model.dart';
import '../../profile/widgets/profile_detail_card.dart';
import '../../profile/widgets/profile_header_section.dart';

class PatientProfileScreen extends StatelessWidget {
  final DashboardProfileModel patient;

  const PatientProfileScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 900;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppLocalizations.of(context)!.profile, // fallback
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 16,
                  vertical: isDesktop ? 48 : 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileHeaderSection(user: patient, isDesktop: isDesktop),
                    const SizedBox(height: 32),
                    GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 2 : 1,
                        crossAxisSpacing: isDesktop ? 24 : 16,
                        mainAxisSpacing: isDesktop ? 24 : 16,
                        mainAxisExtent: isDesktop ? 92 : 78,
                      ),
                      children: [
                        ProfileDetailCard(
                          icon: Icons.call_outlined,
                          title: AppLocalizations.of(context)!.phoneNumber,
                          value: patient.phone,
                        ),
                        ProfileDetailCard(
                          icon: Icons.mail_outline,
                          title: AppLocalizations.of(context)!.email,
                          value: patient.email,
                        ),
                        ProfileDetailCard(
                          icon: Icons.person_outline,
                          title: AppLocalizations.of(context)!.gender,
                          value: patient.gender,
                        ),
                        ProfileDetailCard(
                          icon: Icons.event_outlined,
                          title: AppLocalizations.of(context)!.lastVisit,
                          value: patient.lastVisit,
                          subtitle: patient.lastVisitType,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
