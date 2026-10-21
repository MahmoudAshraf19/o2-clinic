import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medical_device_model.dart';

class MedicalDeviceService {
  MedicalDeviceService._();
  static final MedicalDeviceService instance = MedicalDeviceService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MedicalDeviceModel>? _cachedDevices;

  Future<List<MedicalDeviceModel>> getMedicalDevices({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedDevices != null && _cachedDevices!.isNotEmpty) {
      return _cachedDevices!;
    }

    try {
      final snapshot = await _firestore
          .collection('medical_device')
          .get();

      final list = snapshot.docs
          .map((doc) => MedicalDeviceModel.fromMap(doc.data(), doc.id))
          .toList();

      list.sort((a, b) => a.index.compareTo(b.index));
      _cachedDevices = list;
      return list;
    } catch (e) {
      return _cachedDevices ?? [];
    }
  }

  void clearCache() {
    _cachedDevices = null;
  }
}
