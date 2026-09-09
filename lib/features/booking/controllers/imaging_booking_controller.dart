import 'package:get/get.dart';

import '../data/imaging_booking_data.dart';
import '../models/imaging_day_model.dart';
import '../models/imaging_slot_model.dart';
import '../models/imaging_type_model.dart';

class ImagingBookingController extends GetxController {
  final RxList<ImagingTypeModel> selectedTypes = <ImagingTypeModel>[].obs;
  final Rxn<ImagingDayModel> selectedDay = Rxn<ImagingDayModel>();
  final Rxn<ImagingSlotModel> selectedSlot = Rxn<ImagingSlotModel>();

  final RxList<ImagingDayModel> days = <ImagingDayModel>[].obs;
  final RxList<ImagingSlotModel> slots = <ImagingSlotModel>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> loadSchedule({String? title}) async {
    if (days.isNotEmpty && slots.isNotEmpty) return;

    isLoading.value = true;
    try {
      days.assignAll(ImagingBookingData.getAvailableDays());
      slots.assignAll(ImagingBookingData.getTimeSlots());
    } finally {
      isLoading.value = false;
    }
  }

  void toggleType(ImagingTypeModel type) {
    if (selectedTypes.contains(type)) {
      selectedTypes.remove(type);
    } else {
      selectedTypes.add(type);
    }
  }

  void selectDay(ImagingDayModel day) {
    selectedDay.value = day;
    selectedSlot.value = null;
  }

  void selectSlot(ImagingSlotModel slot) {
    if (!slot.isFull) {
      selectedSlot.value = slot;
    }
  }

  bool canContinue() {
    return selectedTypes.isNotEmpty &&
        selectedDay.value != null &&
        selectedSlot.value != null;
  }

  BookingResult handleBooking() {
    if (!canContinue()) {
      return BookingResult(
        success: false,
        message: 'Select day and time first',
      );
    }

    return BookingResult(
      success: true,
      message: 'Booking confirmed successfully',
    );
  }
}

class BookingResult {
  final bool success;
  final String message;

  BookingResult({required this.success, required this.message});
}
