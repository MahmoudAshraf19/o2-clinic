import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cosmetic_category_model.dart';

class CosmeticFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🚀 GET ALL COSMETIC CATEGORIES
  Future<List<CosmeticCategoryModel>> getCosmeticCategories() async {
    try {
      print("========================================");
      print("🚀 [Cosmetic] FETCHING COSMETIC CATEGORIES FROM FIRESTORE...");

      final snapshot = await _firestore
          .collection("cosmetic")
          .get(const GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isEmpty) {
        print("❌ [Cosmetic] COSMETIC COLLECTION IS EMPTY OR NOT FOUND");
        return [];
      }

      final List<CosmeticCategoryModel> list = [];

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final item = CosmeticCategoryModel.fromMap(id: doc.id, map: data);
          list.add(item);
          print("✅ [Cosmetic] LOADED DOCUMENT: ${doc.id} -> ${item.titleEn}");
        } catch (e) {
          print("💥 [Cosmetic] PARSE ERROR FOR DOCUMENT [${doc.id}]: $e");
        }
      }

      print("🎯 [Cosmetic] TOTAL CATEGORIES LOADED: ${list.length}");
      print("========================================");

      return list;
    } catch (e, stack) {
      print("💥 COSMETIC FETCH ERROR: $e");
      print(stack);

      return [];
    }
  }
}
