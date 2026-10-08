import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DiscountTypeModel {
  final String id;
  final Map<String, String> name;
  final Map<String, String> description;
  final String calculationMethod;
  final bool isActive;
  final String status;

  DiscountTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.calculationMethod,
    required this.isActive,
    required this.status,
  });

  String get localizedName {
    final langCode = Get.locale?.languageCode ?? 'ar';
    return name[langCode] ?? name['ar'] ?? '';
  }

  String get localizedDescription {
    final langCode = Get.locale?.languageCode ?? 'ar';
    return description[langCode] ?? description['ar'] ?? '';
  }

  factory DiscountTypeModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return DiscountTypeModel(
      id: documentId,
      name: Map<String, String>.from(data['name'] ?? {}),
      description: Map<String, String>.from(data['description'] ?? {}),
      calculationMethod: data['calculation_method'] ?? '',
      isActive: data['is_active'] ?? false,
      status: data['status'] ?? 'active',
    );
  }

  factory DiscountTypeModel.fromSnapshot(DocumentSnapshot snapshot) {
    return DiscountTypeModel.fromMap(
      snapshot.data() as Map<String, dynamic>,
      snapshot.id,
    );
  }
}
