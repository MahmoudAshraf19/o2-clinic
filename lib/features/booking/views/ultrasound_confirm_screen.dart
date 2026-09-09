import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../common/app_constants.dart';
import '../../../common/controllers/app_constants_controller.dart';
import '../controllers/booking.dart';
import '../widgets/Ultrasound/ultrasound_data.dart';
import '../../discounts/controllers/discount_controller.dart';
import '../../discounts/widgets/discount_input_widget.dart';
import 'ultrasound_success_screen.dart';

class UltrasoundConfirmScreen extends StatefulWidget {
  final UltrasoundModel model;
  final DateTime date;
  final String time;

  const UltrasoundConfirmScreen({
    super.key,
    required this.model,
    required this.date,
    required this.time,
  });

  @override
  State<UltrasoundConfirmScreen> createState() => _UltrasoundConfirmScreenState();
}

class _UltrasoundConfirmScreenState extends State<UltrasoundConfirmScreen> {
  bool _isBooking = false;
  final DiscountController discountController = Get.put(DiscountController());

  @override
  void dispose() {
    discountController.removeDiscountCode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Get.locale?.languageCode ?? 'en';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      bottomNavigationBar: _bottomBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(AppLocalizations.of(context)!.type),
                    const SizedBox(height: 10),
                    _imagingCard(lang),
                    const SizedBox(height: 18),
                    _sectionTitle(AppLocalizations.of(context)!.appointmentSchedule),
                    const SizedBox(height: 10),
                    _scheduleCard(lang),
                    const SizedBox(height: 18),
                    _sectionTitle(AppLocalizations.of(context)!.clinicLocation),
                    const SizedBox(height: 10),
                    _locationCard(),
                    const SizedBox(height: 18),
                    _sectionTitle(AppLocalizations.of(context)!.paymentSummary),
                    const SizedBox(height: 10),
                    _paymentCard(),
                    const SizedBox(height: 12),
                    _discountSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.confirmImaging,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.2,
                fontFamily: AppFonts.dancingScript,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontFamily: AppFonts.dancingScript,
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _imagingCard(String lang) {
    return _card(
      child: Row(
        children: [
          const Icon(Icons.medical_services, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.model.titleForLanguage(lang),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleCard(String lang) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                _formatDate(widget.date, lang),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.time
                  .replaceAll('AM', AppLocalizations.of(context)!.am)
                  .replaceAll('PM', AppLocalizations.of(context)!.pm),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationCard() {
    return _card(
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.o2ImagingCenterDowntownHubn124,
              style: TextStyle(color: AppColors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard() {
    final originalAmount = widget.model.price;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Obx(() {
        final currency = Get.find<AppConstantsController>().currencySymbol.value;
        final code = discountController.currentValidCode.value;
        final type = discountController.discountTypes.firstWhereOrNull((t) => t.id == code?.discountTypeId);
        
        num finalAmount = originalAmount;
        num discountAmount = 0;
        
        if (code != null && type != null) {
          if (type.calculationMethod == 'percentage') {
            discountAmount = (originalAmount * (code.value / 100));
            if (code.maximumDiscountAmount != null && discountAmount > code.maximumDiscountAmount!) {
              discountAmount = code.maximumDiscountAmount!;
            }
            finalAmount = originalAmount - discountAmount;
          } else if (type.calculationMethod == 'fixed') {
            discountAmount = code.value;
            finalAmount = originalAmount - discountAmount;
          } else if (type.calculationMethod == 'free') {
            discountAmount = originalAmount;
            finalAmount = 0;
          }
          if (finalAmount < 0) finalAmount = 0;
        }

        return Column(
          children: [
            if (code != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.paymentSummary,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    "$originalAmount $currency",
                    style: TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.grey,
                      
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    code.localizedTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    "-$discountAmount $currency",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.totalPayment,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "$finalAmount $currency",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget _discountSection() {
    final langCode = Get.locale?.languageCode ?? 'ar';
    String askText = 'هل لديك كوبون خصم؟';
    if (langCode == 'en') askText = 'Do you have a discount coupon?';
    if (langCode == 'he') askText = 'יש לך קופון הנחה?';

    return Obx(() {
      if (discountController.currentValidCode.value != null) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  discountController.currentValidCode.value!.code,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => discountController.removeDiscountCode(),
              child: const Icon(Icons.close, color: Colors.red, size: 20),
            ),
          ],
        );
      }
      return GestureDetector(
        onTap: () => DiscountInputWidget.show(context),
        child: Row(
          children: [
            const Icon(Icons.local_offer_outlined, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              askText,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _bottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _isBooking ? null : () async {
              setState(() => _isBooking = true);
              try {
                Map<String, dynamic>? discountData;
                final code = discountController.currentValidCode.value;
                final type = discountController.discountTypes.firstWhereOrNull((t) => t.id == code?.discountTypeId);
                num finalAmount = widget.model.price;
                num discountAmount = 0;
                
                if (code != null && type != null) {
                  if (type.calculationMethod == 'percentage') {
                    discountAmount = (widget.model.price * (code.value / 100));
                    if (code.maximumDiscountAmount != null && discountAmount > code.maximumDiscountAmount!) {
                      discountAmount = code.maximumDiscountAmount!;
                    }
                    finalAmount = widget.model.price - discountAmount;
                  } else if (type.calculationMethod == 'fixed') {
                    discountAmount = code.value;
                    finalAmount = widget.model.price - discountAmount;
                  } else if (type.calculationMethod == 'free') {
                    discountAmount = widget.model.price;
                    finalAmount = 0;
                  }
                  if (finalAmount < 0) finalAmount = 0;
                  
                  discountData = {
                    "code_id": code.id,
                    "code": code.code,
                    "type": type.calculationMethod,
                    "discount_value": discountAmount,
                    "original_amount": widget.model.price,
                  };
                }

                final currentUser = FirebaseAuth.instance.currentUser;
                final bookingRes = await BookingFirestoreService().createImagingBooking(
                  user: BookingUserInfo(
                    userId: currentUser?.uid ?? 'guest',
                    name: currentUser?.displayName ?? 'Guest Patient',
                    countryCode: '',
                    number: currentUser?.phoneNumber ?? '',
                  ),
                  categoryId: widget.model.title,
                  subcategoryId: '',
                  nameEn: widget.model.title,
                  nameAr: widget.model.title,
                  selectedDate: widget.date,
                  selectedTime: widget.time,
                  amount: finalAmount,
                  discountData: discountData,
                );

                if (bookingRes.success) {
                  Get.offAll(
                    () => UltrasoundSuccessScreen(
                      model: widget.model,
                      date: widget.date,
                      time: widget.time,
                      bookingId: bookingRes.bookingId ?? "ULS_${DateTime.now().millisecondsSinceEpoch % 10000}",
                    ),
                  );
                } else {
                  Get.snackbar(
                    AppLocalizations.of(context)!.error,
                    bookingRes.message,
                    snackPosition: SnackPosition.TOP,
                  );
                }
              } catch (e) {
                 Get.snackbar(
                   AppLocalizations.of(context)!.error,
                   'Booking failed: $e',
                   snackPosition: SnackPosition.TOP,
                 );
              } finally {
                if (mounted) setState(() => _isBooking = false);
              }
            },
            child: _isBooking
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(AppLocalizations.of(context)!.confirm, style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  String _formatDate(DateTime date, String lang) {
    final formatter = DateFormat('d MMM', lang);
    return formatter.format(date);
  }
}
