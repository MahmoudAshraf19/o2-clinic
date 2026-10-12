// ignore_for_file: use_build_context_synchronously
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:o2_clinic/common/widgets/common_snackbar.dart';
import '../../../../common/widgets/common_button.dart';
import 'package:get/get.dart';

import 'package:o2_clinic/features/booking/data/models/booking_request_models.dart';
import 'package:o2_clinic/features/booking/data/services/fs_bookings_firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../common/controllers/global_auth_controller.dart';
import '../../../../common/models/fs_doctor_model.dart';
import '../controllers/clinical_booking_controller.dart';
import '../../../../common/controllers/app_constants_controller.dart';
import '../../../discounts/presentation/controllers/discount_controller.dart';
import '../../../discounts/presentation/widgets/discount_input_widget.dart';
import 'booking_success_screen.dart';

class ConfirmBookingScreen extends StatefulWidget {
  final DoctorModel doctor;
  final DateTime selectedDate;
  final String selectedTime;
  final String controllerTag;
  final bool isOnline;

  const ConfirmBookingScreen({
    super.key,
    required this.doctor,
    required this.selectedDate,
    required this.selectedTime,
    required this.controllerTag,
    this.isOnline = false,
  });

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  bool _isBooking = false;
  final DiscountController discountController = Get.put(DiscountController());

