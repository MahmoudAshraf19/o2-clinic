import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../presentation/controllers/patient_bookings_controller.dart';
import '../../presentation/widgets/patient_appointment_card.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';

class PatientBookingsScreen extends StatefulWidget {
  const PatientBookingsScreen({super.key});

  @override
  State<PatientBookingsScreen> createState() => _PatientBookingsScreenState();
}

class _PatientBookingsScreenState extends State<PatientBookingsScreen> {
  final PatientBookingsController _controller = Get.put(
    PatientBookingsController(),
  );

  String _selectedType = 'online'; // 'online' or 'clinical'
  String _selectedStatus =
      'pending'; // 'pending', 'upcoming', 'completed', 'cancelled'

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: AppColors.transparent,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr ? 'حجوزاتي' : 'My Bookings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.colorFF60A5FA
                    : AppColors.primary,
                fontFamily: AppFonts.dancingScript,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isAr ? 'إدارة حجوزاتك بسهولة' : 'Manage your bookings easily',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.grey400
                    : AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Type Tabs (Online vs Clinical)
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildTypeTab(
                    title: isAr ? 'أونلاين' : 'Online',
                    value: 'online',
                    icon: Icons.videocam_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTypeTab(
                    title: isAr ? 'في المركز' : 'In Clinic',
                    value: 'clinical',
                    icon: Icons.medical_services_outlined,
                  ),
                ),
              ],
            ),
          ),

          // 2. Status Tabs (only show Pending for Online if requested, but better to show all)
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (_selectedType == 'online')
                  _buildStatusTab(isAr ? 'قيد الانتظار' : 'Pending', 'pending'),
                _buildStatusTab(isAr ? 'القادمة' : 'Upcoming', 'upcoming'),
                _buildStatusTab(isAr ? 'مكتملة' : 'Completed', 'completed'),
                _buildStatusTab(isAr ? 'ملغية' : 'Cancelled', 'cancelled'),
              ],
            ),
          ),

          // 3. List
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: CommonLoadingIndicator());
              }

              final filteredBookings = _controller.bookings.where((doc) {
                final data = doc.data() as Map<String, dynamic>;

                final type = data['type'] as String? ?? 'clinical';
                if (type != _selectedType) return false;

                final statusMap = data['status'] as Map<String, dynamic>? ?? {};
                final currentStatus =
                    statusMap['current'] as String? ?? 'pending';

                // upcoming/confirmed mapping
                String normalizedStatus = currentStatus == 'confirmed'
                    ? 'upcoming'
                    : currentStatus;

                if (normalizedStatus != _selectedStatus) return false;

                return true;
              }).toList();

              if (filteredBookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 64,
                        color: AppColors.grey.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isAr ? 'لا توجد حجوزات' : 'No bookings found',
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredBookings.length,
                padding: const EdgeInsets.only(bottom: 24),
                itemBuilder: (context, index) {
                  final doc = filteredBookings[index];
                  return PatientAppointmentCard(
                    bookingData: doc.data() as Map<String, dynamic>,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
          if (value == 'clinical' && _selectedStatus == 'pending') {
            _selectedStatus =
                'upcoming'; // Clinical doesn't usually have pending
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.white : AppColors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab(String label, String value) {
    final isSelected = _selectedStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedStatus = value);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.grey.withValues(alpha: 0.2),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
