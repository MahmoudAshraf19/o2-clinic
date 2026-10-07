import '../../../../services/data/models/fs_xray_data_model.dart';
import '../../../../services/data/services/fs_xray_data_cache_service.dart';

class XRayData {
  static List<XrayCategoryModel> categories = [];
  static List<XrayServiceModel> services = [];
  static Map<String, List<XrayServiceModel>> servicesByCategory = {};

  static Future<void> loadCategories({bool forceRefresh = false}) async {
    final catalog = await XrayDataCacheService.getCatalog(
      forceRefresh: forceRefresh,
    );
    categories = catalog.categories;
    services = catalog.services;
    servicesByCategory = catalog.servicesByCategory;
  }

  static List<XrayServiceModel> servicesForCategory(String categoryId) {
    return servicesByCategory[categoryId] ?? const <XrayServiceModel>[];
  }

  static XrayCategoryModel? categoryById(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  static void clearCache() {
    XrayDataCacheService.clearCache();
  }
}
