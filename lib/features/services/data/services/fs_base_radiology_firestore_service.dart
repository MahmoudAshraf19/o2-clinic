import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services_firestore/firestore_paths.dart';
import '../models/fs_radiology_item_model.dart';

class RadiologyFirestoreService {
  RadiologyFirestoreService._();

  static final RadiologyFirestoreService instance =
      RadiologyFirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Optimized fetch for all radiology items
  Future<List<RadiologyItemModel>> getAllRadiology() async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.radiologyCategory)
          .get(const GetOptions(source: Source.serverAndCache));

      return snapshot.docs.map((doc) {
        return RadiologyItemModel.fromMap(
          id: doc.id,
          map: doc.data(),
          category: doc.data()['category'] ?? 'General',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRadiologyCategories() async {
    final result = await _firestore
        .collection(FirestorePaths.radiologyCategory)
        .get();

    return result.docs.map((e) => e.data()).toList();
  }

  Future<void> createRadiologyCategory({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(FirestorePaths.radiologyCategory)
        .doc(id)
        .set(data);
  }

  Future<void> updateRadiologyCategory({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(FirestorePaths.radiologyCategory)
        .doc(id)
        .update(data);
  }

  Future<void> deleteRadiologyCategory(String id) async {
    await _firestore
        .collection(FirestorePaths.radiologyCategory)
        .doc(id)
        .delete();
  }
}
