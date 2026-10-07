import '../../../services_firestore/firestore_paths.dart';
import '../../../services_firestore/firestore_service.dart';

class DoctorFirestoreService {
  DoctorFirestoreService._();

  static final DoctorFirestoreService instance = DoctorFirestoreService._();

  final _firestore = FirestoreService.instance.firestore;

  /// CREATE

  Future<void> createDoctor({
    required String doctorId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(FirestorePaths.doctors).doc(doctorId).set(data);
  }

  /// READ

  Future<Map<String, dynamic>?> getDoctor(String doctorId) async {
    final doc = await _firestore
        .collection(FirestorePaths.doctors)
        .doc(doctorId)
        .get();

    return doc.data();
  }

  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    final result = await _firestore.collection(FirestorePaths.doctors).get();

    return result.docs.map((e) => e.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getDoctorsBySpeciality(
    String specialityId,
  ) async {
    final result = await _firestore
        .collection(FirestorePaths.doctors)
        .where("specialized_id", isEqualTo: specialityId)
        .where("is_active", isEqualTo: true)
        .get();

    return result.docs.map((e) => e.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getTopRatedDoctors() async {
    final result = await _firestore
        .collection(FirestorePaths.doctors)
        .where("is_top_rate_enable", isEqualTo: true)
        .orderBy("rating", descending: true)
        .limit(10)
        .get();

    return result.docs.map((e) => e.data()).toList();
  }

  Stream<List<Map<String, dynamic>>> streamDoctors() {
    return _firestore
        .collection(FirestorePaths.doctors)
        .snapshots()
        .map((event) => event.docs.map((e) => e.data()).toList());
  }

  /// UPDATE

  Future<void> updateDoctor({
    required String doctorId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(FirestorePaths.doctors)
        .doc(doctorId)
        .update(data);
  }

  Future<void> updateDoctorAvailability({
    required String doctorId,
    required List<dynamic> availability,
  }) async {
    await _firestore.collection(FirestorePaths.doctors).doc(doctorId).update({
      "availability_day": availability,
    });
  }

  Future<void> updateDoctorRating({
    required String doctorId,
    required double rating,
  }) async {
    await _firestore.collection(FirestorePaths.doctors).doc(doctorId).update({
      "rating": rating,
    });
  }

  /// DELETE

  Future<void> deleteDoctor(String doctorId) async {
    await _firestore.collection(FirestorePaths.doctors).doc(doctorId).delete();
  }
}
