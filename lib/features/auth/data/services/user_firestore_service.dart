import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services_firestore/firestore_paths.dart';

/// [UserFirestoreService] optimized to minimize Firestore read counts.
class UserFirestoreService {
  UserFirestoreService._();
  static final UserFirestoreService instance = UserFirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local memory cache for current user data
  Map<String, dynamic>? _cachedUserData;
  String? _cachedUid;
  String? _cachedDocId;

  Future<void> createUser({
    required String docId,
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(FirestorePaths.users).doc(docId).set(data);
    _cachedUserData = data;
    _cachedUid = uid;
    _cachedDocId = docId;
  }

  Future<String?> _getDocIdByUid(String uid) async {
    if (_cachedUid == uid && _cachedDocId != null) return _cachedDocId;

    try {
      final q = await _firestore
          .collection(FirestorePaths.users)
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get(const GetOptions(source: Source.cache));
      if (q.docs.isNotEmpty) {
        _cachedDocId = q.docs.first.id;
        return _cachedDocId;
      }
    } catch (e) {
      /* ignore */
    }

    final q2 = await _firestore
        .collection(FirestorePaths.users)
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get(const GetOptions(source: Source.server));
    if (q2.docs.isNotEmpty) {
      _cachedDocId = q2.docs.first.id;
      return _cachedDocId;
    }
    return null;
  }

  /// Gets user data with an intelligent caching strategy.
  ///
  /// 1. Checks memory cache first.
  /// 2. If not in memory, tries Firestore persistent cache (offline-safe).
  /// 3. Only hits the server if necessary.
  Future<Map<String, dynamic>?> getUser(
    String uid, {
    bool forceRefresh = false,
  }) async {
    // 1. Memory Cache
    if (!forceRefresh && _cachedUid == uid && _cachedUserData != null) {
      return _cachedUserData;
    }

    final docId = await _getDocIdByUid(uid);
    if (docId == null) return null;

    try {
      // 2. Try Persistence Cache first
      if (!forceRefresh) {
        final cacheDoc = await _firestore
            .collection(FirestorePaths.users)
            .doc(docId)
            .get(const GetOptions(source: Source.cache));

        if (cacheDoc.exists) {
          _cachedUserData = cacheDoc.data();
          _cachedUid = uid;
          return _cachedUserData;
        }
      }
    } catch (_) {
      // Cache miss, proceed to server
    }

    // 3. Server Fetch
    final serverDoc = await _firestore
        .collection(FirestorePaths.users)
        .doc(docId)
        .get(const GetOptions(source: Source.server));

    if (serverDoc.exists) {
      _cachedUserData = serverDoc.data();
      _cachedUid = uid;
    }

    return _cachedUserData;
  }

  Future<void> updateUser({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    final docId = await _getDocIdByUid(uid);
    if (docId != null) {
      await _firestore.collection(FirestorePaths.users).doc(docId).update(data);
    }
    // Update local cache if it's the same user
    if (_cachedUid == uid && _cachedUserData != null) {
      _cachedUserData!.addAll(data);
    }
  }

  Future<void> deleteUser(String uid) async {
    final docId = await _getDocIdByUid(uid);
    if (docId != null) {
      await _firestore.collection(FirestorePaths.users).doc(docId).delete();
    }
    if (_cachedUid == uid) {
      _cachedUserData = null;
      _cachedUid = null;
      _cachedDocId = null;
    }
  }

  Future<bool> isEmailExists(String email) async {
    final query = await _firestore
        .collection(FirestorePaths.users)
        .where('email', isEqualTo: email)
        .limit(1)
        .get(const GetOptions(source: Source.server));
    return query.docs.isNotEmpty;
  }

  void clearCache() {
    _cachedUserData = null;
    _cachedUid = null;
    _cachedDocId = null;
  }

  /// Streams user data. Note: snapshots() automatically handles local vs server,
  /// but use only when real-time updates are essential.
  Stream<Map<String, dynamic>?> streamUser(String uid) {
    return _firestore
        .collection(FirestorePaths.users)
        .where('uid', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final data = snapshot.docs.first.data();
            if (_cachedUid == uid) _cachedUserData = data;
            _cachedDocId = snapshot.docs.first.id;
            _cachedUid = uid;
            return data;
          }
          return null;
        });
  }
}
