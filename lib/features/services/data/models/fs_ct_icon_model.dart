class CtIconModel {
  final String id;
  final String icon; // string name from firestore

  CtIconModel({required this.id, required this.icon});

  factory CtIconModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return CtIconModel(id: id, icon: map['icon'] ?? '');
  }
}
