import 'package:flutter/material.dart';

import 'package:o2_clinic/l10n/app_localizations.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)!.doctorProfile, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    );
  }
}
