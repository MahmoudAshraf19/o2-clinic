import 'package:o2_clinic/common/widgets/common_snackbar.dart';
import 'package:get/get.dart';

import '../widgets/Ultrasound/ultrasound_data.dart';

class UltrasoundBookingController extends GetxController {
  final selectedDayIndex = (-1).obs;
  final selectedSlotIndex = (-1).obs;

  final selectedDay = Rxn<DaySchedule>();
  final selectedSlot = Rxn<TimeSlot>();

  List<DaySchedule> get days => currentModel?.availableDays ?? [];

  UltrasoundModel? currentModel;

  void setModel(UltrasoundModel model) {
    currentModel = model;
    reset();
  }

  void reset() {
    selectedDayIndex.value = -1;
    selectedSlotIndex.value = -1;
    selectedDay.value = null;
    selectedSlot.value = null;
  }

  void selectDay(int index) {
    selectedDayIndex.value = index;
    selectedSlotIndex.value = -1;

    selectedDay.value = days[index];
    selectedSlot.value = null;
  }

  void selectSlot(int index) {
    final slot = selectedDay.value!.slots[index];

    if (slot.isFull) {
      CommonSnackbar.showSuccess(title: "Fully Booked", message: "This time slot is fully booked. Please choose another time.");
      return;
    }

    selectedSlotIndex.value = index;
    selectedSlot.value = slot;
  }

  bool canContinue() => selectedDay.value != null && selectedSlot.value != null;
}
