import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/doctor_statistics_controller.dart';

class DoctorStatisticsScreen extends StatefulWidget {
  const DoctorStatisticsScreen({super.key});

  @override
  State<DoctorStatisticsScreen> createState() => _DoctorStatisticsScreenState();
}

class _DoctorStatisticsScreenState extends State<DoctorStatisticsScreen> {
  final DoctorStatisticsController _controller = Get.put(
    DoctorStatisticsController(),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.statistics,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: AppColors.transparent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildFilterDropdown(l10n),
                  const SizedBox(height: 24),
                  _buildMainMetrics(l10n),
                  const SizedBox(height: 24),
                  _buildBreakdownCards(l10n),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
      ),
      child: Obx(() {
        return DropdownButtonHideUnderline(
          child: DropdownButton<StatFilter>(
            value: _controller.selectedFilter.value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary,
            ),
            items: [
              DropdownMenuItem(
                value: StatFilter.allTime,
                child: Text(
                  l10n.allTime,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: StatFilter.thisYear,
                child: Text(
                  l10n.thisYear,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: StatFilter.thisMonth,
                child: Text(
                  l10n.thisMonth,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: StatFilter.thisWeek,
                child: Text(
                  l10n.thisWeek,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: StatFilter.today,
                child: Text(
                  l10n.today,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: StatFilter.customDay,
                child: Text(
                  l10n.customDay,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              DropdownMenuItem(
                value: StatFilter.customRange,
                child: Text(
                  l10n.customRange,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
            onChanged: (val) async {
              if (val == null) return;
              if (val == StatFilter.customDay) {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.primary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  _controller.customSelectedDate.value = date;
                  _controller.setFilter(val);
                }
              } else if (val == StatFilter.customRange) {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.primary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (range != null) {
                  _controller.customSelectedDateRange.value = range;
                  _controller.setFilter(val);
                }
              } else {
                _controller.setFilter(val);
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildMainMetrics(AppLocalizations l10n) {
    return Column(
      children: [
        // Earnings Card
        Obx(() {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalEarnings,
                        style: const TextStyle(
                          color: AppColors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_controller.totalEarnings.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        // Appointments and Patients row
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildStatCard(
                  title: l10n.totalAppointments,
                  value: _controller.totalAppointments.value.toString(),
                  icon: Icons.calendar_month_rounded,
                  color: AppColors.orange,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => _buildStatCard(
                  title: l10n.uniquePatients,
                  value: _controller.uniquePatients.value.toString(),
                  icon: Icons.people_alt_rounded,
                  color: AppColors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(
          () => _buildStatCard(
            title: l10n.averageEarnings,
            value: '\$${_controller.averageEarnings.value.toStringAsFixed(2)}',
            icon: Icons.analytics_rounded,
            color: AppColors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCards(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.statusBreakdown,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.1)),
          ),
          child: Obx(() {
            final total = _controller.totalAppointments.value;
            final completed = _controller.completedCount.value;
            final pending = _controller.pendingCount.value;
            final cancelled = _controller.cancelledCount.value;
            return Column(
              children: [
                _buildProgressBar(
                  'Completed',
                  completed,
                  total,
                  AppColors.green,
                ),
                const SizedBox(height: 12),
                _buildProgressBar('Pending', pending, total, AppColors.orange),
                const SizedBox(height: 12),
                _buildProgressBar('Cancelled', cancelled, total, AppColors.red),
              ],
            );
          }),
        ),

        const SizedBox(height: 24),
        Text(
          l10n.topServices,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.grey.withValues(alpha: 0.1)),
          ),
          child: Obx(() {
            final services = _controller.topServices;
            if (services.isEmpty) {
              return const Center(
                child: Text('-', style: TextStyle(color: AppColors.grey)),
              );
            }

            // Sort services by count descending
            final sortedKeys = services.keys.toList()
              ..sort((a, b) => services[b]!.compareTo(services[a]!));
            final totalAppts = _controller.totalAppointments.value;

            return Column(
              children: sortedKeys.map((key) {
                final count = services[key]!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildProgressBar(
                    key,
                    count,
                    totalAppts,
                    AppColors.primary,
                  ),
                );
              }).toList(),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProgressBar(String label, int value, int total, Color color) {
    final double percent = total == 0 ? 0 : value / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$value (${(percent * 100).toStringAsFixed(0)}%)',
              style: const TextStyle(fontSize: 13, color: AppColors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: color.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
      ],
    );
  }
}
