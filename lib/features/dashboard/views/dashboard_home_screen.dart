import 'package:flutter/material.dart';

import '../widgets/dashboard_discount_banners.dart';
import '../widgets/dashboard_external_link_banners.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_search_bar.dart';
import '../widgets/dashboard_top_doctors.dart';
import '../widgets/dashboard_upcoming_appointment.dart';

class DashboardHomeScreen extends StatelessWidget {
  const DashboardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          DashboardSearchBar(),
          SizedBox(height: 20),
          DiscountBannersSection(),
          SizedBox(height: 24),
          DashboardQuickActions(),
          SizedBox(height: 24),
          ExternalLinkBannersSection(),
          SizedBox(height: 28),
          DashboardTopDoctors(),
          SizedBox(height: 28),
          DashboardUpcomingAppointment(),
        ],
      ),
    );
  }
}