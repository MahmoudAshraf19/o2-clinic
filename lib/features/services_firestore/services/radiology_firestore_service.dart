import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ct_icon_model.dart';
import '../models/radiology_ct_model.dart';
import '../models/radiology_item_model.dart';
import '../models/radiology_ultrasound_model.dart';
import '../models/radiology_xray_model.dart';

class RadiologyFirestoreService {
  RadiologyFirestoreService._();
  static final RadiologyFirestoreService instance =
      RadiologyFirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = "radiology_category";

  Future<Map<String, dynamic>?> _getDocData(String docId) async {
    final doc = await _firestore
        .collection(_collection)
        .doc(docId)
        .get(const GetOptions(source: Source.serverAndCache));

    if (!doc.exists) {
      print("❌ [RadiologyFirestoreService] Doc not found: $_collection/$docId");
      return null;
    }

    final data = doc.data();
    if (data == null) {
      print("❌ [RadiologyFirestoreService] Data is null: $_collection/$docId");
      return null;
    }

    return data;
  }

  // =========================
  // CT (CATEGORIES/CARDS)
  // =========================

  Future<List<RadiologyCtModel>> getCtCategories() async {
    try {
      print("🚀 [Radiology] FETCH CT FROM FIRESTORE");

      final data = await _getDocData("ct");
      if (data == null) return [];

      final List<RadiologyCtModel> list = [];

      data.forEach((key, value) {
        // ✅ لو عندك أي keys مش كاردز تجاهلها هنا
        if (value is Map<String, dynamic>) {
          try {
            list.add(RadiologyCtModel.fromMap(id: key, map: value));
          } catch (e) {
            print("💥 [Radiology] CT PARSE ERROR [$key]: $e");
          }
        }
      });

      print("✅ [Radiology] CT TOTAL: ${list.length}");
      return list;
    } catch (e) {
      print("💥 [Radiology] CT FETCH ERROR: $e");
      return [];
    }
  }

  // =========================
  // CT ICONS (from /icons)
  // =========================

  Future<List<CtIconModel>> getCtIcons() async {
    try {
      print("🚀 [Radiology] FETCH CT ICONS FROM /icons");

      final snapshot = await _firestore
          .collection("icons") // ✅ collection مستقلة
          .get(const GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isEmpty) {
        print("❌ [Radiology] NO ICONS FOUND IN /icons");
        return [];
      }

      final List<CtIconModel> icons = [];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          icons.add(CtIconModel.fromMap(id: doc.id, map: data));
        } catch (e) {
          print("💥 [Radiology] ICON PARSE ERROR [${doc.id}]: $e");
        }
      }

      print("✅ [Radiology] CT ICONS TOTAL: ${icons.length}");
      return icons;
    } catch (e) {
      print("💥 [Radiology] CT ICONS FETCH ERROR: $e");
      return [];
    }
  }

  // =========================
  // X-RAY
  // =========================

  Future<List<RadiologyXrayModel>> getXrayCategories() async {
    try {
      print("🚀 [Radiology] FETCH X-RAY FROM FIRESTORE");

      final data = await _getDocData("x_ray");
      if (data == null) return [];

      final List<RadiologyXrayModel> list = [];

      data.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          try {
            list.add(RadiologyXrayModel.fromMap(id: key, map: value));
          } catch (e) {
            print("💥 [Radiology] X-RAY PARSE ERROR [$key]: $e");
          }
        }
      });

      print("✅ [Radiology] X-RAY TOTAL: ${list.length}");
      return list;
    } catch (e) {
      print("💥 [Radiology] X-RAY FETCH ERROR: $e");
      return [];
    }
  }

  // =========================
  // ULTRASOUND
  // =========================

  Future<List<RadiologyUltrasoundModel>> getUltrasoundCategories() async {
    try {
      print("🚀 [Radiology] FETCH ULTRASOUND FROM FIRESTORE");

      final data = await _getDocData("ultrasound");
      if (data == null) return [];

      final List<RadiologyUltrasoundModel> list = [];

      data.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          try {
            list.add(RadiologyUltrasoundModel.fromMap(id: key, map: value));
          } catch (e) {
            print("💥 [Radiology] ULTRASOUND PARSE ERROR [$key]: $e");
          }
        }
      });

      list.removeWhere((e) => (e.isActive == false));

      print("✅ [Radiology] ULTRASOUND TOTAL: ${list.length}");
      return list;
    } catch (e) {
      print("💥 [Radiology] ULTRASOUND FETCH ERROR: $e");
      return [];
    }
  }

  // =========================
  // OPTIONAL: ALL IN ONE
  // =========================

  Future<List<RadiologyItemModel>> getAllRadiology() async {
    try {
      print("🚀 [Radiology] FETCH ALL (ct + x_ray + ultrasound)");

      final ct = await _getDocData("ct");
      final xray = await _getDocData("x_ray");
      final us = await _getDocData("ultrasound");

      final List<RadiologyItemModel> result = [];

      void addCategory(String categoryKey, Map<String, dynamic>? map) {
        if (map == null) return;
        map.forEach((itemKey, itemValue) {
          if (itemValue is Map<String, dynamic>) {
            try {
              result.add(
                RadiologyItemModel.fromMap(
                  id: itemKey,
                  map: itemValue,
                  category: categoryKey,
                ),
              );
            } catch (e) {
              print(
                "💥 [Radiology] ITEM PARSE ERROR [$categoryKey/$itemKey]: $e",
              );
            }
          }
        });
      }

      addCategory("ct", ct);
      addCategory("x_ray", xray);
      addCategory("ultrasound", us);

      print("✅ [Radiology] ALL TOTAL: ${result.length}");
      return result;
    } catch (e) {
      print("💥 [Radiology] ALL FETCH ERROR: $e");
      return [];
    }
  }
}
