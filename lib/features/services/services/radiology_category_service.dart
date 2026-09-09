import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/radiology_category_model.dart';

class RadiologyCategoryService {
  RadiologyCategoryService._();
  static final instance = RadiologyCategoryService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<RadiologyCategoryModel>> fetchRadiologyCategories({bool forceRefresh = false}) async {
    // Basic implementation for fetching radiology categories
    final snap = await _db.collection('radiology').get();

    final list = snap.docs
        .map((doc) => RadiologyCategoryModel.fromMap(doc.id, doc.data()))
        .where((e) => e.isActive)
        .toList();

    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }
}
