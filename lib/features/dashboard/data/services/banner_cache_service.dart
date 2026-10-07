import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/banner_model.dart';

class BannerCacheService {
  BannerCacheService({this.cacheDuration = const Duration(minutes: 5)});

  final Duration cacheDuration;

  static const String _cacheKey = 'cached_banners_v3';
  static const String _cacheTimeKey = 'cached_banners_time_v3';

  Future<void> cacheBanners(List<BannerModel> banners) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final encoded = jsonEncode(
        banners.map((banner) {
          final map = banner.toMap();
          map['id'] = banner.id;
          return map;
        }).toList(),
      );

      await prefs.setString(_cacheKey, encoded);
      await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {
      await clearCache();
      rethrow;
    }
  }

  Future<List<BannerModel>?> getCachedBanners() async {
    final prefs = await SharedPreferences.getInstance();

    final cachedString = prefs.getString(_cacheKey);
    final cachedTime = prefs.getInt(_cacheTimeKey);

    if (cachedString == null || cachedTime == null) return null;

    final isExpired =
        DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(cachedTime),
        ) >
        cacheDuration;

    if (isExpired) {
      await clearCache();
      return null;
    }

    try {
      final decoded = jsonDecode(cachedString);

      if (decoded is! List) {
        await clearCache();
        return null;
      }

      final result = <BannerModel>[];

      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          result.add(
            BannerModel.fromMap(item, id: item['id']?.toString() ?? ''),
          );
          continue;
        }

        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          result.add(BannerModel.fromMap(map, id: map['id']?.toString() ?? ''));
          continue;
        }

        await clearCache();
        return null;
      }

      return result;
    } catch (_) {
      await clearCache();
      return null;
    }
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheTimeKey);
  }

  Future<bool> hasValidCache() async {
    return (await getCachedBanners()) != null;
  }
}
