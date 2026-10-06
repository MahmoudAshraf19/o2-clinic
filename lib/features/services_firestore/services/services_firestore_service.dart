import 'package:cloud_firestore/cloud_firestore.dart';

import '../firestore_paths.dart';
import '../models/service_model.dart';

class ServicesFirestoreService {
  // Singleton instance
  static final ServicesFirestoreService _instance =
      ServicesFirestoreService._internal();
  factory ServicesFirestoreService() => _instance;
  ServicesFirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Memory Cache
  List<ServiceModel>? _cachedServices;
  DateTime? _lastFetchTime;

  // Cache expires after 15 minutes to reduce reads significantly
  static const Duration _cacheTtl = Duration(minutes: 15);

  /// Fetches services with an optimized multi-layer caching strategy.
  Future<List<ServiceModel>> getAllServices({bool forceRefresh = false}) async {
    try {
      final now = DateTime.now();

      // 1. Return memory cache if valid and not forcing refresh
      if (!forceRefresh && _cachedServices != null && _lastFetchTime != null) {
        if (now.difference(_lastFetchTime!) < _cacheTtl) {
          return _cachedServices!;
        }
      }


      // 2. Try to get from local persistent cache first (instant response)
      // This doesn't count as a billable read if data is already in local SQLite
      try {
        final cacheSnapshot = await _firestore
            .collection(FirestorePaths.servicesCollection)
            .orderBy('order')
            .get(const GetOptions(source: Source.cache));

        if (cacheSnapshot.docs.isNotEmpty && !forceRefresh) {
          _cachedServices = _parseSnapshot(cacheSnapshot);
          _lastFetchTime = now;

          // Optionally: Trigger a background fetch to update the cache without waiting
          _backgroundSync();

          return _cachedServices!;
        }
      } catch (e) {
        // Cache might be empty or unavailable, proceed to server
      }

      // 3. Fetch from Server if cache is empty, expired, or refresh requested
      final serverSnapshot = await _firestore
          .collection(FirestorePaths.servicesCollection)
          .orderBy('order')
          .get(const GetOptions(source: Source.server));

      _cachedServices = _parseSnapshot(serverSnapshot);
      _lastFetchTime = now;

      return _cachedServices!;
    } catch (e) {
      // Return last known cache if available even if expired, rather than empty list
      return _cachedServices ?? [];
    }
  }

  /// Silently updates the local cache in the background
  Future<void> _backgroundSync() async {
    try {
      final snapshot = await _firestore
          .collection(FirestorePaths.servicesCollection)
          .orderBy('order')
          .get(const GetOptions(source: Source.server));

      _cachedServices = _parseSnapshot(snapshot);
      _lastFetchTime = DateTime.now();
    } catch (e) { /* ignore */ }
  }

  List<ServiceModel> _parseSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ServiceModel(
        id: data['id'] ?? doc.id,
        titleEn: data['title_en'] ?? '',
        titleAr: data['title_ar'] ?? '',
        titleHe: data['title_he'] ?? '',
        descriptionEn: data['description_en'] ?? '',
        descriptionAr: data['description_ar'] ?? '',
        descriptionHe: data['description_he'] ?? '',
        image: data['image'] ?? '',
        price: data['price']?.toString() ?? '0',
      );
    }).toList();
  }

  /// Manually clear cache if needed
  void clearCache() {
    _cachedServices = null;
    _lastFetchTime = null;
  }
}
