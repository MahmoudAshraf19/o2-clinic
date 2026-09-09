import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/navigation/bindings/navigation_binding.dart';
import '../../core/navigation/views/navigation_shell.dart';
import '../../features/all_doctors/presentation/pages/all_doctors_page.dart';
import '../../features/auth/bindings/login_binding.dart';
import '../../features/auth/bindings/register_binding.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';
import '../../features/doctors/bindings/doctor_profile_binding.dart';
import '../../features/doctors/bindings/doctors_binding.dart';
import '../../features/doctors/models/doctor_model.dart';
import '../../features/doctors/views/doctor_profile_screen.dart';
import '../../features/doctors/views/doctors_screen.dart';
import '../../features/onboarding/bindings/onboarding_binding.dart';
import '../../features/onboarding/views/onboarding_screen.dart';
import '../../features/services_firestore/models/specialized_service_model.dart';
import '../../features/services/views/department_doctor_screen.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/views/splash_screen.dart';
import '../../features/welcome/bindings/welcome_binding.dart';
import '../../features/welcome/views/welcome_screen.dart';
import '../../features/auth/bindings/doctor_login_binding.dart';
import '../../features/auth/views/doctor_login_screen.dart';
import '../../features/doctor_dashboard/bindings/doctor_navigation_binding.dart';
import '../../features/doctor_dashboard/views/doctor_navigation_shell.dart';
import 'app_routes.dart';

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
      name: AppRoutes.welcome,
      page: () => const WelcomeScreen(),
      binding: WelcomeBinding(),
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
            body: const Center(child: Text('Doctor data not found')),
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
            body: const Center(child: Text('Department data not found')),
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
  ];
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
