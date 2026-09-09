import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/specialized_service_model.dart';

class SpecializedFirestoreService {
  static final SpecializedFirestoreService instance =
      SpecializedFirestoreService._();

  SpecializedFirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<SpecializedServiceModel>> getAllSpecialized() async {
    try {
      print("⚡ [Specialized] FETCH START (/specialized)");

      final snapshot = await _firestore
          .collection("specialized")
          .get(const GetOptions(source: Source.serverAndCache));

      print("📦 [Specialized] TOTAL DOCS: ${snapshot.docs.length}");

      if (snapshot.docs.isEmpty) {
        print("❌ [Specialized] No documents found in /specialized");
        return [];
      }

      final List<SpecializedServiceModel> result = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        // ✅ لو id مش موجود في الدوك نفسه، خده من doc.id
        final fixedMap = <String, dynamic>{...data, 'id': data['id'] ?? doc.id};

        try {
          result.add(SpecializedServiceModel.fromMap(map: fixedMap));
          print("✅ Loaded: ${doc.id}");
        } catch (e) {
          print("❌ ERROR parsing ${doc.id}: $e");
        }
      }

      print("🎯 TOTAL SPECIALIZED: ${result.length}");
      return result;
    } catch (e, stack) {
      print("💥 [Specialized] FIRESTORE ERROR: $e");
      print(stack);
      return [];
    }
  }
}
