import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ct_scan_type_model.dart';

class CtScanTypeFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CtScanTypeFirestoreService();

  /// 🚀 GET ALL CT SCAN TYPES
  Future<List<CtScanTypeModel>> getCtScanTypes() async {
    try {
      final snapshot = await _firestore
          .collection("ct_scan_type")
          .get(const GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final List<CtScanTypeModel> types = [];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();

          final type = CtScanTypeModel.fromMap(id: doc.id, map: data);

          types.add(type);
        } catch (e) {
          /* ignore */
        }
      }

      return types;
    } catch (e) {
      return [];
    }
  }
}
