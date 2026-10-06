import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/discount_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';

class DiscountInputWidget {
  static void show(BuildContext context) {
    final discountController = Get.find<DiscountController>();
    final TextEditingController textController = TextEditingController();

    // Reset errors when opening
    discountController.verificationError.value = '';

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getTranslatedString(
                      'enter_coupon',
                      Get.locale?.languageCode,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,

                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.grey),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  hintText: _getTranslatedString(
                    'coupon_hint',
                    Get.locale?.languageCode,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (discountController.verificationError.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      discountController.verificationError.value,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: Obx(() {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: discountController.isVerifyingCode.value
                        ? null
                        : () async {
                            if (textController.text.trim().isEmpty) return;
                            await discountController.verifyDiscountCode(
                              textController.text.trim(),
                            );
                            if (discountController.currentValidCode.value !=
                                null) {
                              Get.back();
                            }
                          },
                    child: discountController.isVerifyingCode.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _getTranslatedString(
                              'apply',
                              Get.locale?.languageCode,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                }),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  static String _getTranslatedString(String key, String? langCode) {
    final lang = langCode ?? 'ar';
    switch (key) {
      case 'enter_coupon':
        if (lang == 'ar') return 'إدخال كوبون الخصم';
        if (lang == 'en') return 'Enter Discount Coupon';
        if (lang == 'he') return 'הזן קופון הנחה';
        return 'إدخال كوبون الخصم';
      case 'coupon_hint':
        if (lang == 'ar') return 'رقم الكوبون';
        if (lang == 'en') return 'Coupon Code';
        if (lang == 'he') return 'קוד קופון';
        return 'رقم الكوبون';
      case 'apply':
        if (lang == 'ar') return 'تطبيق الكوبون';
        if (lang == 'en') return 'Apply Coupon';
        if (lang == 'he') return 'החל קופון';
        return 'تطبيق الكوبون';
      default:
        return '';
    }
  }
}
