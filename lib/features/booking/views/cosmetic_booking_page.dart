import 'dart:ui';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../chat_support/widgets/support_chat_widgets.dart';
import '../../services/models/cosmetic_category_model.dart';
import '../controllers/cosmetic_booking_controller.dart';
import 'cosmetic_confirm_screen.dart';

import 'package:o2_clinic/l10n/app_localizations.dart';

class CosmeticBookingPage extends StatelessWidget {
  final CosmeticCategoryModel model;

  const CosmeticBookingPage({super.key, required this.model});

  String _t(String text) {
    final lang = Get.locale?.languageCode ?? 'en';
    if (lang == 'ar') {
      switch (text) {
        case "Booking": return "الحجز";
        case "Select Date & Time": return "اختر التاريخ والوقت";
        case "Cosmetic Department": return "قسم التجميل";
        case "Available Days": return "الأيام المتاحة";
        case "No available dates": return "لا توجد أيام متاحة";
        case "Time": return "الوقت";
        case "No available time slots.": return "لا توجد مواعيد متاحة.";
        case "Book Appointment": return "احجز الموعد";
        case "Selection Required": return "مطلوب الاختيار";
        case "Please select a date first": return "الرجاء تحديد التاريخ أولا";
        case "Please select a time first": return "الرجاء تحديد الوقت أولا";
      }
    } else if (lang == 'he') {
      switch (text) {
        case "Booking": return "הזמנה";
        case "Select Date & Time": return "בחר תאריך ושעה";
        case "Cosmetic Department": return "מחלקת קוסמטיקה";
        case "Available Days": return "ימים פנויים";
        case "No available dates": return "אין תאריכים פנויים";
        case "Time": return "זמן";
        case "No available time slots.": return "אין זמנים פנויים.";
        case "Book Appointment": return "הזמן תור";
        case "Selection Required": return "נדרשת בחירה";
        case "Please select a date first": return "נא לבחור תאריך תחילה";
        case "Please select a time first": return "נא לבחור זמן תחילה";
      }
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CosmeticAppointmentBookingController(model),
      tag: model.id,
    );

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildHeader(context),
              const SizedBox(height: 8),
              if (FirebaseAuth.instance.currentUser == null) ...[
                const Spacer(),
                const SupportAuthPrompt(),
                const Spacer(),
              ] else ...[
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _serviceCard(context),
                      const SizedBox(height: 24),
                      _daysSection(context, controller),
                      const SizedBox(height: 24),
                      _timeSection(context, controller),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                _bookButton(context, controller),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _t("Booking"),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontFamily: AppFonts.dancingScript,
                letterSpacing: 0.4,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _t("Select Date & Time"),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary.withValues(alpha: 0.75),
                fontWeight: FontWeight.w500,
                
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _serviceCard(BuildContext context) {
    final langCode = Get.locale?.languageCode ?? 'en';
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: model.image.isNotEmpty 
            ? CachedImageWidget(imageUrl: 
                model.image,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackAvatar(),
              )
            : _fallbackAvatar(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.getName(langCode),
                  style: const TextStyle(
                    
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _t("Cosmetic Department"),
                  style: TextStyle(
                    
                    color: AppColors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackAvatar() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(
        model.getBadgeIcon(),
        color: AppColors.primary,
        size: 28,
      ),
    );
  }

  String _getDayShort(int weekday) {
    final lang = Get.locale?.languageCode ?? 'en';
    if (lang == 'ar') {
      const daysAr = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
      return daysAr[weekday - 1];
    } else if (lang == 'he') {
      const daysHe = ['שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת', 'ראשון'];
      return daysHe[weekday - 1];
    }
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  Widget _daysSection(BuildContext context, CosmeticAppointmentBookingController controller) {
    return Obx(() {
      final selected = controller.selectedDate.value;
      final dates = controller.availableDates;
      final isAr = Get.locale?.languageCode == 'ar';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                _t("Available Days"),
                style: TextStyle(
                  fontFamily: AppFonts.dancingScript,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (dates.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                _t("No available dates"),
                style: TextStyle(
                  
                  color: AppColors.grey,
                ),
              ),
            )
          else
            SizedBox(
              height: 92,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (_, i) {
                  final date = dates[i];
                  final isSelected = selected == date;

                  return GestureDetector(
                    onTap: () => controller.selectDate(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(right: isAr ? 0 : 10, left: isAr ? 10 : 0),
                      width: 72,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getDayShort(date.weekday),
                            style: TextStyle(
                              
                              fontSize: 11,
                              letterSpacing: 1.5,
                              color: isSelected ? Colors.white : AppColors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${date.day}",
                            style: TextStyle(
                              
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    });
  }

  Widget _timeSection(BuildContext context, CosmeticAppointmentBookingController controller) {
    return Obx(() {
      if (controller.selectedDate.value == null) {
        return const SizedBox();
      }

      final times = controller.availableTimes;
      if (times.isEmpty) {
        return Text(_t("No available time slots."));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                _t("Time"),
                style: TextStyle(
                  fontFamily: AppFonts.dancingScript,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: times.map((t) {
              final isSelected = controller.selectedTime.value == t;
              return GestureDetector(
                onTap: () => controller.selectTime(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    t.replaceAll('AM', AppLocalizations.of(context)!.am).replaceAll('PM', AppLocalizations.of(context)!.pm),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    });
  }

  Widget _bookButton(
    BuildContext context,
    CosmeticAppointmentBookingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          final date = controller.selectedDate.value;
          if (date == null) {
            Get.snackbar(_t('Selection Required'), _t('Please select a date first'), snackPosition: SnackPosition.TOP);
            return;
          }

          final time = controller.selectedTime.value;
          if (time.isEmpty) {
            Get.snackbar(_t('Selection Required'), _t('Please select a time first'), snackPosition: SnackPosition.TOP);
            return;
          }

          Get.to(
            () => CosmeticConfirmScreen(
              model: controller.service,
              selectedDate: date,
              selectedTime: time,
              controllerTag: controller.service.id,
              totalPrice: double.tryParse(controller.service.price) ?? 0.0,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(double.infinity, 55),
          elevation: 8,
        ),
        child: Text(
          _t("Book Appointment"),
          style: TextStyle(
            
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
