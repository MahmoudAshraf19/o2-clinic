import 'package:flutter/material.dart';

import '../../../../services/data/models/fs_radiology_ct_model.dart';
import '../../../../services/data/services/fs_radiology_cache_service.dart';

class CTScanData {
  static Future<Map<String, List<ScanCardData>>> loadSections() async {
    final items = await RadiologyCacheService.getCtCategories();

    final core = <ScanCardData>[];
    final specialized = <ScanCardData>[];

    for (final item in items) {
      final mapped = _map(item);

      if (item.type.toLowerCase().contains('core') ||
          item.type.toLowerCase().contains('diagnostic')) {
        core.add(mapped);
      } else {
        specialized.add(mapped);
      }
    }

    return {'coreDiagnostics': core, 'specializedImaging': specialized};
  }

  static ScanCardData _map(RadiologyCtModel item) {
    return ScanCardData(
      id: item.id,
      title: item.titleEn,
      description: item.descriptionEn,
      icon: _iconFromName(item.icon),
      bigIcon: _iconFromName(item.icon),
      price: item.price.toDouble(),
    );
  }

  static IconData _iconFromName(String value) {
    switch (value) {
      case 'psychology_outlined':
        return Icons.psychology_outlined;
      case 'accessible_forward_outlined':
        return Icons.accessible_forward_outlined;
      case 'air_outlined':
        return Icons.air_outlined;
      case 'dinner_dining_outlined':
        return Icons.dinner_dining_outlined;
      case 'airline_seat_legroom_extra_outlined':
        return Icons.airline_seat_legroom_extra_outlined;
      case 'accessibility_new_outlined':
        return Icons.accessibility_new_outlined;
      case 'fitness_center_outlined':
        return Icons.fitness_center_outlined;
      default:
        return Icons.medical_services_outlined;
    }
  }
}

class ScanCardData {
  const ScanCardData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.bigIcon,
    required this.price,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final IconData bigIcon;
  final double price;
}
