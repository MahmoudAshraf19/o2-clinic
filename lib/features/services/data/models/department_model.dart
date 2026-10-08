import 'package:o2_clinic/common/models/fs_doctor_model.dart';

class DepartmentModel {
  final String id;
  final String name;
  final String subtitle;
  final String icon;
  final String description;
  final List<DoctorModel> doctors;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.description,
    required this.doctors,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      subtitle: json['subtitle'] ?? '',
      icon: json['icon'] ?? '',
      description: json['description'] ?? '',
      doctors:
          (json['doctors'] as List<dynamic>?)
              ?.map((doctor) => DoctorModel.fromMap(id: doctor['id'] ?? '', map: doctor))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subtitle': subtitle,
      'icon': icon,
      'description': description,
      'doctors': [],
    };
  }
}
