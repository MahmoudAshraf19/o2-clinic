import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/services/firestore/firestore_paths.dart';
import '../models/banner_model.dart';
import 'banner_cache_service.dart';

class BannerServiceException implements Exception {
  final String message;
  final String? code;

  const BannerServiceException(this.message, {this.code});

  @override
  String toString() {
    if (code == null) return 'BannerServiceException: $message';
    return 'BannerServiceException($code): $message';
  }
}

class BannerService {
  BannerService({
    FirebaseFirestore? firestore,
    BannerCacheService? cacheService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _cacheService = cacheService ?? BannerCacheService();

  final FirebaseFirestore _firestore;
  final BannerCacheService _cacheService;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.banners);

  Future<List<BannerModel>> getActiveBanners({
    bool forceRefresh = false,
  }) async {
    debugPrint('[Banners] getActiveBanners called. forceRefresh=$forceRefresh');

    if (!forceRefresh) {
      final cached = await _cacheService.getCachedBanners();
      if (cached != null) {
        final activeCached = cached.where((b) => b.isActive).toList();
        debugPrint(
          '[Banners] Returning ${activeCached.length} active banner(s) from cache.',
        );
        return _sortBanners(activeCached);
      }
    }

    try {
      final banners = await _fetchAllBannersFromFirestore();
      final activeBanners = banners.where((b) => b.isActive).toList();

      await _cacheService.cacheBanners(activeBanners);

      debugPrint(
        '[Banners] Fetched ${activeBanners.length} active banner(s) from Firestore.',
      );

      return _sortBanners(activeBanners);
    } on FirebaseException catch (e) {
      debugPrint(
        '[Banners] FirebaseException in getActiveBanners: ${e.code} | ${e.message}',
      );

      final cached = await _cacheService.getCachedBanners();
      if (cached != null && cached.isNotEmpty) {
        final activeCached = cached.where((b) => b.isActive).toList();
        debugPrint(
          '[Banners] Falling back to cache with ${activeCached.length} active banner(s).',
        );
        return _sortBanners(activeCached);
      }

      throw BannerServiceException(_mapFirebaseError(e), code: e.code);
    } catch (e, st) {
      debugPrint('[Banners] Unexpected error in getActiveBanners: $e');
      debugPrintStack(stackTrace: st);

      final cached = await _cacheService.getCachedBanners();
      if (cached != null && cached.isNotEmpty) {
        final activeCached = cached.where((b) => b.isActive).toList();
        debugPrint(
          '[Banners] Falling back to cache with ${activeCached.length} active banner(s).',
        );
        return _sortBanners(activeCached);
      }

      throw BannerServiceException(
        'Unexpected error while fetching active banners: $e',
      );
    }
  }

  Future<List<BannerModel>> getAllBanners({bool forceRefresh = false}) async {
    debugPrint('[Banners] getAllBanners called. forceRefresh=$forceRefresh');

    if (!forceRefresh) {
      final cached = await _cacheService.getCachedBanners();
      if (cached != null) {
        debugPrint(
          '[Banners] Returning ${cached.length} banner(s) from cache.',
        );
        return _sortBanners(cached);
      }
    }

    try {
      final banners = await _fetchAllBannersFromFirestore();

      await _cacheService.cacheBanners(banners);

      debugPrint(
        '[Banners] Fetched ${banners.length} banner(s) from Firestore.',
      );

      return _sortBanners(banners);
    } on FirebaseException catch (e) {
      debugPrint(
        '[Banners] FirebaseException in getAllBanners: ${e.code} | ${e.message}',
      );

      final cached = await _cacheService.getCachedBanners();
      if (cached != null && cached.isNotEmpty) {
        debugPrint(
          '[Banners] Falling back to cache with ${cached.length} banner(s).',
        );
        return _sortBanners(cached);
      }

      throw BannerServiceException(_mapFirebaseError(e), code: e.code);
    } catch (e, st) {
      debugPrint('[Banners] Unexpected error in getAllBanners: $e');
      debugPrintStack(stackTrace: st);

      final cached = await _cacheService.getCachedBanners();
      if (cached != null && cached.isNotEmpty) {
        debugPrint(
          '[Banners] Falling back to cache with ${cached.length} banner(s).',
        );
        return _sortBanners(cached);
      }

      throw BannerServiceException(
        'Unexpected error while fetching banners: $e',
      );
    }
  }

  Stream<List<BannerModel>> watchActiveBanners() {
    debugPrint('[Banners] watchActiveBanners stream started.');

    return _collection
        .snapshots()
        .map((snapshot) {
          try {
            final banners = snapshot.docs
                .map((doc) => BannerModel.fromMap(doc.data(), id: doc.id))
                .where((banner) => banner.isActive)
                .toList();

            _cacheService.cacheBanners(banners);

            debugPrint(
              '[Banners] Stream update received with ${banners.length} active banner(s).',
            );

            return _sortBanners(banners);
          } catch (e, st) {
            debugPrint('[Banners] Error while mapping stream data: $e');
            debugPrintStack(stackTrace: st);
            return <BannerModel>[];
          }
        })
        .handleError((Object error, StackTrace stackTrace) async {
          debugPrint('[Banners] Stream error: $error');
          debugPrintStack(stackTrace: stackTrace);

          final cached = await _cacheService.getCachedBanners();
          if (cached != null) {
            debugPrint(
              '[Banners] Using cached banners after stream error: ${cached.length}',
            );
          }
        });
  }

  Future<BannerModel?> getBannerById(String bannerId) async {
    debugPrint('[Banners] getBannerById called for id=$bannerId');

    try {
      final doc = await _collection.doc(bannerId).get();

      if (!doc.exists || doc.data() == null) {
        debugPrint('[Banners] Banner not found for id=$bannerId');
        return null;
      }

      return BannerModel.fromMap(doc.data()!, id: doc.id);
    } on FirebaseException catch (e) {
      throw BannerServiceException(_mapFirebaseError(e), code: e.code);
    } catch (e, st) {
      debugPrint('[Banners] Unexpected error in getBannerById: $e');
      debugPrintStack(stackTrace: st);

      throw BannerServiceException(
        'Unexpected error while fetching banner: $e',
      );
    }
  }

  Future<List<BannerModel>> _fetchAllBannersFromFirestore() async {
    try {
      final querySnapshot = await _collection.get(
        const GetOptions(source: Source.serverAndCache),
      );

      final banners = querySnapshot.docs
          .map((doc) => BannerModel.fromMap(doc.data(), id: doc.id))
          .toList();

      return _sortBanners(banners);
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition' || e.code == 'invalid-argument') {
        debugPrint(
          '[Banners] Query fallback activated because of Firestore query restriction: ${e.code}',
        );

        final snapshot = await _collection.get(
          const GetOptions(source: Source.serverAndCache),
        );

        final banners = snapshot.docs
            .map((doc) => BannerModel.fromMap(doc.data(), id: doc.id))
            .toList();

        return _sortBanners(banners);
      }

      rethrow;
    }
  }

  List<BannerModel> _sortBanners(List<BannerModel> banners) {
    final sorted = [...banners];
    sorted.sort((a, b) {
      final orderCompare = a.order.compareTo(b.order);
      if (orderCompare != 0) return orderCompare;
      final aTitle = a.title['en'] ?? '';
      final bTitle = b.title['en'] ?? '';
      return aTitle.toLowerCase().compareTo(bTitle.toLowerCase());
    });
    return sorted;
  }

  String _mapFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'You do not have permission to access banners.';
      case 'unavailable':
        return 'Firestore is currently unavailable. Please try again later.';
      case 'not-found':
        return 'Banner collection or document was not found.';
      case 'deadline-exceeded':
        return 'Request timed out while fetching banners.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'failed-precondition':
        return 'A required Firestore index may be missing for this query.';
      case 'invalid-argument':
        return 'The Firestore query is invalid.';
      default:
        return e.message ?? 'An unknown Firestore error occurred.';
    }
  }
}