  @override
  void dispose() {
    // Reset discount when leaving
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(AppLocalizations.of(context)!.doctorDetails),
                    SizedBox(height: 10),
                    _doctorCard(),
                    SizedBox(height: 18),
                    _sectionTitle(
                      AppLocalizations.of(context)!.appointmentSchedule,
                    ),
                    SizedBox(height: 10),
                    _scheduleCard(),
                    SizedBox(height: 18),
                    _sectionTitle(AppLocalizations.of(context)!.clinicLocation),
                    SizedBox(height: 10),
                    _locationCard(),
                    SizedBox(height: 18),
                    _sectionTitle(AppLocalizations.of(context)!.paymentSummary),
                    SizedBox(height: 10),
                    _paymentCard(),
                    SizedBox(height: 12),
                    _discountSection(),
                    SizedBox(height: 18),
                    _sectionTitle(AppLocalizations.of(context)!.patientInfo),
                    SizedBox(height: 10),
                    _patientCard(),
                    SizedBox(height: 24),
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
                  color: Theme.of(context).textTheme.bodyMedium?.color
                      ?.withValues(alpha: 0.7)
                      .withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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

  Widget _doctorCard() {
    final lang = Get.locale?.languageCode ?? 'en';
    String doctorName = widget.doctor.nameEn;
    if (lang == 'ar' && widget.doctor.nameAr.isNotEmpty) {
      doctorName = widget.doctor.nameAr;
    }
    if (lang == 'he' && widget.doctor.nameHe.isNotEmpty) {
      doctorName = widget.doctor.nameHe;
    }

    String doctorTitle = widget.doctor.titleEn;
    if (lang == 'ar' && widget.doctor.titleAr.isNotEmpty) {
      doctorTitle = widget.doctor.titleAr;
    }
    if (lang == 'he' && widget.doctor.titleHe.isNotEmpty) {
      doctorTitle = widget.doctor.titleHe;
    }

    return _card(
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: widget.doctor.image.isNotEmpty
                ? CachedNetworkImageProvider(widget.doctor.image)
                : null,
            child: widget.doctor.image.isEmpty
                ? Icon(Icons.person, color: AppColors.white)
                : null,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  doctorTitle,
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
    final formattedDate = DateFormat(
      'd MMM yyyy',
      lang,
    ).format(widget.selectedDate);

    String translatedTime = widget.selectedTime;
    if (lang == 'ar') {
      translatedTime = translatedTime
          .replaceAll('AM', 'ص')
          .replaceAll('PM', 'م');
    } else if (lang == 'he') {
      translatedTime = translatedTime
          .replaceAll('AM', 'לפנה״צ')
          .replaceAll('PM', 'אחה״צ');
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                formattedDate,
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
              translatedTime,
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
              widget.isOnline
                  ? (AppLocalizations.of(context)!.onlineConsultation)
                  : AppLocalizations.of(context)!.o2ClinicMainBranchnfloor4,
              style: TextStyle(color: AppColors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard() {
    final originalAmount = widget.isOnline
        ? widget.doctor.priceForOnline
        : widget.doctor.price;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Obx(() {
        final currency =
            Get.find<AppConstantsController>().currencySymbol.value;
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
                    AppLocalizations.of(
                      context,
                    )!.paymentSummary, // Or original price text
                    style: TextStyle(
                      fontWeight: FontWeight.w600,

                      color: Theme.of(context).textTheme.bodyLarge?.color,
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
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    code.localizedTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,

                      color: AppColors.green,
                    ),
                  ),
                  Text(
                    "-$discountAmount $currency",
                    style: TextStyle(fontSize: 14, color: AppColors.green),
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
                  "$finalAmount $currency",
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
                Icon(Icons.check_circle, color: AppColors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  discountController.currentValidCode.value!.code,
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            CommonButton(
              onPressed: () => discountController.removeDiscountCode(),
              text: '',
              type: CommonButtonType.text,
              icon: Icons.close,
              foregroundColor: AppColors.red,
            ),
          ],
        );
      }
      return GestureDetector(
        onTap: () => DiscountInputWidget.show(
          context,
          doctorId: widget.doctor.id,
        ),
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
      final globalAuth = Get.find<GlobalAuthController>();
      final userData = globalAuth.currentUserData.value;
      final currentUser = FirebaseAuth.instance.currentUser;

      String name = AppLocalizations.of(context)!.guestPatient;
      String phone = AppLocalizations.of(context)!.notLinked;

      if (userData != null) {
        name =
            userData['name'] ??
            userData['first_name'] ??
            currentUser?.displayName ??
            AppLocalizations.of(context)!.guestPatient;
        if (userData['phone'] != null && userData['phone'] is Map) {
          phone =
              userData['phone']['full'] ??
              userData['phone']['number'] ??
              AppLocalizations.of(context)!.notLinked;
        } else if (userData['phoneNumber'] != null) {
          phone = userData['phoneNumber'].toString();
        }
      } else if (currentUser != null) {
        name =
            currentUser.displayName ??
            AppLocalizations.of(context)!.guestPatient;
        phone =
            currentUser.phoneNumber ?? AppLocalizations.of(context)!.notLinked;
      }

      return _card(
        child: Column(
          children: [
            _InfoRow(AppLocalizations.of(context)!.name, name),
            SizedBox(height: 10),
            _InfoRow(AppLocalizations.of(context)!.phone, phone),
          ],
        ),
      );
    });
  }

  Widget _bottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SafeArea(
        child: SizedBox(
          height: 52,
          child: CommonButton(
            type: CommonButtonType.primary,
            backgroundColor: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            isLoading: _isBooking,
            onPressed: () async {
                    setState(() => _isBooking = true);
                    try {
                      final controller = Get.find<AppointmentBookingController>(
                        tag: widget.controllerTag,
                      );

                      // ✅ لو UI عدّل التاريخ/الوقت (احتياطي)
                      controller.selectedDate.value = widget.selectedDate;
                      controller.selectedTime.value = widget.selectedTime;

                      // ✅ لازم الوقت يبقى موجود
                      if (widget.selectedTime.trim().isEmpty) {
                        CommonSnackbar.showError(title: AppLocalizations.of(context)!.error, message: AppLocalizations.of(context)!.timeIsNotAvailable);
                        return;
                      }

                      // ✅ User info
                      final globalAuth = Get.find<GlobalAuthController>();
                      final userData = globalAuth.currentUserData.value;
                      final currentUser = FirebaseAuth.instance.currentUser;

                      String name = AppLocalizations.of(context)!.guestPatient;
                      String countryCode = "";
                      String number = AppLocalizations.of(context)!.notLinked;

                      if (userData != null) {
                        name =
                            userData['name'] ??
                            userData['first_name'] ??
                            currentUser?.displayName ??
                            AppLocalizations.of(context)!.guestPatient;
                        if (userData['phone'] != null &&
                            userData['phone'] is Map) {
                          countryCode =
                              userData['phone']['countryCode']?.toString() ??
                              "";
                          number =
                              userData['phone']['number']?.toString() ??
                              AppLocalizations.of(context)!.notLinked;
                        } else if (userData['phoneNumber'] != null) {
                          number = userData['phoneNumber'].toString();
                        }
                      } else if (currentUser != null) {
                        name =
                            currentUser.displayName ??
                            AppLocalizations.of(context)!.guestPatient;
                        number =
                            currentUser.phoneNumber ??
                            AppLocalizations.of(context)!.notLinked;
                      }

                      final user = BookingUserInfo(
                        userId: currentUser?.uid ?? 'guest',
                        name: name,
                        countryCode: countryCode,
                        number: number,
                      );

                      // Calculate discount data to save
                      Map<String, dynamic>? discountData;
                      final code = discountController.currentValidCode.value;
                      final type = discountController.discountTypes
                          .firstWhereOrNull(
                            (t) => t.id == code?.discountTypeId,
                          );
                      final originalPrice = widget.isOnline
                          ? widget.doctor.priceForOnline
                          : widget.doctor.price;
                      num finalAmount = originalPrice;
                      num discountAmount = 0;

                      if (code != null && type != null) {
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
                          if (code.doctorId != null) "doctor_id": code.doctorId,
                          if (code.doctorName != null) "doctor_name": code.doctorName,
                        };
                      }

                      // ✅ Firestore Transaction booking
                      final res = await controller.confirmBooking(
                        user: user,
                        durationMinutes: 30,
                        clinicName: "O2 Clinic - Main Branch",
                        floor: "4",
                        room: "",
                        paymentStatus: "pending",
                        paymentMethod: "cash",
                        currency: Get.find<AppConstantsController>()
                            .currencyName
                            .value,
                        amountOverride: finalAmount,
                        appVersion: "8.8",
                        discountData: discountData,
                        isOnline: widget.isOnline,
                      );

                      if (!res.success) {
                        debugPrint(
                          "❌ [ConfirmBookingScreen] Booking unsuccessful: ${res.message}",
                        );

                        String userMessage = res.message;
                        if (userMessage.toLowerCase().contains("failed:") ||
                            userMessage.toLowerCase().contains("error") ||
                            userMessage.toLowerCase().contains("exception")) {
                          userMessage = AppLocalizations.of(
                            context,
                          )!.couldNotCompleteYourBooking;
                        }

                        CommonSnackbar.showError(title: AppLocalizations.of(context)!.bookingFailed, message: userMessage);
                        return;
                      }

                      final bookingId = res.bookingId ?? '';

                      if (widget.isOnline) {
                        // Send notifications for online booking
                        try {
                          await FirebaseFirestore.instance
                              .collection('notifications')
                              .add({
                                'userId': currentUser?.uid ?? 'guest',
                                'title': 'Online Booking Request',
                                'body':
                                    'Your online consultation request has been sent to the doctor and is pending confirmation.',
                                'createdAt': FieldValue.serverTimestamp(),
                                'type': 'booking',
                                'data': {'bookingId': bookingId},
                              });

                          final doctorDoc = await FirebaseFirestore.instance
                              .collection('Doctors')
                              .doc(widget.doctor.id)
                              .get();
                          final doctorAuthUid =
                              doctorDoc.data()?['auth_uid'] as String?;

                          if (doctorAuthUid != null &&
                              doctorAuthUid.isNotEmpty) {
                            await FirebaseFirestore.instance
                                .collection('notifications')
                                .add({
                                  'userId': doctorAuthUid,
                                  'title': 'New Online Booking Request',
                                  'body':
                                      'You have a new online consultation request from ${user.name} at ${widget.selectedTime} on ${BookingsFirestoreService.formatDate(widget.selectedDate)}.',
                                  'createdAt': FieldValue.serverTimestamp(),
                                  'type': 'booking',
                                  'data': {'bookingId': bookingId},
                                });
                          }
                        } catch (e) {
                          debugPrint('Error sending notifications: $e');
                        }
                      }

                      Get.to(
                        () => BookingSuccessScreen(
                          doctor: widget.doctor,
                          selectedDate: widget.selectedDate,
                          selectedTime: widget.selectedTime,
                          bookingId: bookingId,
                          isOnline: widget.isOnline,
                        ),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 350),
                      );
                    } catch (e, st) {
                      debugPrint("❌ [ConfirmBookingScreen] Error: $e");
                      debugPrint("❌ [ConfirmBookingScreen] StackTrace: $st");
                      CommonSnackbar.showError(title: AppLocalizations.of(context)!.bookingFailed, message: AppLocalizations.of(context)!.anUnexpectedErrorOccurred);
                    } finally {
                      if (mounted) setState(() => _isBooking = false);
                    }
                  },
            text: AppLocalizations.of(context)!.confirm,
            textStyle: TextStyle(
              color: Theme.of(context).cardColor,
              fontWeight: FontWeight.w800,
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

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow(this.title, this.value);

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
