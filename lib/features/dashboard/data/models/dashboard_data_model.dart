import 'dashboard_appointment_model.dart';
import 'dashboard_doctor_model.dart';
import 'dashboard_health_chip_model.dart';
import 'dashboard_promo_model.dart';
import 'dashboard_quick_action_model.dart';
import 'dashboard_specialty_model.dart';

class DashboardDataModel {
  final List<DashboardQuickActionModel> quickActions;
  final List<DashboardDoctorModel> topDoctors;
  final DashboardAppointmentModel upcomingAppointment;
  final List<DashboardSpecialtyModel> specialties;
  final List<DashboardHealthChipModel> healthChips;
  final List<DashboardPromoModel> promos;

  const DashboardDataModel({
    required this.quickActions,
    required this.topDoctors,
    required this.upcomingAppointment,
    required this.specialties,
    required this.healthChips,
    required this.promos,
  });
}
