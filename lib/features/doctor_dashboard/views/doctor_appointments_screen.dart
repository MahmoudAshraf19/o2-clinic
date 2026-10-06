import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:o2_clinic/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/doctor_appointments_controller.dart';
import '../widgets/doctor_appointment_card.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  DateTime? _selectedDate;
  late DateTime _displayedMonth;
  late ScrollController _scrollController;
  String _selectedStatus = 'pending';
  final DoctorAppointmentsController _controller = Get.put(
    DoctorAppointmentsController(),
  );
  Worker? _targetDateWorker;
  Worker? _targetStatusWorker;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = null;
    _displayedMonth = DateTime(now.year, now.month, 1);

    double initialOffset = 0.0;
    if (now.year == _displayedMonth.year &&
        now.month == _displayedMonth.month) {
      final index = now.day - 1;
      initialOffset = (index * 60.0) - (Get.width / 2) + 30 + 12;
      if (initialOffset < 0) initialOffset = 0;
    }

    _scrollController = ScrollController(initialScrollOffset: initialOffset);

    _targetDateWorker = ever(_controller.selectedTargetDate, (
      DateTime? newDate,
    ) {
      if (newDate != null && mounted) {
        setState(() {
          _selectedDate = newDate;
          _displayedMonth = DateTime(newDate.year, newDate.month, 1);
        });
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToSelectedDate(),
        );
      }
    });

    _targetStatusWorker = ever(_controller.targetStatus, (String? status) {
      if (status != null && mounted) {
        setState(() {
          _selectedStatus = status;
        });
      }
    });

    if (_controller.targetStatus.value != null) {
      _selectedStatus = _controller.targetStatus.value!;
    }

    // Check immediately if there's already a target date set
    if (_controller.selectedTargetDate.value != null) {
      final newDate = _controller.selectedTargetDate.value!;
      _selectedDate = newDate;
      _displayedMonth = DateTime(newDate.year, newDate.month, 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToSelectedDate();
      });
    }
  }

  void _scrollToSelectedDate() {
    if (_scrollController.hasClients && _selectedDate != null) {
      if (_selectedDate!.year == _displayedMonth.year &&
          _selectedDate!.month == _displayedMonth.month) {
        final index = _selectedDate!.day - 1;

        final screenWidth = MediaQuery.of(context).size.width;
        final double offset = (index * 60.0) - (screenWidth / 2) + 30 + 12;

        final targetOffset = offset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );

        _scrollController.jumpTo(targetOffset);
      }
    }
  }

  @override
  void dispose() {
    _targetDateWorker?.dispose();
    _targetStatusWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
        1,
      );
      if (_selectedDate != null &&
          _selectedDate!.year == _displayedMonth.year &&
          _selectedDate!.month == _displayedMonth.month) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToSelectedDate(),
        );
      } else {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
      if (_selectedDate != null &&
          _selectedDate!.year == _displayedMonth.year &&
          _selectedDate!.month == _displayedMonth.month) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToSelectedDate(),
        );
      } else {
        _scrollController.jumpTo(0);
      }
    });
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    return List.generate(
      daysInMonth,
      (index) => DateTime(month.year, month.month, index + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          AppLocalizations.of(context)!.doctorAppointments,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildCalendarCard(),
            const SizedBox(height: 16),
            _buildStatusFilter(),
            const SizedBox(height: 16),
            Expanded(child: _buildAppointmentsPlaceholder()),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    final days = _getDaysInMonth(_displayedMonth);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.only(top: 16, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat(
                    'MMMM yyyy',
                    Get.locale?.languageCode ?? 'en',
                  ).format(_displayedMonth),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: _previousMonth,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _nextMonth,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Days List
          SizedBox(
            height: 60,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final date = days[index];
                final isSelected =
                    _selectedDate != null &&
                    date.year == _selectedDate!.year &&
                    date.month == _selectedDate!.month &&
                    date.day == _selectedDate!.day;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        // Toggle off
                        _selectedDate = null;
                      } else {
                        _selectedDate = date;
                      }
                    });
                  },
                  child: Container(
                    width: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.E(
                            Get.locale?.languageCode ?? 'en',
                          ).format(date).substring(0, 3),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white70 : AppColors.grey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      {'key': 'pending', 'label': AppLocalizations.of(context)!.pending},
      {'key': 'upcoming', 'label': AppLocalizations.of(context)!.upcoming},
      {'key': 'completed', 'label': AppLocalizations.of(context)!.completed},
      {'key': 'cancelled', 'label': AppLocalizations.of(context)!.cancelled},
      {
        'key': 'under_investigation',
        'label': AppLocalizations.of(context)!.underInvestigation,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: statuses.map((status) {
            final isSelected = _selectedStatus == status['key'];
            return GestureDetector(
              onTap: () {
                setState(() => _selectedStatus = status['key']!);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  status['label']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAppointmentsPlaceholder() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      // Filter bookings
      final filteredBookings = _controller.bookings.where((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Filter by Status
        final statusMap = data['status'] as Map<String, dynamic>? ?? {};
        final currentStatus = statusMap['current'] as String? ?? 'pending';

        if (_selectedStatus == 'upcoming') {
          if (currentStatus != 'upcoming' && currentStatus != 'confirmed')
            return false;
        } else {
          if (currentStatus != _selectedStatus) return false;
        }

        if (_selectedDate != null) {
          final schedule = data['schedule'] as Map<String, dynamic>? ?? {};
          final dateStr = schedule['date'] as String?; // format: "2026-09-09"
          if (dateStr != null && dateStr.isNotEmpty) {
            try {
              DateTime bookingDate;
              try {
                bookingDate = DateTime.parse(dateStr);
              } catch (e) {
                bookingDate = DateFormat('dd MMM yyyy').parse(dateStr);
              }

              if (bookingDate.year != _selectedDate!.year ||
                  bookingDate.month != _selectedDate!.month ||
                  bookingDate.day != _selectedDate!.day) {
                return false;
              }
            } catch (e) {
              return false;
            }
          } else {
            return false; // No date string, hide it
          }
        }

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
                AppLocalizations.of(context)!.noAppointmentsFound,
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
          return DoctorAppointmentCard(
            bookingData: doc.data() as Map<String, dynamic>,
          );
        },
      );
    });
  }
}

