import 'package:flutter/material.dart';

import '../widgets/doctor_home_top_cover.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/next_patient_widget.dart';
import '../widgets/past_appointments_widget.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          const DoctorHomeTopCover(),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const SliverToBoxAdapter(child: QuickActionsWidget()),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          const SliverToBoxAdapter(child: NextPatientWidget()),
          const SliverToBoxAdapter(child: PastAppointmentsWidget()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
