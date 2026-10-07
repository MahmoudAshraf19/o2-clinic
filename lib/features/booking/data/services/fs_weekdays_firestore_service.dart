import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/fs_weekday_model.dart';

class WeekdaysFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🚀 GET ALL WEEKDAYS
  Future<List<WeekdayModel>> getAllWeekdays() async {
    try {
      final snapshot = await _firestore
          .collection("weekdays")
          .get(const GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isEmpty) {
        return [];
      }

      final List<WeekdayModel> weekdays = [];

      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();

          final weekday = WeekdayModel.fromMap(id: doc.id, map: data);

          weekdays.add(weekday);
        } catch (e) {
          /* ignore */
        }
      }

      /// 🔥 SORT BY ORDER
      weekdays.sort((a, b) => a.order.compareTo(b.order));

      return weekdays;
    } catch (e) {
      return [];
    }
  }

  /// 🚀 GET ACTIVE WEEKDAYS ONLY
  Future<List<WeekdayModel>> getActiveWeekdays() async {
    try {
      final snapshot = await _firestore
          .collection("weekdays")
          .where("isActive", isEqualTo: true)
          .get(const GetOptions(source: Source.serverAndCache));

      final weekdays = snapshot.docs.map((doc) {
        return WeekdayModel.fromMap(id: doc.id, map: doc.data());
      }).toList();

      weekdays.sort((a, b) => a.order.compareTo(b.order));

      return weekdays;
    } catch (e) {
      return [];
    }
  }

  /// 🚀 GET SINGLE WEEKDAY
  Future<WeekdayModel?> getWeekdayById(String weekdayId) async {
    try {
      final doc = await _firestore
          .collection("weekdays")
          .doc(weekdayId)
          .get(const GetOptions(source: Source.serverAndCache));

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final weekday = WeekdayModel.fromMap(id: doc.id, map: doc.data()!);

      return weekday;
    } catch (e) {
      return null;
    }
  }
}
