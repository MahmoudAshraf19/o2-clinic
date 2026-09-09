import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cosmetic_category_model.dart';

class CosmeticCategoryService {
  CosmeticCategoryService._();
  static final instance = CosmeticCategoryService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<CosmeticCategoryModel>> fetchCosmeticCategories({bool forceRefresh = false}) async {
    final snap = await _db.collection('cosmetic').get();

    final list = snap.docs
        .map((doc) => CosmeticCategoryModel.fromMap(doc.id, doc.data()))
        .where((e) => e.isActive)
        .toList();

    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }
}
