import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../chat_doctors/models/doctor_chat_model.dart';
import '../../chat_doctors/views/doctor_active_chat_screen.dart';
import '../../../core/services/notification_service.dart';

class DoctorBookingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const DoctorBookingDetailsScreen({super.key, required this.bookingData});

  @override
  State<DoctorBookingDetailsScreen> createState() => _DoctorBookingDetailsScreenState();
}

class _DoctorBookingDetailsScreenState extends State<DoctorBookingDetailsScreen> {
  bool _isLoading = false;
  String? _patientImageUrl;
  String _patientGender = '';
  String _patientAge = '';

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    final userId = (widget.bookingData['user'] as Map<String, dynamic>?)?['userId'] as String? ?? '';
    if (userId.isEmpty) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        if (mounted) {
          setState(() {
            _patientImageUrl = doc.data()!['image'] as String?;
            _patientGender = doc.data()!['gender'] as String? ?? '';
            _patientAge = doc.data()!['age']?.toString() ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching patient data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    
    // User Data
    final bookingId = widget.bookingData['id'] as String? ?? '';
    final userMap = widget.bookingData['user'] as Map<String, dynamic>? ?? {};
    final userId = userMap['userId'] as String? ?? '';
    final name = userMap['name'] as String? ?? 'Patient';
    final phoneMap = userMap['phone'] as Map<String, dynamic>? ?? {};
    final phoneFull = phoneMap['full'] as String? ?? '';

    // Schedule Data
    final schedule = widget.bookingData['schedule'] as Map<String, dynamic>? ?? {};
    final timeStr = schedule['time'] as String? ?? '';
    final dateStr = schedule['date'] as String? ?? '';
    final duration = schedule['duration_minutes'] as int? ?? 30;

    // Timeline Data
    final timeline = widget.bookingData['timeline'] as Map<String, dynamic>? ?? {};
    final createdAtTs = timeline['createdAt'] as Timestamp?;
    String createdAtStr = '';
    if (createdAtTs != null) {
      createdAtStr = DateFormat('dd MMM yyyy, hh:mm a', isAr ? 'ar' : 'en').format(createdAtTs.toDate());
    }

    // Status Data
    final statusMap = widget.bookingData['status'] as Map<String, dynamic>? ?? {};
    final currentStatus = statusMap['current'] as String? ?? 'pending';
    
    // Type and Service
    final type = widget.bookingData['type'] as String? ?? 'clinical';
    final isOnline = type == 'online';
    final service = widget.bookingData['service'] as Map<String, dynamic>? ?? {};
    final doctorMap = widget.bookingData['doctor'] as Map<String, dynamic>? ?? {};
    final serviceNameEn = service['serviceName_en'] as String? ?? doctorMap['specialty'] as String? ?? '';
    final serviceNameAr = service['serviceName_ar'] as String? ?? doctorMap['specialty'] as String? ?? '';
    final serviceName = isAr ? serviceNameAr : serviceNameEn;

    // Payment Data
    final payment = widget.bookingData['payment'] as Map<String, dynamic>? ?? {};
    final amount = payment['amount']?.toString() ?? '0';
    final currency = payment['currency'] as String? ?? '';
    final payMethod = payment['method'] as String? ?? '';

    // Format display date
    String displayDate = '';
    if (dateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dateStr);
        displayDate = DateFormat('dd MMM yyyy', isAr ? 'ar' : 'en').format(dt);
      } catch (e) {
        displayDate = dateStr;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isAr ? 'تفاصيل الحجز' : 'Booking Details', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120), // padding for bottom bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopProfileSection(name, phoneFull, isAr, currentStatus, userId, doctorMap),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'معلومات الموعد' : 'Appointment Info',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard([
                        if (bookingId.isNotEmpty)
                          _InfoItem(icon: Icons.tag_rounded, title: isAr ? 'رقم الحجز' : 'Booking ID', value: bookingId),
                        _InfoItem(icon: Icons.calendar_today_rounded, title: isAr ? 'تاريخ الموعد' : 'Date', value: displayDate),
                        _InfoItem(icon: Icons.access_time_rounded, title: isAr ? 'الوقت' : 'Time', value: timeStr),
                        _InfoItem(icon: Icons.hourglass_bottom_rounded, title: isAr ? 'المدة' : 'Duration', value: '$duration ${isAr ? 'دقيقة' : 'min'}'),
                        _InfoItem(icon: Icons.history_rounded, title: isAr ? 'تاريخ الحجز' : 'Booked On', value: createdAtStr.isNotEmpty ? createdAtStr : 'N/A'),
                      ]),

