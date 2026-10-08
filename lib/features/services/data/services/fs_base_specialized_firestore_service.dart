import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firestore/firestore_paths.dart';

/// [SpecializedFirestoreService] with professional caching to reduce reads.
class SpecializedFirestoreService {
  SpecializedFirestoreService._();
  static final SpecializedFirestoreService instance =
      SpecializedFirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache
  List<Map<String, dynamic>>? _cachedList;
  DateTime? _lastFetch;
  static const _ttl = Duration(minutes: 30);

  Future<List<Map<String, dynamic>>> getAllSpecialized({
    bool forceRefresh = false,
  }) async {
    // 1. Memory Cache
    if (!forceRefresh && _cachedList != null && _lastFetch != null) {
      if (DateTime.now().difference(_lastFetch!) < _ttl) {
        return _cachedList!;
      }
    }

    try {
      // 2. Local Persistence
      if (!forceRefresh) {
        final cache = await _firestore
            .collection(FirestorePaths.specialized)
            .get(const GetOptions(source: Source.cache));
        if (cache.docs.isNotEmpty) {
          _cachedList = cache.docs.map((e) => e.data()).toList();
          _lastFetch = DateTime.now();
          return _cachedList!;
        }
      }
    } catch (e) {
      /* ignore */
    }

    // 3. Server
    final result = await _firestore
        .collection(FirestorePaths.specialized)
        .get(const GetOptions(source: Source.server));

    _cachedList = result.docs.map((e) => e.data()).toList();
    _lastFetch = DateTime.now();
    return _cachedList!;
  }

  Future<Map<String, dynamic>?> getSpecialized(String id) async {
    // Try finding in cached list first
    if (_cachedList != null) {
      try {
        return _cachedList!.firstWhere((element) => element['id'] == id);
      } catch (e) {
        /* ignore */
      }
    }

    final result = await _firestore
        .collection(FirestorePaths.specialized)
        .doc(id)
        .get(const GetOptions(source: Source.serverAndCache));

    return result.data();
  }

  Future<void> createSpecialized({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(FirestorePaths.specialized).doc(id).set(data);
    _cachedList = null; // Invalidate cache
  }

  Future<void> updateSpecialized({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await _firestore
        .collection(FirestorePaths.specialized)
        .doc(id)
        .update(data);
    _cachedList = null; // Invalidate cache
  }

  Future<void> deleteSpecialized(String id) async {
    await _firestore.collection(FirestorePaths.specialized).doc(id).delete();
    _cachedList = null; // Invalidate cache
  }
}
