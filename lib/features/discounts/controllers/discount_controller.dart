import 'package:get/get.dart';
import '../models/discount_type_model.dart';
import '../models/discount_code_model.dart';
import '../services/discount_service.dart';

class DiscountController extends GetxController {
  final DiscountService _discountService = DiscountService();

  var discountTypes = <DiscountTypeModel>[].obs;
  var discountCodes = <DiscountCodeModel>[].obs;

  var isLoadingTypes = false.obs;
  var isLoadingCodes = false.obs;
  var isVerifyingCode = false.obs;

  var currentValidCode = Rxn<DiscountCodeModel>();
  var verificationError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDiscountTypes();
  }

  Future<void> fetchDiscountTypes() async {
    try {
      isLoadingTypes(true);
      final types = await _discountService.getDiscountTypes();
      discountTypes.assignAll(types);
    } catch (e) {
      print('Error fetching discount types: $e');
    } finally {
      isLoadingTypes(false);
    }
  }

  Future<void> fetchDiscountCodes() async {
    try {
      isLoadingCodes(true);
      final codes = await _discountService.getDiscountCodes();
      discountCodes.assignAll(codes);
    } catch (e) {
      print('Error fetching discount codes: $e');
    } finally {
      isLoadingCodes(false);
    }
  }

  String _getErrorMessage(String key) {
    final lang = Get.locale?.languageCode ?? 'ar';
    if (key == 'invalid') {
      if (lang == 'en') return "Invalid or inactive discount code";
      if (lang == 'he') return "קוד ההנחה אינו חוקי או שאינו פעיל";
      return "كود الخصم غير صحيح أو غير مفعل";
    }
    if (key == 'not_started') {
      if (lang == 'en') return "Discount code is not active yet";
      if (lang == 'he') return "קוד ההנחה עדיין לא פעיל";
      return "كود الخصم لم يبدأ بعد";
    }
    if (key == 'expired') {
      if (lang == 'en') return "Discount code is expired";
      if (lang == 'he') return "קוד ההנחה פג תוקף";
      return "كود الخصم منتهي الصلاحية";
    }
    if (key == 'limit_reached') {
      if (lang == 'en') return "Discount code usage limit reached";
      if (lang == 'he') return "הגעת להגבלת השימוש בקוד ההנחה";
      return "تم تجاوز الحد الأقصى لاستخدام كود الخصم";
    }
    if (key == 'error') {
      if (lang == 'en') return "Error verifying code";
      if (lang == 'he') return "שגיאה באימות קוד";
      return "حدث خطأ أثناء التحقق من الكود";
    }
    return key;
  }

  Future<void> verifyDiscountCode(String codeText) async {
    if (codeText.trim().isEmpty) return;

    try {
      isVerifyingCode(true);
      verificationError('');
      currentValidCode.value = null;

      final code = await _discountService.getDiscountCodeByCode(
        codeText.trim(),
      );

      if (code == null) {
        verificationError(_getErrorMessage('invalid'));
        return;
      }

      final now = DateTime.now();
      if (code.startDate != null && now.isBefore(code.startDate!)) {
        verificationError(_getErrorMessage('not_started'));
        return;
      }

      if (code.endDate != null && now.isAfter(code.endDate!)) {
        verificationError(_getErrorMessage('expired'));
        return;
      }

      // Check usage limits: -1 means infinite uses
      if (!code.isInfiniteUse && code.usedCount >= code.usageLimit) {
        verificationError(_getErrorMessage('limit_reached'));
        return;
      }

      currentValidCode.value = code;
    } catch (e) {
      verificationError(_getErrorMessage('error'));
      print('Error verifying discount code: $e');
    } finally {
      isVerifyingCode(false);
    }
  }

  void removeDiscountCode() {
    currentValidCode.value = null;
    verificationError('');
  }
}
