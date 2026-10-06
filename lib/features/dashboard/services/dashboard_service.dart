import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../models/dashboard_appointment_model.dart';
import '../models/dashboard_data_model.dart';
import '../models/dashboard_doctor_model.dart';
import '../models/dashboard_health_chip_model.dart';
import '../models/dashboard_promo_model.dart';
import '../models/dashboard_quick_action_model.dart';
import '../models/dashboard_specialty_model.dart';

class DashboardService {
  Future<DashboardDataModel> getDashboardData() async {
    final isAr = Get.locale?.languageCode == 'ar';
    final isHe = Get.locale?.languageCode == 'he';

    return DashboardDataModel(
      promos: [
        DashboardPromoModel(
          id: 'promo_search',
          title: isAr ? 'ابحث واحجز' : isHe ? 'חפש והזמן' : 'Search & Book',
          subtitle: isAr ? 'ابحث عن الأطباء، العيادات، الأشعة...' : isHe ? 'חפש רופאים, מרפאות, רדיולוגיה...' : 'Find doctors, clinics, radiology...',
          startColor: AppColors.primary,
          endColor: const Color(0xFF005049),
        ),
      ],
      quickActions: [
        DashboardQuickActionModel(
          id: 'location',
          title: isAr ? 'موقعنا' : isHe ? 'המיקום\nשלנו' : 'Our\nLocation',
          imagePath: 'assets/icons/svg_icons/location.svg',
        ),
        DashboardQuickActionModel(
          id: 'doctor',
          title: isAr ? 'ابحث عن\nطبيب' : isHe ? 'חפש\nרופא' : 'Find\nDoctor',
          imagePath: 'assets/icons/svg_icons/search.svg',
        ),
        DashboardQuickActionModel(
          id: 'radiology',
          title: isAr ? 'حجز\nأشعة' : isHe ? 'הזמנת\nרדיולוגיה' : 'Radiology\nBooking',
          imagePath: 'assets/icons/svg_icons/radiology.svg',
        ),
        DashboardQuickActionModel(
          id: 'lab',
          title: isAr ? 'تحاليل\nمخبرية' : isHe ? 'בדיקות\nמעבדה' : 'Lab\nTests',
          imagePath: 'assets/icons/svg_icons/lab.svg',
        ),
        DashboardQuickActionModel(
          id: 'cosmetic',
          title: isAr ? 'حجز\nتجميل' : isHe ? 'הזמנת\nקוסמטיקה' : 'Cosmetic\nBooking',
          imagePath: 'assets/icons/svg_icons/cosmetic.svg',
        ),
        DashboardQuickActionModel(
          id: 'appointments',
          title: isAr ? 'مواعيدي' : isHe ? 'התורים\nשלי' : 'My\nAppointments',
          imagePath: 'assets/icons/svg_icons/my_appointments.svg',
        ),
      ],
      topDoctors: const [
        DashboardDoctorModel(
          id: 'sarah',
          name: 'Dr. Sarah Johnson',
          specialty: 'Dermatology',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCWUghLJB42DPKFCUpftrrhRsnfluyGyuTcM_DCkc71o-b-k0Ajc-9KsAAzj2RKh6T_duUsLRPx_PjxjIOakjdbDP393X6jzNQezEWsfKOw7XOREpE6cWfMQIBF63_sjUskgN8Pypd0TV4p2wpH9ydgdzbKh6vYsS7KufKsITICxx8Qx74IOpNZND5mu9J2OTotr8pSDKrTRu-k8Sw1AbRc6ZCKMlucoXcLZcCYrrkSVSrk0jbMN_Mj5JkX_iTixfhS0Ce_h86m01g',
          rating: 5.0,
        ),
        DashboardDoctorModel(
          id: 'chen',
          name: 'Dr. Michael Chen',
          specialty: 'Orthopedics',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDjvLY20nBEQyCe2axbPtQIRJFtoaRW-cBTEPJhuHqWTXDCCHAzbLN_Y18smjVto83GmL3ctDM1gItLX3L4zvcRFcb3cEW43WJLG46I_7IGpHIhQ_5YKLRkNHb6ST3GyqV7Gkb0_XbCeIl5rX3XxQ_LtLA6KEuDP5Pvmmh4LHxj6QDTPAkuvQ6icEoIysLByFn5ER_Zi-3OaXedrfRNT7k9mFhfBiBtiFjZv9J-NhnsqXKNQdv3p_EESybbJ3zsr96QTbq6Y-USFkg',
          rating: 4.9,
          isHot: true,
        ),
      ],
      upcomingAppointment: const DashboardAppointmentModel(
        id: 'appt_1',
        doctorName: 'Dr. Ahmed Hassan',
        doctorSpecialty: 'Cardiology',
        doctorImageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuB5y_xdeIDWIjS6Nrw2-ixKrmeAniH5p4j_4BPpU513Idrzky18kgv2YK9cyj2HTck29gj5N5rY6SOfjvX6eQRGik1vafVW8mW4hk3CB69dJmMNlIj8YbnYe5MHeFqlScej-L6CBWFqjE01LIlzWhQhrLJh3YI3hh3uGLtU9KYRfvzfAoierxJ3ququvTdnW-uM62NGOaDJehDHvf7d0jPk2SwlTyNsquP01P_8VUD89leg13eTi3Cl_ESSnRvW4nkpjz7hC-Rpg7o',
        label: 'Tomorrow',
        time: '3:30 PM',
        location: 'Wing A',
      ),
      specialties: [
        DashboardSpecialtyModel(
          id: 'chest',
          name: isAr ? 'عيادة الصدرية' : isHe ? 'מרפאת חזה' : 'Chest Clinic',
          description: isAr ? 'اختبارات وظائف الرئة واستشارات' : isHe ? 'בדיקות תפקודי ריאות וייעוצים' : 'Pulmonary function tests & consults',
          icon: Icons.air_rounded,
          isAvailable: true,
        ),
        DashboardSpecialtyModel(
          id: 'cardiology',
          name: isAr ? 'عيادة القلب' : isHe ? 'קרדיולוגיה' : 'Cardiology',
          description: isAr ? 'تخطيط القلب وصحة القلب' : isHe ? 'אק"ג ובריאות הלב' : 'ECG & Heart health',
          icon: Icons.favorite_rounded,
          isAvailable: false,
          nextSlotLabel: isAr ? 'الأربعاء، 9:00 ص' : isHe ? 'רביעי, 9:00 בבוקר' : 'Wed, 9:00 AM',
        ),
      ],
      healthChips: [
        DashboardHealthChipModel(
          id: 'water',
          title: isAr ? 'اشرب ماء' : isHe ? 'שתה מים' : 'Drink Water',
          icon: Icons.water_drop_rounded,
          backgroundColor: const Color(0xFFEAF9F7),
          foregroundColor: const Color(0xFF3BA99C),
          borderColor: const Color(0xFF8CF5E6),
        ),
        DashboardHealthChipModel(
          id: 'steps',
          title: isAr ? '10 آلاف خطوة' : isHe ? '10k צעדים' : '10k Steps',
          icon: Icons.directions_walk_rounded,
          backgroundColor: const Color(0xFFF0FAF9),
          foregroundColor: const Color(0xFF006860),
          borderColor: const Color(0xFF8DF4E8),
        ),
        DashboardHealthChipModel(
          id: 'tips',
          title: isAr ? 'المزيد من النصائح' : isHe ? 'טיפים נוספים' : 'More Tips',
          icon: Icons.lightbulb_rounded,
          backgroundColor: const Color(0xFFE6E9E8),
          foregroundColor: const Color(0xFF3E4947),
          borderColor: const Color(0xFFE6E9E8),
        ),
      ],
    );
  }
}
