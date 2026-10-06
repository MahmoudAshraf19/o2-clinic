import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/xray_data_model.dart';

class XrayDataFirestoreService {
  XrayDataFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String _categoryCollection = 'radiology_category';
  static const String _categoryDocument = 'x_ray';
  static const String _serviceCollection = 'x_ray_data';

  Future<XrayCatalog> getCatalog() async {
    _logDivider();
    _logInfo('Starting X-Ray catalog fetch...');
    _logInfo('Reading categories from $_categoryCollection/$_categoryDocument');
    _logInfo('Reading services from $_serviceCollection');

    try {
      final categoryDocFuture = _firestore
          .collection(_categoryCollection)
          .doc(_categoryDocument)
          .get(const GetOptions(source: Source.serverAndCache));

      final servicesFuture = _firestore
          .collection(_serviceCollection)
          .get(const GetOptions(source: Source.serverAndCache));

      final categoryDoc = await categoryDocFuture;
      final servicesSnapshot = await servicesFuture;

      _logInfo('Category document fetched.');
      _logInfo('Document exists: ${categoryDoc.exists}');
      _logInfo('Document id: ${categoryDoc.id}');
      _logInfo('Services snapshot fetched.');
      _logInfo('Services docs count: ${servicesSnapshot.docs.length}');

      if (!categoryDoc.exists) {
        _logError(
          'Category document not found: $_categoryCollection/$_categoryDocument',
        );
        _logDivider();
        return XrayCatalog.empty();
      }

      final categoryData = categoryDoc.data();
      if (categoryData == null || categoryData.isEmpty) {
        _logError('Category document exists but data is empty.');
        _logDivider();
        return XrayCatalog.empty();
      }

      _logSuccess('Raw category document loaded successfully.');
      _logInfo('Top-level keys count: ${categoryData.keys.length}');
      _logInfo('Top-level keys: ${categoryData.keys.join(', ')}');

      final categoryMap = _extractCategoryMap(categoryData);
      _logInfo('Detected category entries: ${categoryMap.length}');

      final services = <XrayServiceModel>[];
      var skippedServices = 0;

      for (final doc in servicesSnapshot.docs) {
        final raw = doc.data();

        if (raw.isEmpty) {
          skippedServices++;
          _logWarn('Service doc "${doc.id}" is empty. Skipped.');
          continue;
        }

        try {
          final service = XrayServiceModel.fromMap(
            id: _readString(raw, const ['id'], fallback: doc.id),
            map: raw,
          );
          services.add(service);
        } catch (e) {
          skippedServices++;
          _logWarn('Failed to parse service "${doc.id}" -> $e');
        }
      }

      _logSuccess('Services parsed: ${services.length}');
      if (skippedServices > 0) {
        _logWarn('Services skipped: $skippedServices');
      }

      final countByCategory = <String, int>{};
      for (final service in services) {
        if (service.categoryId.trim().isEmpty) continue;
        countByCategory[service.categoryId] =
            (countByCategory[service.categoryId] ?? 0) + 1;
      }

      final categories = <XrayCategoryModel>[];
      var skippedCategories = 0;

      for (final entry in categoryMap.entries) {
        final raw = entry.value;

        if (raw is! Map<String, dynamic>) {
          skippedCategories++;
          _logWarn('Category "${entry.key}" is not a valid map. Skipped.');
          continue;
        }

        try {
          final id = _readString(raw, const ['id'], fallback: entry.key);

          final model = XrayCategoryModel.fromMap(
            id: id,
            map: raw,
            serviceCount: countByCategory[id] ?? 0,
          );

          categories.add(model);
        } catch (e) {
          skippedCategories++;
          _logWarn('Failed to parse category "${entry.key}" -> $e');
        }
      }

      _logSuccess('Categories parsed: ${categories.length}');
      if (skippedCategories > 0) {
        _logWarn('Categories skipped: $skippedCategories');
      }

      categories.sort((a, b) {
        final orderCompare = a.order.compareTo(b.order);
        if (orderCompare != 0) return orderCompare;
        return a.titleEn.toLowerCase().compareTo(b.titleEn.toLowerCase());
      });

      services.sort((a, b) {
        final orderCompare = a.order.compareTo(b.order);
        if (orderCompare != 0) return orderCompare;
        return a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase());
      });

      final grouped = <String, List<XrayServiceModel>>{};
      for (final service in services) {
        if (service.categoryId.trim().isEmpty) continue;
        grouped.putIfAbsent(service.categoryId, () => <XrayServiceModel>[]);
        grouped[service.categoryId]!.add(service);
      }

      _logSuccess('Grouping complete.');
      _logInfo('Grouped categories with services: ${grouped.length}');
      _logInfo('Final categories count: ${categories.length}');
      _logInfo('Final services count: ${services.length}');

      for (final category in categories) {
        _logInfo(
          '📂 Category => id=${category.id}, '
          'title=${category.titleEn}, '
          'icon=${category.iconKey}, '
          'services=${category.serviceCount}',
        );
      }

      for (final service in services) {
        _logInfo(
          '🧪 Service => id=${service.id}, '
          'category=${service.categoryId}, '
          'name=${service.nameEn}, '
          'price=${service.price}',
        );
      }

      final knownCategoryIds = categories.map((e) => e.id).toSet();
      final unknownServices = services
          .where(
            (s) =>
                s.categoryId.isNotEmpty &&
                !knownCategoryIds.contains(s.categoryId),
          )
          .toList();

      if (unknownServices.isNotEmpty) {
        _logWarn(
          'Found ${unknownServices.length} service(s) with categoryId not found in categories.',
        );
        for (final s in unknownServices) {
          _logWarn('Orphan service => ${s.id} | category=${s.categoryId}');
        }
      }

      _logSuccess('X-Ray catalog loaded successfully.');
      _logDivider();

      return XrayCatalog(
        categories: categories,
        services: services,
        servicesByCategory: Map<String, List<XrayServiceModel>>.unmodifiable(
          grouped,
        ),
      );
    } on FirebaseException catch (e, stack) {
      _logError('FirebaseException occurred.');
      _logError('Code: ${e.code}');
      _logError('Message: ${e.message ?? "No message"}');
      _logError('Plugin: ${e.plugin}');
      _logError('Stack: $stack');
      _logDivider();
      return XrayCatalog.empty();
    } catch (e, stack) {
      _logError('Unexpected error while fetching X-Ray catalog.');
      _logError('Error: $e');
      _logError('Stack: $stack');
      _logDivider();
      return XrayCatalog.empty();
    }
  }

  Map<String, dynamic> _extractCategoryMap(Map<String, dynamic> raw) {
    final radiologyCategory = _asMap(raw['radiology_category']);
    if (radiologyCategory.isNotEmpty) {
      final xRay = _asMap(radiologyCategory['x_ray']);
      if (xRay.isNotEmpty) return xRay;
      return radiologyCategory;
    }

    final xRay = _asMap(raw['x_ray']);
    if (xRay.isNotEmpty) return xRay;

    final xRayCategories = _asMap(raw['x_ray_categories']);
    if (xRayCategories.isNotEmpty) return xRayCategories;

    final flatCategories = <String, dynamic>{};
    for (final entry in raw.entries) {
      if (entry.value is Map<String, dynamic>) {
        final item = entry.value as Map<String, dynamic>;
        if (item.containsKey('title_en') ||
            item.containsKey('title_ar') ||
            item.containsKey('icon')) {
          flatCategories[entry.key] = item;
        }
      }
    }
    return flatCategories;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return <String, dynamic>{};
  }

  String _readString(
    Map<String, dynamic> map,
    List<String> keys, {
    required String fallback,
  }) {
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  void _logDivider() {
  }

  void _logInfo(String message) {
  }

  void _logSuccess(String message) {
  }

  void _logWarn(String message) {
  }

  void _logError(String message) {
  }
}
