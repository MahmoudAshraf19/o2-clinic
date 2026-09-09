import 'package:flutter/material.dart';

import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../widgets/doctor_home_top_cover.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const DoctorHomeTopCover(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.doctorHome, 
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
