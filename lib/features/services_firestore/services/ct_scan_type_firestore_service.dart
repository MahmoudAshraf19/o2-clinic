import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ct_scan_type_model.dart';

class CtScanTypeFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CtScanTypeFirestoreService();

  /// 🚀 GET ALL CT SCAN TYPES
  Future<List<CtScanTypeModel>> getCtScanTypes() async {
    try {
      print("🚀 FETCH CT SCAN TYPES");

      final snapshot = await _firestore
          .collection("ct_scan_type")
          .get(const GetOptions(source: Source.serverAndCache));

      print("📦 TOTAL TYPES: ${snapshot.docs.length}");

      if (snapshot.docs.isEmpty) {
        print("❌ NO CT SCAN TYPES FOUND");
        return [];
      }

      final List<CtScanTypeModel> types = [];

      for (final doc in snapshot.docs) {
        try {
          print("➡️ READING TYPE: ${doc.id}");

          final data = doc.data();

          final type = CtScanTypeModel.fromMap(id: doc.id, map: data);

          types.add(type);

          print("✅ LOADED TYPE: ${type.nameEn}");
        } catch (e) {
          print("💥 TYPE PARSE ERROR [${doc.id}]: $e");
        }
      }

      print("🎯 TOTAL LOADED TYPES: ${types.length}");

      return types;
    } catch (e, stack) {
      print("💥 CT SCAN TYPES ERROR: $e");
      print(stack);

      return [];
    }
  }
}
