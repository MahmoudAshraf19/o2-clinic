import 'firestore_paths.dart';
import 'firestore_service.dart';

class AppConstantsFirestoreService {
  AppConstantsFirestoreService._();

  static final AppConstantsFirestoreService instance =
      AppConstantsFirestoreService._();

  final _firestore = FirestoreService.instance.firestore;

  /// CREATE

  Future<void> createAppConstants({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(FirestorePaths.appConstants)
        .doc(docId)
        .set(data);
  }

  /// READ

  Future<Map<String, dynamic>?> getAppConstants(String docId) async {
    final doc = await _firestore
        .collection(FirestorePaths.appConstants)
        .doc(docId)
        .get();

    return doc.data();
  }

  Future<List<Map<String, dynamic>>> getAllAppConstants() async {
    final result = await _firestore
        .collection(FirestorePaths.appConstants)
        .get();

    return result.docs.map((e) => e.data()).toList();
  }

  Stream<List<Map<String, dynamic>>> streamAppConstants() {
    return _firestore
        .collection(FirestorePaths.appConstants)
        .snapshots()
        .map((event) => event.docs.map((e) => e.data()).toList());
  }

  /// UPDATE

  Future<void> updateAppConstants({
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(FirestorePaths.appConstants)
        .doc(docId)
        .update(data);
  }

  /// DELETE

  Future<void> deleteAppConstants(String docId) async {
    await _firestore
        .collection(FirestorePaths.appConstants)
        .doc(docId)
        .delete();
  }
}
