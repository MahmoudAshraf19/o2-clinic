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
      print("========================================");
      print(
        "🔍 [AppConstants] Fetching 'currency' document from 'app_constants' collection...",
      );
      final doc = await AppConstantsFirestoreService.instance.getAppConstants(
        'currency',
      );

      if (doc != null) {
        print("🔍 [AppConstants] Found currency document: $doc");
        final currencyModel = CurrencyModel.fromMap(doc);
        print(
          "🔍 [AppConstants] Parsed Model - Symbol: ${currencyModel.symbol}, Name: ${currencyModel.name}",
        );
        currencySymbol.value = currencyModel.symbol;
        currencyName.value = currencyModel.name;
        print(
          "✅ [AppConstants] Successfully updated currency to: ${currencySymbol.value}",
        );
      } else {
        print("⚠️ [AppConstants] 'currency' document not found!");
      }

      print("🔍 [AppConstants] Fetching 'slot_interval_hours'...");
      final docInterval = await AppConstantsFirestoreService.instance
          .getAppConstants('slot_interval_hours');
      if (docInterval != null && docInterval['slot_interval_hours'] != null) {
        slotIntervalHours.value = (docInterval['slot_interval_hours'] as num)
            .toInt();
        print(
          "✅ [AppConstants] Successfully updated slotIntervalHours to: ${slotIntervalHours.value}",
        );
      }

      print("========================================");
    } catch (e, stack) {
      print("❌ [AppConstants] Error loading app constants: $e");
      print(stack);
    }
  }
}
