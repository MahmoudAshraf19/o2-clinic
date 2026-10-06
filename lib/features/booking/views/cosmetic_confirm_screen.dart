import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../common/controllers/global_auth_controller.dart';
import '../../../common/app_constants.dart';
import '../../services/models/cosmetic_category_model.dart';
import '../controllers/booking.dart';
import '../controllers/cosmetic_booking_controller.dart';
import '../../discounts/controllers/discount_controller.dart';
import '../../discounts/widgets/discount_input_widget.dart';
import 'cosmetic_success_screen.dart';

class CosmeticConfirmScreen extends StatefulWidget {
  final CosmeticCategoryModel model;
  final DateTime selectedDate;
  final String selectedTime;
  final String controllerTag;
  final double totalPrice;

  const CosmeticConfirmScreen({
    super.key,
    required this.model,
    required this.selectedDate,
    required this.selectedTime,
    required this.controllerTag,
    required this.totalPrice,
  });

  @override
  State<CosmeticConfirmScreen> createState() => _CosmeticConfirmScreenState();
}

class _CosmeticConfirmScreenState extends State<CosmeticConfirmScreen> {
  bool _isBooking = false;
  final DiscountController discountController = Get.put(DiscountController());

  @override
  void dispose() {
    discountController.removeDiscountCode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: _bottomBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Service Details"),
                    SizedBox(height: 10),
                    _serviceCard(),
                    SizedBox(height: 18),
                    _sectionTitle("Appointment Schedule"),
                    SizedBox(height: 10),
                    _scheduleCard(),
                    SizedBox(height: 18),
                    _sectionTitle("Clinic Location"),
                    SizedBox(height: 10),
                    _locationCard(),
                    SizedBox(height: 18),
                    _sectionTitle("Payment Summary"),
                    SizedBox(height: 10),
                    _paymentCard(),
                    SizedBox(height: 12),
                    _discountSection(),
                    SizedBox(height: 18),
                    _sectionTitle("Patient Info"),
                    SizedBox(height: 10),
                    _patientCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _topBar() {
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _t("Confirmation"),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontFamily: AppFonts.dancingScript,
                  letterSpacing: 0.4,
                  height: 1,
                ),
              ),
              SizedBox(height: 4),
              Text(
                _t("Review Appointment Details"),
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7).withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _t(String text) {
    final lang = Get.locale?.languageCode ?? 'en';
    if (lang == 'ar') {
      switch (text) {
        case "Confirmation":
          return "التأكيد";
        case "Review Appointment Details":
          return "مراجعة تفاصيل الموعد";
        case "Service Details":
          return "تفاصيل الخدمة";
        case "Appointment Schedule":
          return "موعد الحجز";
        case "Clinic Location":
          return "موقع العيادة";
        case "Payment Summary":
          return "ملخص الدفع";
        case "Patient Info":
          return "معلومات المريض";
        case "Cosmetic Department":
          return "قسم التجميل";
        case "Direct Services":
          return "خدمات مباشرة";
        case "Total Payment":
          return "إجمالي الدفع";
        case "Confirm Booking":
          return "تأكيد الحجز";
        case "Booking Failed":
          return "فشل الحجز";
        case "Error":
          return "خطأ";
        case "Please log in first":
          return "يجب تسجيل الدخول";
        case "O2 Clinic Headquarters":
          return "مقر o2 clinic";
        case "Guest Patient":
          return "مريض زائر";
        case "Unknown Email":
          return "بريد غير معروف";
      }
    } else if (lang == 'he') {
      switch (text) {
        case "Confirmation":
          return "אישור";
        case "Review Appointment Details":
          return "סקירת פרטי תור";
        case "Service Details":
          return "פרטי שירות";
        case "Appointment Schedule":
          return "מועד התור";
        case "Clinic Location":
          return "מיקום המרפאה";
        case "Payment Summary":
          return "סיכום תשלום";
        case "Patient Info":
          return "פרטי מטופל";
        case "Cosmetic Department":
          return "מחלקת קוסמטיקה";
        case "Direct Services":
          return "שירותים ישירים";
        case "Total Payment":
          return "תשלום כולל";
        case "Confirm Booking":
          return "אישור הזמנה";
        case "Booking Failed":
          return "הזמנה נכשלה";
        case "Error":
          return "שגיאה";
        case "Please log in first":
          return "נא להתחבר תחילה";
        case "O2 Clinic Headquarters":
          return "מטה o2 clinic";
        case "Guest Patient":
          return "מטופל אורח";
        case "Unknown Email":
          return "דוא\"ל לא ידוע";
      }
    }
    return text;
  }

