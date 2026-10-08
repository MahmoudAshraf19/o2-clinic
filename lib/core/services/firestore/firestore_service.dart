import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// CREATE

  Future<void> createDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(collection).doc(docId).set(data);
  }

  Future<String> addDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    final doc = await firestore.collection(collection).add(data);
    return doc.id;
  }

  /// READ

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collection,
    required String docId,
  }) async {
    return await firestore.collection(collection).doc(docId).get();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getCollection({
    required String collection,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
    queryBuilder,
  }) async {
    Query<Map<String, dynamic>> query = firestore.collection(collection);

    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    final result = await query.get();

    return result.docs;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument({
    required String collection,
    required String docId,
  }) {
    return firestore.collection(collection).doc(docId).snapshots();
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> streamCollection({
    required String collection,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
    queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = firestore.collection(collection);

    if (queryBuilder != null) {
      query = queryBuilder(query);
    }

    return query.snapshots().map((e) => e.docs);
  }

  /// UPDATE

  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await firestore.collection(collection).doc(docId).update(data);
  }

  Future<void> updateField({
    required String collection,
    required String docId,
    required String field,
    required dynamic value,
  }) async {
    await firestore.collection(collection).doc(docId).update({field: value});
  }

  // DELETE

  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    await firestore.collection(collection).doc(docId).delete();
  }

  // BATCH

  Future<void> batchWrite({
    required List<Future<void> Function(WriteBatch batch)> actions,
  }) async {
    final batch = firestore.batch();

    for (final action in actions) {
      await action(batch);
    }

    await batch.commit();
  }

  // TRANSACTION

  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) action,
  ) async {
    return await firestore.runTransaction(action);
  }
}
