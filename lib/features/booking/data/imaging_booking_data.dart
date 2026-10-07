import '../../services/data/models/fs_radiology_ct_model.dart';
import '../../services/data/models/fs_radiology_ultrasound_model.dart';
import '../../services/data/models/fs_xray_data_model.dart';
import '../../services/data/services/fs_radiology_cache_service.dart';
import '../../services/data/services/fs_xray_data_cache_service.dart';
import 'models/imaging_day_model.dart';
import 'models/imaging_slot_model.dart';
import 'models/imaging_type_model.dart';

class ImagingBookingData {
  static Future<List<ImagingTypeModel>> getCtScanTypes() async {
    final items = await RadiologyCacheService.getCtCategories();
    return items.map(_mapCtToType).toList();
  }

  static Future<List<ImagingTypeModel>> getXRayTypes() async {
    final items = await XrayDataCacheService.getAllXrayData();
    return items.map(_mapXrayToType).toList();
  }

  static Future<List<ImagingTypeModel>> getUltrasoundTypes() async {
    final items = await RadiologyCacheService.getUltrasoundCategories();
    return items.map(_mapUltrasoundToType).toList();
  }

  static List<ImagingDayModel> getAvailableDays() {
    final now = DateTime.now();
    return List.generate(5, (index) {
      final date = now.add(Duration(days: index + 1));
      return ImagingDayModel(day: _dayName(date.weekday), date: date);
    });
  }

  static List<ImagingSlotModel> getTimeSlots() {
    return const [
      ImagingSlotModel(time: "09:00 AM", maxBookings: 5, booked: 2),
      ImagingSlotModel(time: "10:00 AM", maxBookings: 5, booked: 4),
      ImagingSlotModel(time: "11:00 AM", maxBookings: 5, booked: 1),
      ImagingSlotModel(time: "12:00 PM", maxBookings: 5, booked: 3),
      ImagingSlotModel(time: "01:00 PM", maxBookings: 5, booked: 0),
      ImagingSlotModel(time: "02:00 PM", maxBookings: 5, booked: 2),
      ImagingSlotModel(time: "03:00 PM", maxBookings: 5, booked: 1),
    ];
  }

  static ImagingTypeModel _mapCtToType(RadiologyCtModel item) {
    return ImagingTypeModel(
      id: item.id,
      title: item.titleEn,
      description: item.descriptionEn,
      price: item.price.toInt(),
    );
  }

  static ImagingTypeModel _mapXrayToType(XrayDataModel item) {
    return ImagingTypeModel(
      id: item.id,
      title: item.nameEn,
      description: item.nameEn,
      price: item.price.toInt(),
    );
  }

  static ImagingTypeModel _mapUltrasoundToType(RadiologyUltrasoundModel item) {
    return ImagingTypeModel(
      id: item.id,
      title: item.nameEn,
      description: item.descriptionEn,
      price: item.price.toInt(),
    );
  }

  static String _dayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }
}