  Widget _sectionTitle(String text) {
    return Text(
      _t(text),
      style: TextStyle(
        fontSize: 18,
        fontFamily: AppFonts.dancingScript,
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _serviceCard() {
    
    
    return _card(
      child: Row(
        children: [
          Builder(builder: (context) {
          final langCode = Get.locale?.languageCode ?? 'en';
          return Row(
            children: [
              CircleAvatar(
            radius: 26,
            backgroundImage: widget.model.image.isNotEmpty
                ? CachedNetworkImageProvider(widget.model.image)
                : null,
            child: widget.model.image.isEmpty
                ? Icon(widget.model.getBadgeIcon(), color: Colors.white)
                : null,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.model.getName(langCode),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  (widget.model.id == 'Sleep_study' ||
                          widget.model.id == 'pulmonary_function')
                      ? _t("Direct Services")
                      : _t("Cosmetic Department"),
                  style: TextStyle(color: AppColors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.verified, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _scheduleCard() {
    final dateKey = BookingFirestoreService.formatDate(widget.selectedDate);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                dateKey,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.selectedTime,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
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
          Icon(Icons.location_on, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              _t("O2 Clinic Headquarters"),
              style: TextStyle(color: AppColors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard() {
    final originalAmount = widget.totalPrice;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Obx(() {
        final code = discountController.currentValidCode.value;
        final type = discountController.discountTypes.firstWhereOrNull(
          (t) => t.id == code?.discountTypeId,
        );

        num finalAmount = originalAmount;
        num discountAmount = 0;

        if (code != null && type != null) {
          if (type.calculationMethod == 'percentage') {
            discountAmount = (originalAmount * (code.value / 100));
            if (code.maximumDiscountAmount != null &&
                discountAmount > code.maximumDiscountAmount!) {
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
                    _t("Payment Summary"),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,

                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    "$originalAmount ${AppConstants.currencySymbol}",
                    style: TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
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
                    "-$discountAmount ${AppConstants.currencySymbol}",
                    style: TextStyle(fontSize: 14, color: Colors.green),
                  ),
                ],
              ),
              const Divider(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _t("Total Payment"),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,

                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "$finalAmount ${AppConstants.currencySymbol}",
                  style: TextStyle(
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
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  discountController.currentValidCode.value!.code,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => discountController.removeDiscountCode(),
              child: Icon(Icons.close, color: Colors.red, size: 20),
            ),
          ],
        );
      }
      return GestureDetector(
        onTap: () => DiscountInputWidget.show(context),
        child: Row(
          children: [
            Icon(
              Icons.local_offer_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              askText,
              style: TextStyle(
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

  Widget _patientCard() {
    return Obx(() {
      final globalAuth = Get.isRegistered<GlobalAuthController>()
          ? Get.find<GlobalAuthController>()
          : null;
      final userData = globalAuth?.currentUserData.value;
      final currentUser = FirebaseAuth.instance.currentUser;

      String userName = _t("Guest Patient");
      String email = _t("Unknown Email");

      if (userData != null) {
        userName =
            userData['name'] ??
            userData['first_name'] ??
            currentUser?.displayName ??
            _t("Guest Patient");
        final contactMap = userData['contact'] as Map<String, dynamic>?;
        final phoneMap = userData['phone'] as Map<String, dynamic>?;
        final phone = contactMap?['phone'] ?? phoneMap?['full_phone'];
        email = phone ?? currentUser?.email ?? _t("Unknown Email");
      } else if (currentUser != null) {
        userName = currentUser.displayName ?? _t("Guest Patient");
        email = currentUser.email ?? _t("Unknown Email");
      }

      return _card(
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: AppColors.surface,
              child: Icon(Icons.person, color: AppColors.primary),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    email,
                    style: TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: child,
    );
  }

  Widget _bottomBar(BuildContext context) {
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.4)),
        ),
      ),
      child: ElevatedButton(
        onPressed: _isBooking ? null : _confirmBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: _isBooking
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Theme.of(context).cardColor,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                _t("Confirm Booking"),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).cardColor,
                ),
              ),
      ),
    );
  }

  // ================= LOGIC =================

  Future<void> _confirmBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      Get.snackbar(_t('Error'), _t('Please log in first'));
      return;
    }

    setState(() => _isBooking = true);

    try {
      

      Map<String, dynamic>? discountData;
      final code = discountController.currentValidCode.value;
      final type = discountController.discountTypes.firstWhereOrNull(
        (t) => t.id == code?.discountTypeId,
      );
      num finalAmount = widget.totalPrice;
      num discountAmount = 0;

      if (code != null && type != null) {
        if (type.calculationMethod == 'percentage') {
          discountAmount = (widget.totalPrice * (code.value / 100));
          if (code.maximumDiscountAmount != null &&
              discountAmount > code.maximumDiscountAmount!) {
            discountAmount = code.maximumDiscountAmount!;
          }
          finalAmount = widget.totalPrice - discountAmount;
        } else if (type.calculationMethod == 'fixed') {
          discountAmount = code.value;
          finalAmount = widget.totalPrice - discountAmount;
        } else if (type.calculationMethod == 'free') {
          discountAmount = widget.totalPrice;
          finalAmount = 0;
        }
        if (finalAmount < 0) finalAmount = 0;

        discountData = {
          "code_id": code.id,
          "code": code.code,
          "type": type.calculationMethod,
          "discount_value": discountAmount,
          "original_amount": widget.totalPrice,
        };
      }
      final isDirect =
          widget.model.id == 'Sleep_study' ||
          widget.model.id == 'pulmonary_function';

      BookingResult bookingRes;
      if (isDirect) {
        bookingRes = await BookingFirestoreService().createDirectBooking(
          user: BookingUserInfo(
            userId: user.uid,
            name: user.displayName ?? "Guest",
            countryCode: "+20",
            number: "",
          ),
          serviceId: widget.model.id,
          nameEn: widget.model.getName('en'),
          nameAr: widget.model.getName('ar'),
          selectedDate: widget.selectedDate,
          selectedTime: widget.selectedTime,
          amount: finalAmount,
          discountData: discountData,
        );
      } else {
        bookingRes = await BookingFirestoreService().createCosmeticBooking(
          user: BookingUserInfo(
            userId: user.uid,
            name: user.displayName ?? "Guest",
            countryCode: "+20",
            number: "",
          ),
          cosmeticId: widget.model.id,
          nameEn: widget.model.getName('en'),
          nameAr: widget.model.getName('ar'),
          selectedDate: widget.selectedDate,
          selectedTime: widget.selectedTime,
          amount: finalAmount,
          discountData: discountData,
        );
      }

      if (bookingRes.success) {
        if (Get.isRegistered<CosmeticAppointmentBookingController>(
          tag: widget.controllerTag,
        )) {
          Get.delete<CosmeticAppointmentBookingController>(
            tag: widget.controllerTag,
          );
        }

        Get.off(
          () => CosmeticSuccessScreen(
            model: widget.model,
            selectedDate: widget.selectedDate,
            selectedTime: widget.selectedTime,
            bookingId: bookingRes.bookingId ?? 'Unknown',
          ),
        );
      } else {
        Get.snackbar(
          _t('Booking Failed'),
          bookingRes.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        _t('Error'),
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }
}






