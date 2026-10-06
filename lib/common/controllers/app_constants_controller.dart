import 'package:get/get.dart';
import '../../features/services_firestore/app_constants_firestore_service.dart';
import '../../features/services_firestore/models/app_constants_model.dart';

class AppConstantsController extends GetxController {
  final currencySymbol = "EGP".obs;
  final currencyName = "EGP".obs;
  final slotIntervalHours = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadConstants();
  }

  Future<void> loadConstants() async {
    try {
      final doc = await AppConstantsFirestoreService.instance.getAppConstants(
        'currency',
      );

      if (doc != null) {
        final currencyModel = CurrencyModel.fromMap(doc);
        currencySymbol.value = currencyModel.symbol;
        currencyName.value = currencyModel.name;
      } else {
      }

      final docInterval = await AppConstantsFirestoreService.instance
          .getAppConstants('slot_interval_hours');
      if (docInterval != null && docInterval['slot_interval_hours'] != null) {
        slotIntervalHours.value = (docInterval['slot_interval_hours'] as num)
            .toInt();
      }

    } catch (e, stack) {
    }
  }
}
