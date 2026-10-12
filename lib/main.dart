import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:o2_clinic/core/localization/locale_controller.dart';

import 'core/routes/app_pages.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'common/controllers/app_constants_controller.dart';
import 'common/controllers/global_auth_controller.dart';
import 'features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:device_preview/device_preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'firebase_options.dart';

Future<void> main() async {
  try {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: binding);
    await initializeDateFormatting();

    if (kIsWeb) {
      usePathUrlStrategy();
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await NotificationService.instance.init();

    final prefs = await SharedPreferences.getInstance();
    String? savedLanguageCode = prefs.getString('language_code');
    String? savedThemeString = prefs.getString('theme_mode');

    if (savedLanguageCode == null || savedThemeString == null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('app_constants')
            .doc('default')
            .get()
            .timeout(const Duration(seconds: 3));
        if (doc.exists) {
          final data = doc.data()!;
          if (savedLanguageCode == null) {
            final isAr = data['is_ar_default_language'] ?? false;
            savedLanguageCode = isAr ? 'ar' : 'en';
            await prefs.setString('language_code', savedLanguageCode);
          }
          if (savedThemeString == null) {
            final isLight = data['is_light_theme_default'] ?? true;
            savedThemeString = isLight ? 'light' : 'dark';
            await prefs.setString('theme_mode', savedThemeString);
          }
        }
      } catch (e) {
        debugPrint('Failed to load default constants: $e');
      }
    }
    
    savedLanguageCode ??= 'en';
    savedThemeString ??= 'light';

    final ThemeMode initialThemeMode = savedThemeString == 'dark' ? ThemeMode.dark : ThemeMode.light;

    Get.put(LocaleController(savedLanguageCode), permanent: true);

    Get.put(AppConstantsController(), permanent: true);
    Get.put(GlobalAuthController(), permanent: true);
    Get.put(NotificationsController(), permanent: true);

    runApp(
      DevicePreview(
        enabled: kIsWeb && !kReleaseMode,
        builder: (context) => O2ClinicApp(initialThemeMode: initialThemeMode),
      ),
    );
  } catch (e) {
    FlutterNativeSplash.remove();
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Error: $e'))),
      ),
    );
  }
}

class O2ClinicApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  
  const O2ClinicApp({super.key, required this.initialThemeMode});

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
            child: SafeArea(
              top: false,
              bottom: true,
              child: devicePreviewChild,
            ),
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
          cardColor: baseTheme.cardColor,
          cardTheme: baseTheme.cardTheme,
          inputDecorationTheme: baseTheme.inputDecorationTheme,
          elevatedButtonTheme: baseTheme.elevatedButtonTheme,
          outlinedButtonTheme: baseTheme.outlinedButtonTheme,
          bottomNavigationBarTheme: baseTheme.bottomNavigationBarTheme,
        ),
        darkTheme: ThemeData(
          useMaterial3: AppTheme.darkTheme.useMaterial3,
          fontFamily: activeFontFamily,
          colorScheme: AppTheme.darkTheme.colorScheme,
          textTheme: AppTheme.darkTheme.textTheme.apply(
            fontFamily: activeFontFamily,
          ),
          scaffoldBackgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
          primaryColor: AppTheme.darkTheme.primaryColor,
          appBarTheme: AppTheme.darkTheme.appBarTheme,
          cardColor: AppTheme.darkTheme.cardColor,
          cardTheme: AppTheme.darkTheme.cardTheme,
          inputDecorationTheme: AppTheme.darkTheme.inputDecorationTheme,
          elevatedButtonTheme: AppTheme.darkTheme.elevatedButtonTheme,
          outlinedButtonTheme: AppTheme.darkTheme.outlinedButtonTheme,
          bottomNavigationBarTheme: AppTheme.darkTheme.bottomNavigationBarTheme,
        ),
        themeMode: initialThemeMode,
        initialRoute: '/',
        getPages: AppPages.pages,
        defaultTransition: Transition.cupertino,
        transitionDuration: const Duration(milliseconds: 300),
        smartManagement: SmartManagement.onlyBuilder,
      );
    });
  }
}
