import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../chat_support/widgets/support_chat_widgets.dart';
import '../controllers/ultrasound_booking_controller.dart';
import '../widgets/Ultrasound/ultrasound_data.dart';
import 'ultrasound_confirm_screen.dart';

class UltrasoundBookingPage extends StatelessWidget {
  final UltrasoundModel model;

  const UltrasoundBookingPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UltrasoundBookingController());
    controller.setModel(model);

    final isAuth = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _header(model.title),
            if (!isAuth) ...[
              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SupportAuthPrompt(),
              ),
              const Spacer(),
            ] else ...[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _calendar(controller, context),
                    const SizedBox(height: 20),
                    _slots(controller, context),
                  ],
                ),
              ),
              _continue(controller, context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const BackButton(),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _calendar(UltrasoundBookingController c, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.availableDays,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 92,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: c.days.length,
            itemBuilder: (_, i) {
              final day = c.days[i];
              return Obx(() {
                final isSelected = c.selectedDay.value == day;
                return GestureDetector(
                  onTap: () => c.selectDay(i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 74,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _localizeDayName(day.day, context),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  String _localizeDayName(String day, BuildContext context) {
    final lower = day.toLowerCase();
    if (lower.contains('mon')) return AppLocalizations.of(context)!.monday;
    if (lower.contains('tue')) return AppLocalizations.of(context)!.tuesday;
    if (lower.contains('wed')) return AppLocalizations.of(context)!.wednesday;
    if (lower.contains('thu')) return AppLocalizations.of(context)!.thursday;
    if (lower.contains('fri')) return AppLocalizations.of(context)!.friday;
    if (lower.contains('sat')) return AppLocalizations.of(context)!.saturday;
    if (lower.contains('sun')) return AppLocalizations.of(context)!.sunday;
    return day;
  }

  Widget _slots(UltrasoundBookingController c, BuildContext context) {
    return Obx(() {
      final day = c.selectedDay.value;
      if (day == null) {
        return Text(AppLocalizations.of(context)!.pleaseSelectDateFirst);
      }

      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(day.slots.length, (i) {
          final slot = day.slots[i];
          final selected = c.selectedSlotIndex.value == i;

          return GestureDetector(
            onTap: () => c.selectSlot(i),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: slot.isFull
                    ? Colors.grey.shade300
                    : selected
                    ? AppColors.primary
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: slot.isFull ? Colors.grey : AppColors.primary,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    slot.time
                        .replaceAll('AM', AppLocalizations.of(context)!.am)
                        .replaceAll('PM', AppLocalizations.of(context)!.pm),
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    slot.isFull
                        ? AppLocalizations.of(context)!.full
                        : "${slot.remainingSlots} ${AppLocalizations.of(context)!.available}",
                    style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _continue(UltrasoundBookingController c, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          if (!c.canContinue()) {
            Get.snackbar(
              AppLocalizations.of(context)!.error,
              AppLocalizations.of(context)!.selectionRequired,
              snackPosition: SnackPosition.TOP,
            );
            return;
          }

          Get.to(
            () => UltrasoundConfirmScreen(
              model: model,
              date: DateTime.now(),
              time: c.selectedSlot.value!.time,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          AppLocalizations.of(context)!.continueBooking,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

