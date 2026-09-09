import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/radiology_item_model.dart';

class RadiologyFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RadiologyFirestoreService();

  Future<List<RadiologyItemModel>> getAllRadiology() async {
    try {
      print("⚡ [Radiology] FETCH START");

      final doc = await _firestore
          .collection("services")
          .doc("radiology_category")
          .get();

      if (!doc.exists) {
        print("❌ Document not found");
        return [];
      }

      final data = doc.data();
      if (data == null) return [];

      final List<RadiologyItemModel> result = [];

      print("📦 Categories: ${data.keys}");

      data.forEach((categoryKey, categoryValue) {
        if (categoryValue is Map<String, dynamic>) {
          print("➡️ Category: $categoryKey");

          categoryValue.forEach((itemKey, itemValue) {
            if (itemValue is Map<String, dynamic>) {
              result.add(
                RadiologyItemModel.fromMap(
                  id: itemKey,
                  map: itemValue,
                  category: categoryKey,
                ),
              );

              print("✅ Loaded: $itemKey");
            }
          });
        }
      });

      print("🎯 TOTAL: ${result.length}");

      return result;
    } catch (e, stack) {
      print("💥 ERROR: $e");
      print(stack);
      return [];
    }
  }
}
