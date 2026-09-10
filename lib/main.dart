import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:o2_clinic/core/localization/locale_controller.dart';

import 'core/routes/app_pages.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'common/controllers/app_constants_controller.dart';
import 'common/controllers/global_auth_controller.dart';
import 'features/notifications/controllers/notifications_controller.dart';
import 'package:device_preview/device_preview.dart';
import 'firebase_options.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting();

    if (kIsWeb) {
      usePathUrlStrategy();
    }

    print('🚀 Starting Initialization...');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    await NotificationService.instance.init();

    print('✅ Notification Service initialized');

    final prefs = await SharedPreferences.getInstance();
    final String savedLanguageCode = prefs.getString('language_code') ?? 'en';
    Get.put(LocaleController(savedLanguageCode), permanent: true);

    Get.put(AppConstantsController(), permanent: true);
    Get.put(GlobalAuthController(), permanent: true);
    Get.put(NotificationsController(), permanent: true);
    print('✅ AppConstantsController initialized');

    runApp(
      DevicePreview(
        enabled: kIsWeb && !kReleaseMode,
        builder: (context) => const O2ClinicApp(),
      ),
    );
  } catch (e, stack) {
    print('❌ CRITICAL ERROR DURING INIT: $e');
    print(stack);
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}

class O2ClinicApp extends StatelessWidget {
  const O2ClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData baseTheme = AppTheme.lightTheme;
    final localeController = Get.find<LocaleController>();

    return Obx(() {
      final isArabic = localeController.currentLanguageCode == 'ar';
      final activeFontFamily = isArabic ? 'IBMPlexSansArabic' : 'Manrope';

      return GetMaterialApp(
        locale: localeController.locale,
        builder: (context, child) {
          final devicePreviewChild = DevicePreview.appBuilder(context, child);
          return DefaultTextStyle.merge(
            style: TextStyle(
              fontFamilyFallback: isArabic ? const ['IBMPlexSansArabic'] : null,
            ),
            child: devicePreviewChild,
          );
        },
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        title: 'O2 Clinic',
        theme: ThemeData(
          useMaterial3: baseTheme.useMaterial3,
          fontFamily: activeFontFamily,
          colorScheme: baseTheme.colorScheme,
          textTheme: baseTheme.textTheme.apply(fontFamily: activeFontFamily),
          scaffoldBackgroundColor: baseTheme.scaffoldBackgroundColor,
          primaryColor: baseTheme.primaryColor,
          appBarTheme: baseTheme.appBarTheme,
          cardTheme: baseTheme.cardTheme,
          inputDecorationTheme: baseTheme.inputDecorationTheme,
          elevatedButtonTheme: baseTheme.elevatedButtonTheme,
          outlinedButtonTheme: baseTheme.outlinedButtonTheme,
          bottomNavigationBarTheme: baseTheme.bottomNavigationBarTheme,
        ),
        initialRoute: '/',
        getPages: AppPages.pages,
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        smartManagement: SmartManagement.onlyBuilder,
      );
    });
  }
}