                      const SizedBox(height: 24),
                      Text(
                        isAr ? 'تفاصيل الخدمة' : 'Service Details',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard([
                        _InfoItem(icon: isOnline ? Icons.videocam_rounded : Icons.business_rounded, title: isAr ? 'نوع الحجز' : 'Type', value: isOnline ? (isAr ? 'استشارة أونلاين' : 'Online Consultation') : (isAr ? 'حضور شخصي' : 'In Clinic')),
                        _InfoItem(icon: Icons.medical_services_rounded, title: isAr ? 'الخدمة' : 'Service', value: serviceName),
                        _InfoItem(icon: Icons.payment_rounded, title: isAr ? 'الدفع' : 'Payment', value: '$amount $currency (${payMethod.toUpperCase()})'),
                        _InfoItem(
                          icon: Icons.info_rounded, 
                          title: isAr ? 'حالة الحجز' : 'Status', 
                          value: _getStatusLabel(currentStatus, isAr), 
                          valueColor: _getStatusColor(currentStatus)
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          if (currentStatus == 'pending')
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.grey.withValues(alpha: 0.1))),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: _CustomButton(
                          title: isAr ? 'رفض' : 'Reject',
                          textColor: Colors.red[700]!,
                          bgColor: Colors.red.withValues(alpha: 0.1),
                          onTap: () => _handleStatusChange('cancelled', isAr),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _CustomButton(
                          title: isAr ? 'تأكيد الحجز' : 'Accept Booking',
                          textColor: Colors.white,
                          bgColor: AppColors.primary,
                          onTap: () => _handleStatusChange('upcoming', isAr),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.2),
              child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildTopProfileSection(String name, String phone, bool isAr, String status, String patientId, Map<String, dynamic> doctorMap) {
    String subtitle = '';
    if (_patientAge.isNotEmpty) subtitle += '$_patientAge ${isAr ? 'سنة' : 'yrs'}';
    if (_patientAge.isNotEmpty && _patientGender.isNotEmpty) subtitle += ' • ';
    if (_patientGender.isNotEmpty) subtitle += _patientGender;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.grey.withValues(alpha: 0.1),
            backgroundImage: (_patientImageUrl != null && _patientImageUrl!.isNotEmpty) ? NetworkImage(_patientImageUrl!) : null,
            child: (_patientImageUrl == null || _patientImageUrl!.isEmpty)
                ? const Icon(Icons.person, color: AppColors.grey, size: 30)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: AppColors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone_rounded, size: 14, color: AppColors.grey),
                    const SizedBox(width: 6),
                    Text(phone, style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5)),
                  ],
                ),
              ],
            ),
          ),
          if (status != 'cancelled')
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.primary),
                onPressed: () => _startConsultation(patientId, name, doctorMap),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<_InfoItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.1)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => Divider(color: AppColors.grey.withValues(alpha: 0.1), height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 14, color: AppColors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold, 
                      color: item.valueColor ?? AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }



  void _startConsultation(String patientId, String patientName, Map<String, dynamic> doctorMap) {
    final doctorId = doctorMap['doctorId'] as String? ?? '';
    final doctorNameEn = doctorMap['name_en'] as String? ?? '';
    final doctorImage = doctorMap['image'] as String? ?? '';
    
    final ids = [patientId, doctorId];
    ids.sort();
    final roomId = ids.join('_');

    final room = DoctorChatRoom(
      id: roomId,
      customerId: patientId,
      customerName: patientName,
      customerProfileImage: _patientImageUrl ?? '',
      doctorId: doctorId,
      doctorName: doctorNameEn,
      doctorProfileImage: doctorImage,
      lastMessage: '',
      lastMessageKind: '',
      lastSenderId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Get.to(() => DoctorActiveChatScreen(room: room));
  }

  Future<void> _handleStatusChange(String newStatus, bool isAr) async {
    final title = isAr ? 'تأكيد الإجراء' : 'Confirm Action';
    final content = isAr 
        ? 'هل أنت متأكد من ${newStatus == 'upcoming' ? 'قبول' : 'رفض'} هذا الموعد؟ لا يمكن التراجع عن هذا الإجراء لاحقاً.' 
        : 'Are you sure you want to ${newStatus == 'upcoming' ? 'accept' : 'reject'} this appointment? This action cannot be undone.';
        
    final confirmBtn = isAr ? 'نعم، أؤكد' : 'Yes, Confirm';
    final cancelBtn = isAr ? 'تراجع' : 'Cancel';

    final bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content, style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelBtn, style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'upcoming' ? AppColors.primary : Colors.red,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(confirmBtn, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final bookingId = widget.bookingData['id'] as String;
      final userId = (widget.bookingData['user'] as Map<String, dynamic>)['userId'] as String;
      
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
        'status.current': newStatus,
        'status.label': newStatus == 'upcoming' ? 'Confirmed' : 'Cancelled',
        'timeline.${newStatus == 'upcoming' ? 'confirmedAt' : 'cancelledAt'}': FieldValue.serverTimestamp(),
      });

      final notifTitle = {
        'ar': 'تحديث حالة الحجز',
        'en': 'Booking Update',
      };
      
      final notifBody = {
        'ar': newStatus == 'upcoming' ? 'تم تأكيد حجزك من قبل الطبيب.' : 'نعتذر، تم إلغاء حجزك من قبل الطبيب.',
        'en': newStatus == 'upcoming' ? 'Your booking has been confirmed by the doctor.' : 'We apologize, your booking was cancelled by the doctor.',
      };

      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'title': notifTitle,
        'body': notifBody,
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'booking',
        'status': {'read': false},
        'priority': 'normal',
        'data': {'bookingId': bookingId},
      });

      // Schedule Doctor Reminder for Online Consultations
      final type = widget.bookingData['type'] as String? ?? 'clinical';
      if (newStatus == 'confirmed' && type == 'online') {
        final scheduleMap = widget.bookingData['schedule'] as Map<String, dynamic>? ?? {};
        final ts = scheduleMap['timestamp'] as Timestamp?;
        if (ts != null) {
          final appointmentDate = ts.toDate();
          final langCode = Get.locale?.languageCode ?? 'en';
          await NotificationService.instance.scheduleDoctorOnlineReminder(
            bookingId: bookingId,
            appointmentDate: appointmentDate,
            langCode: langCode,
          );
        }
      }

      Get.back(); // Go back to list
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getStatusLabel(String status, bool isAr) {
    switch (status) {
      case 'upcoming':
      case 'confirmed': return isAr ? 'مؤكد' : 'CONFIRMED';
      case 'pending': return isAr ? 'قيد الانتظار' : 'PENDING';
      case 'cancelled': return isAr ? 'ملغي' : 'CANCELLED';
      case 'completed': return isAr ? 'مكتمل' : 'COMPLETED';
      default: return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
      case 'confirmed': return Colors.green[700]!;
      case 'pending': return Colors.orange[800]!;
      case 'cancelled': return Colors.red[700]!;
      case 'completed': return AppColors.primary;
      default: return AppColors.grey;
    }
  }
}

class _InfoItem {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  _InfoItem({required this.icon, required this.title, required this.value, this.valueColor});
}

class _CustomButton extends StatelessWidget {
  final String title;
  final Color textColor;
  final Color bgColor;
  final VoidCallback onTap;
  final IconData? icon;

  const _CustomButton({
    required this.title,
    required this.textColor,
    required this.bgColor,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
