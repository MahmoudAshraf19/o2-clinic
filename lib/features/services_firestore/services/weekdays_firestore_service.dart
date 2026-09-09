import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/weekday_model.dart';

class WeekdaysFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🚀 GET ALL WEEKDAYS
  Future<List<WeekdayModel>> getAllWeekdays() async {
    try {
      print("🚀 [WeekdaysFirestore] FETCH START");

      final snapshot = await _firestore
          .collection("weekdays")
          .get(const GetOptions(source: Source.serverAndCache));

      print("📦 TOTAL WEEKDAYS: ${snapshot.docs.length}");

      if (snapshot.docs.isEmpty) {
        print("❌ No weekdays found");
        return [];
      }

      final List<WeekdayModel> weekdays = [];

      for (final doc in snapshot.docs) {
        try {
          print("➡️ Reading weekday: ${doc.id}");

          final data = doc.data();

          final weekday = WeekdayModel.fromMap(id: doc.id, map: data);

          weekdays.add(weekday);

          print("✅ Loaded weekday: ${weekday.titleEn}");
        } catch (e) {
          print("❌ ERROR parsing weekday ${doc.id}: $e");
        }
      }

      /// 🔥 SORT BY ORDER
      weekdays.sort((a, b) => a.order.compareTo(b.order));

      print("🎯 TOTAL LOADED: ${weekdays.length}");

      return weekdays;
    } catch (e, stack) {
      print("💥 FIRESTORE ERROR: $e");
      print(stack);

      return [];
    }
  }

  /// 🚀 GET ACTIVE WEEKDAYS ONLY
  Future<List<WeekdayModel>> getActiveWeekdays() async {
    try {
      print("🚀 FETCH ACTIVE WEEKDAYS");

      final snapshot = await _firestore
          .collection("weekdays")
          .where("isActive", isEqualTo: true)
          .get(const GetOptions(source: Source.serverAndCache));

      print("📦 ACTIVE WEEKDAYS: ${snapshot.docs.length}");

      final weekdays = snapshot.docs.map((doc) {
        return WeekdayModel.fromMap(id: doc.id, map: doc.data());
      }).toList();

      weekdays.sort((a, b) => a.order.compareTo(b.order));

      return weekdays;
    } catch (e) {
      print("💥 ACTIVE WEEKDAYS ERROR: $e");

      return [];
    }
  }

  /// 🚀 GET SINGLE WEEKDAY
  Future<WeekdayModel?> getWeekdayById(String weekdayId) async {
    try {
      print("🔍 FETCH WEEKDAY: $weekdayId");

      final doc = await _firestore
          .collection("weekdays")
          .doc(weekdayId)
          .get(const GetOptions(source: Source.serverAndCache));

      if (!doc.exists || doc.data() == null) {
        print("❌ Weekday not found");

        return null;
      }

      final weekday = WeekdayModel.fromMap(id: doc.id, map: doc.data()!);

      print("✅ Loaded weekday: ${weekday.titleEn}");

      return weekday;
    } catch (e) {
      print("💥 GET WEEKDAY ERROR: $e");

      return null;
    }
  }
}
