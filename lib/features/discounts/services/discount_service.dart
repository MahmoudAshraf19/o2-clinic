import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/discount_type_model.dart';
import '../models/discount_code_model.dart';

class DiscountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DiscountTypeModel>> getDiscountTypes() async {
    try {
      final snapshot = await _firestore.collection('discount_types').get();
      return snapshot.docs.map((doc) => DiscountTypeModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get discount types: $e');
    }
  }

  Future<List<DiscountCodeModel>> getDiscountCodes() async {
    try {
      final snapshot = await _firestore.collection('discount_codes').get();
      return snapshot.docs.map((doc) => DiscountCodeModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get discount codes: $e');
    }
  }

  Future<DiscountCodeModel?> getDiscountCodeByCode(String code) async {
    try {
      final snapshot = await _firestore
          .collection('discount_codes')
          .where('code', isEqualTo: code)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return DiscountCodeModel.fromSnapshot(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get discount code: $e');
    }
  }
}
