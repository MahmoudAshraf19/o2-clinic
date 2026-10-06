import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../common/controllers/global_auth_controller.dart';
import '../../../../common/app_constants.dart';
import '../../../services/models/radiology_category_model.dart';
import '../../controllers/radiology_booking_controller.dart';
import '../../../discounts/controllers/discount_controller.dart';
import '../../../discounts/widgets/discount_input_widget.dart';
import 'radiology_booking_success_screen.dart';
import '../../../chat_support/services/radiology_chat_service.dart';
import '../../../chat_support/screens/radiology_chat_screen.dart';
import 'dart:async';

class RadiologyConfirmBookingScreen extends StatefulWidget {
  final RadiologyCategoryModel service;
  final DateTime selectedDate;
  final String selectedTime;
  final String controllerTag;
  final String bookingId;

  const RadiologyConfirmBookingScreen({
    super.key,
    required this.service,
    required this.selectedDate,
    required this.selectedTime,
    required this.controllerTag,
    required this.bookingId,
  });

  @override
  State<RadiologyConfirmBookingScreen> createState() =>
      _RadiologyConfirmBookingScreenState();
}

class _RadiologyConfirmBookingScreenState
    extends State<RadiologyConfirmBookingScreen> {
  bool _isBooking = false;
  final DiscountController discountController = Get.put(DiscountController());
  final RxNum _determinedPrice = RxNum(-1);
  StreamSubscription? _chatSub;

  bool _hasEnsuredChat = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _chatSub = RadiologyChatService.instance
          .watchChatInfo(widget.bookingId)
          .listen((doc) {
            if (doc.exists) {
              final data = doc.data();
              if (data != null && data['determinedPrice'] != null) {
                _determinedPrice.value = (data['determinedPrice'] as num);
              }
            }
          });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasEnsuredChat) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        RadiologyChatService.instance.ensureConversation(
          user.uid,
          widget.bookingId,
          widget.service.getName(Get.locale?.languageCode ?? 'en'),
          defaultWelcomeMessage: AppLocalizations.of(
            context,
          )?.radiologyChatWelcome,
        );
      }
      _hasEnsuredChat = true;
    }
  }

  @override
  void dispose() {
    _chatSub?.cancel();
    discountController.removeDiscountCode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
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
                    SizedBox(height: 30),
                    _bottomBar(context),
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
                AppLocalizations.of(context)!.confirmation,
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
                AppLocalizations.of(context)!.reviewAppointmentDetails,
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
        case "Service Details":
          return "تفاصيل الخدمة";
        case "Appointment Schedule":
          return "موعد الحجز";
        case "Clinic Location":
          return "موقع العيادة";
        case "Payment Summary":
          return "ملخص الدفع";
        case "Patient Info":
          return "بيانات المريض";
        case "Name":
          return "الاسم";
        case "Phone":
          return "الهاتف";
        case "Not linked":
          return "غير مرتبط";
        case "Guest Patient":
          return "مريض زائر";
      }
    } else if (lang == 'he') {
      switch (text) {
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
        case "Name":
          return "שם";
        case "Phone":
          return "טלפון";
        case "Not linked":
          return "לא מקושר";
        case "Guest Patient":
          return "מטופל אורח";
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
          CircleAvatar(
            radius: 26,
            backgroundImage: widget.service.image.isNotEmpty
                ? CachedNetworkImageProvider(widget.service.image)
                : null,
            child: widget.service.image.isEmpty
                ? Icon(Icons.medical_services, color: Colors.white)
                : null,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.getName('en'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.radiologyDepartment,
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
    final lang = Get.locale?.languageCode ?? 'en';
    final dateKey = DateFormat('d MMM', lang).format(widget.selectedDate);

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
              widget.selectedTime
                  .replaceAll('AM', AppLocalizations.of(context)!.am)
                  .replaceAll('PM', AppLocalizations.of(context)!.pm),
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
              AppLocalizations.of(context)!.o2ClinicMainBranchnfloor1,
              style: TextStyle(color: AppColors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard() {
    return Obx(() {
      final num originalAmount = _determinedPrice.value;

      if (originalAmount < 0) {
        return GestureDetector(
          onTap: () {
            Get.to(
              () => RadiologyChatScreen(
                bookingId: widget.bookingId,
                serviceName: widget.service.getName(
                  Get.locale?.languageCode ?? 'en',
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.support_agent,
                  color: AppColors.primary,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.radiologyPricingInquiryPrompt,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      }

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

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            if (code != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.paymentSummary,
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
                  AppLocalizations.of(context)!.totalPayment,
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
        ),
      );
    });
  }

  Widget _discountSection() {
    final langCode = Get.locale?.languageCode ?? 'ar';
    String askText = 'هل لديك كوبون خصم؟';
    if (langCode == 'en') askText = 'Do you have a discount coupon?';
    if (langCode == 'he') askText = 'יש לך קופון הנחה?';

    return Obx(() {
      if (_determinedPrice.value < 0) return const SizedBox.shrink();

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

      String name = _t("Guest Patient");
      String phone = _t("Not linked");

      if (userData != null) {
        name =
            userData['name'] ??
            userData['first_name'] ??
            currentUser?.displayName ??
            _t("Guest Patient");
        if (userData['phone'] != null && userData['phone'] is Map) {
          phone =
              userData['phone']['full'] ??
              userData['phone']['number'] ??
              _t("Not linked");
        } else if (userData['phoneNumber'] != null) {
          phone = userData['phoneNumber'].toString();
        }
      } else if (currentUser != null) {
        name = currentUser.displayName ?? _t("Guest Patient");
        phone = currentUser.phoneNumber ?? _t("Not linked");
      }

      return _card(
        child: Column(
          children: [
            _infoRow(_t("Name"), name),
            SizedBox(height: 10),
            _infoRow(_t("Phone"), phone),
          ],
        ),
      );
    });
  }

  Widget _bottomBar(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 52,
        child: Obx(
          () => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: (_isBooking || _determinedPrice.value < 0)
                ? null
                : () async {
                    setState(() => _isBooking = true);
                    try {
                      RadiologyAppointmentBookingController controller;
                      if (Get.isRegistered<RadiologyAppointmentBookingController>(tag: widget.controllerTag)) {
                        controller = Get.find<RadiologyAppointmentBookingController>(tag: widget.controllerTag);
                      } else {
                        controller = Get.put(RadiologyAppointmentBookingController(widget.service), tag: widget.controllerTag);
                      }

                      // ✅ لو UI عدّل التاريخ/الوقت (احتياطي)
                      controller.selectedDate.value = widget.selectedDate;
                      controller.selectedTime.value = widget.selectedTime;
                      controller.selectTime(widget.selectedTime);

                      if (widget.selectedTime.trim().isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Time is not available',
                          snackPosition: SnackPosition.TOP,
                        );
                        return;
                      }

                      Map<String, dynamic>? discountData;
                      final code = discountController.currentValidCode.value;
                      final type = discountController.discountTypes
                          .firstWhereOrNull(
                            (t) => t.id == code?.discountTypeId,
                          );
                      num finalAmount = _determinedPrice.value;
                      num discountAmount = 0;

                      if (code != null && type != null) {
                        final num originalPrice = _determinedPrice.value;
                        if (type.calculationMethod == 'percentage') {
                          discountAmount = (originalPrice * (code.value / 100));
                          if (code.maximumDiscountAmount != null &&
                              discountAmount > code.maximumDiscountAmount!) {
                            discountAmount = code.maximumDiscountAmount!;
                          }
                          finalAmount = originalPrice - discountAmount;
                        } else if (type.calculationMethod == 'fixed') {
                          discountAmount = code.value;
                          finalAmount = originalPrice - discountAmount;
                        } else if (type.calculationMethod == 'free') {
                          discountAmount = originalPrice;
                          finalAmount = 0;
                        }
                        if (finalAmount < 0) finalAmount = 0;

                        discountData = {
                          "code_id": code.id,
                          "code": code.code,
                          "type": type.calculationMethod,
                          "discount_value": discountAmount,
                          "original_amount": originalPrice,
                        };
                      }

                      final res = await controller.confirmBooking(
                        finalAmount: finalAmount,
                        discountData: discountData,
                        existingBookingId: widget.bookingId.isNotEmpty ? widget.bookingId : null,
                      );

                      if (!res.success) {
                        debugPrint(
                          "❌ [RadiologyConfirmBookingScreen] Booking unsuccessful: ${res.message}",
                        );

                        String userMessage = res.message;
                        if (userMessage.toLowerCase().contains("failed:") ||
                            userMessage.toLowerCase().contains("error") ||
                            userMessage.toLowerCase().contains("exception")) {
                          userMessage =
                              'Could not complete your booking at this time. Please try again.';
                        }

                        Get.snackbar(
                          'Booking Failed',
                          userMessage,
                          snackPosition: SnackPosition.TOP,
                        );
                        return;
                      }

                      // Reset the price so the next booking asks for the price again!
                      final cUser = FirebaseAuth.instance.currentUser;
                      if (cUser != null) {
                        RadiologyChatService.instance.resetDeterminedPrice(
                          widget.bookingId,
                        );
                      }

                      final bookingId = res.bookingId ?? '';

                      Get.to(
                        () => RadiologyBookingSuccessScreen(
                          service: widget.service,
                          selectedDate: widget.selectedDate,
                          selectedTime: widget.selectedTime,
                          bookingId: bookingId,
                        ),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 350),
                      );
                    } catch (e, st) {
                      debugPrint("❌ [RadiologyConfirmBookingScreen] Error: $e");
                      debugPrint(
                        "❌ [RadiologyConfirmBookingScreen] StackTrace: $st",
                      );
                      Get.snackbar(
                        'Booking Failed',
                        'An unexpected error occurred. Please try again.',
                        snackPosition: SnackPosition.TOP,
                      );
                    } finally {
                      if (mounted) setState(() => _isBooking = false);
                    }
                  },
            child: _isBooking
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).cardColor,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    AppLocalizations.of(context)!.confirm,
                    style: TextStyle(
                      color: Theme.of(context).cardColor,

                      fontWeight: FontWeight.w800,
                    ),
                  ),
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }
}

class _infoRow extends StatelessWidget {
  final String title;
  final String value;

  const _infoRow(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: AppColors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w700,

            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}





