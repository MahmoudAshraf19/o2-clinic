import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/specialized_service_model.dart';

class SpecializedFirestoreService {
  static final SpecializedFirestoreService instance =
      SpecializedFirestoreService._();

  SpecializedFirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<SpecializedServiceModel>> getAllSpecialized() async {
    try {

      final snapshot = await _firestore
          .collection("specialized")
          .get(const GetOptions(source: Source.serverAndCache));


      if (snapshot.docs.isEmpty) {
        return [];
      }

      final List<SpecializedServiceModel> result = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        // ✅ لو id مش موجود في الدوك نفسه، خده من doc.id
        final fixedMap = <String, dynamic>{...data, 'id': data['id'] ?? doc.id};

        try {
          result.add(SpecializedServiceModel.fromMap(map: fixedMap));
        } catch (e) {
        }
      }

      return result;
    } catch (e) {
      return [];
    }
  }
}
