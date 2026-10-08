import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../common/models/fs_doctor_model.dart';

class DoctorsFirestoreService {
  DoctorsFirestoreService();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DoctorModel>> _fetchDoctorsByBoolField({
    required String fieldName,
    required bool value,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('Doctors')
          .where(fieldName, isEqualTo: value);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get(
        const GetOptions(source: Source.serverAndCache),
      );

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs
          .map((doc) => DoctorModel.fromMap(id: doc.id, map: doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<DoctorModel>> getTopRatedDoctors() async {
    return _fetchDoctorsByBoolField(
      fieldName: 'is_top_rate_enable',
      value: true,
    );
  }

  Future<List<DoctorModel>> getTheTopDoctors() async {
    return _fetchDoctorsByBoolField(fieldName: 'the_top', value: true);
  }

  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      final snapshot = await _firestore
          .collection('Doctors')
          .get(const GetOptions(source: Source.serverAndCache));

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs
          .map((doc) => DoctorModel.fromMap(id: doc.id, map: doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
