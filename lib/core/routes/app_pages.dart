import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/navigation/bindings/navigation_binding.dart';
import '../../core/navigation/views/navigation_shell.dart';
import '../../features/doctors/presentation/screens/all_doctors_page.dart';
import '../../features/auth/presentation/bindings/login_binding.dart';
import '../../features/auth/presentation/bindings/register_binding.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/doctors/presentation/bindings/doctor_profile_binding.dart';
import '../../features/doctors/presentation/bindings/doctors_binding.dart';
import '../../features/doctors/data/models/doctor_model.dart';
import '../../features/doctors/presentation/screens/doctor_profile_screen.dart';
import '../../features/doctors/presentation/screens/doctors_screen.dart';
import '../../features/onboarding/presentation/bindings/onboarding_binding.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/services/data/models/fs_specialized_service_model.dart';
import '../../features/services/presentation/screens/department_doctor_screen.dart';
import '../../features/splash/presentation/bindings/splash_binding.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

import '../../features/auth/presentation/bindings/doctor_login_binding.dart';
import '../../features/auth/presentation/screens/doctor_login_screen.dart';
import '../../features/doctor_dashboard/presentation/bindings/doctor_navigation_binding.dart';
import '../../features/doctor_dashboard/presentation/screens/doctor_navigation_shell.dart';
import '../../features/chat_support/presentation/screens/radiology_chat_screen.dart';
import 'app_routes.dart';
import 'package:o2_clinic/common/widgets/common_empty_state.dart';

class AppPages {
  AppPages._();

  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: '/',
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),

    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.mainNavigation,
      page: () => const NavigationShell(),
      binding: NavigationBinding(),
    ),
    GetPage(
      name: AppRoutes.doctors,
      page: () => const DoctorsScreen(),
      binding: DoctorsBinding(),
    ),
    GetPage(
      name: AppRoutes.doctorProfile,
      page: () {
        // Get the doctor data passed as argument
        final doctor = Get.arguments as DoctorModel?;
        if (doctor == null) {
          // Return a placeholder if no doctor data is passed
          return Scaffold(
            appBar: AppBar(title: const Text('Doctor Profile')),
            body: const CommonEmptyState(title: 'Doctor data not found'),
          );
        }
        return DoctorProfileScreen(doctor: doctor);
      },
      binding: DoctorProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.departmentDoctors,
      page: () {
        // Get the department data passed as argument
        final department = Get.arguments as SpecializedServiceModel?;
        if (department == null) {
          // Return a placeholder if no department data is passed
          return Scaffold(
            appBar: AppBar(title: const Text('Department Doctors')),
            body: const CommonEmptyState(title: 'Department data not found'),
          );
        }
        return DepartmentDoctorScreen(department: department);
      },
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.allDoctors,
      page: () => const AllDoctorsPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.doctorLogin,
      page: () => const DoctorLoginScreen(),
      binding: DoctorLoginBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.doctorNavigation,
      page: () => const DoctorNavigationShell(),
      binding: DoctorNavigationBinding(),
    ),
    GetPage(
      name: AppRoutes.radiologyChat,
      page: () => RadiologyChatScreen(
        bookingId: Get.arguments?['bookingId'] ?? '',
        serviceName: Get.arguments?['serviceName'] ?? '',
      ),
    ),
  ];
}
