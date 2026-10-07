import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/fs_cosmetic_category_model.dart';

class CosmeticFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🚀 GET ALL COSMETIC CATEGORIES
  Future<List<CosmeticCategoryModel>> getCosmeticCategories() async {
    try {
      final snapshot = await _firestore
          .collection("cosmetic")
          .get(const GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final List<CosmeticCategoryModel> list = [];

      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final item = CosmeticCategoryModel.fromMap(id: doc.id, map: data);
          list.add(item);
        } catch (e) {
          /* ignore */
        }
      }

      return list;
    } catch (e) {
      return [];
    }
  }
}
