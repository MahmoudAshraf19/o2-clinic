import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/doctor_edit_profile_controller.dart';
import '../controllers/doctor_profile_controller.dart';

class DoctorEditProfileScreen extends StatelessWidget {
  const DoctorEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorEditProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.editProfile,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF13364A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF13364A),
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ElevatedButton(
              onPressed: controller.saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.save,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Profile Image'),
              const SizedBox(height: 12),
              _buildImagePicker(controller),
              const SizedBox(height: 24),

              _buildSectionTitle('Doctor Name'),
              const SizedBox(height: 12),
              _buildLanguageSummaryField(
                context: context,
                title: 'Doctor Name',
                controller: controller,
                arController: controller.nameArController,
                enController: controller.nameEnController,
                heController: controller.nameHeController,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Professional Title'),
              const SizedBox(height: 12),
              _buildLanguageSummaryField(
                context: context,
                title: 'Professional Title',
                controller: controller,
                arController: controller.titleArController,
                enController: controller.titleEnController,
                heController: controller.titleHeController,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Specialty'),
              const SizedBox(height: 12),
              _buildLockedField(
                context: context,
                controller: controller,
                icon: Icons.medical_services_outlined,
                value: controller.specialty,
                isDropdown: true,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('About / Description'),
              const SizedBox(height: 12),
              _buildLanguageSummaryField(
                context: context,
                title: 'About / Description',
                controller: controller,
                arController: controller.descArController,
                enController: controller.descEnController,
                heController: controller.descHeController,
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Email'),
              const SizedBox(height: 12),
              _buildLockedField(
                context: context,
                controller: controller,
                icon: Icons.email_outlined,
                value: controller.emailController.text,
              ),
              const SizedBox(height: 24),

              // Online Consultation Toggle
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.videocam_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Online Consultation',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.isOnlineAvailable.value
                                  ? 'Online Consultation Available'
                                  : 'Online Consultation Unavailable',
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: controller.isOnlineAvailable.value,
                        onChanged: controller.toggleOnline,
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.primary,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFFD1D5DB),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Obx(() {
                if (!controller.isOnlineAvailable.value)
                  return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Online Consultation Price'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: controller.onlinePriceController,
                      icon: Icons.monetization_on_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),

                    // Online Consultation Schedule
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Online Consultation Schedule'),
                        InkWell(
                          onTap: () =>
                              _showAddOnlineScheduleDialog(context, controller),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Add',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (controller.onlineSchedule.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const Center(
                            child: Text(
                              'No online schedule added',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: controller.onlineSchedule.entries.expand((
                          entry,
                        ) {
                          final day = entry.key;
                          final schedules = entry.value;
                          List<Widget> rows = [];
                          for (int i = 0; i < schedules.length; i++) {
                            rows.add(
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            day.capitalizeFirst ?? day,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Color(0xFF13364A),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${schedules[i]['from']}:00 - ${schedules[i]['to']}:00',
                                            style: const TextStyle(
                                              color: Color(0xFF6B7280),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => controller
                                          .removeOnlineScheduleSlot(day, i),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return rows;
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                );
              }),

              const Divider(color: Color(0xFFF3F4F6), thickness: 1),
              const SizedBox(height: 24),

              // Locked Fields
              _buildLockedRow(
                context: context,
                controller: controller,
                icon: Icons.calendar_today_outlined,
                title: 'Regular Availability',
                subtitle: 'Friday • 9:00 AM - 9:00 PM',
              ),
              const SizedBox(height: 20),

              _buildLockedRow(
                context: context,
                controller: controller,
                icon: Icons.business_center_outlined,
                title: 'Years of Experience',
                subtitle: '${controller.yearsExperience} years',
              ),
              const SizedBox(height: 20),

              _buildLockedRow(
                context: context,
                controller: controller,
                icon: Icons.star_border_rounded,
                title: 'Rating',
                subtitle: '(4.8)',
              ),
              const SizedBox(height: 20),

              _buildLockedRow(
                context: context,
                controller: controller,
                icon: Icons.monetization_on_outlined,
                title: 'Regular Consultation Price',
                subtitle: '${controller.regularPrice} EGP',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF13364A),
      ),
    );
  }

  Widget _buildImagePicker(DoctorEditProfileController controller) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Obx(
              () => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF3F4F6),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: controller.selectedImage.value != null
                      ? (kIsWeb
                            ? Image.network(
                                controller.selectedImage.value!.path,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(controller.selectedImage.value!.path),
                                fit: BoxFit.cover,
                              ))
                      : (controller.existingImageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: controller.existingImageUrl,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.person,
                                size: 40,
                                color: AppColors.grey,
                              )),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        InkWell(
          onTap: controller.pickImage,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Change Photo',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSummaryField({
    required BuildContext context,
    required String title,
    required DoctorEditProfileController controller,
    required TextEditingController arController,
    required TextEditingController enController,
    required TextEditingController heController,
    int maxLines = 1,
  }) {
    return InkWell(
      onTap: () => _showLanguageBottomSheet(
        context: context,
        title: title,
        controller: controller,
        arController: arController,
        enController: enController,
        heController: heController,
        maxLines: maxLines,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const Icon(
              Icons.language_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  arController,
                  enController,
                  heController,
                ]),
                builder: (context, _) {
                  final langCode = Localizations.localeOf(context).languageCode;
                  String text = '';

                  if (langCode == 'ar' && arController.text.isNotEmpty) {
                    text = arController.text;
                  } else if (langCode == 'he' && heController.text.isNotEmpty) {
                    text = heController.text;
                  } else if (langCode == 'en' && enController.text.isNotEmpty) {
                    text = enController.text;
                  } else if (enController.text.isNotEmpty) {
                    text = enController.text;
                  } else if (arController.text.isNotEmpty) {
                    text = arController.text;
                  } else if (heController.text.isNotEmpty) {
                    text = heController.text;
                  } else {
                    text = 'Not set';
                  }

                  return Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      color: text == 'Not set'
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF13364A),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            const Icon(Icons.edit_outlined, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet({
    required BuildContext context,
    required String title,
    required DoctorEditProfileController controller,
    required TextEditingController arController,
    required TextEditingController enController,
    required TextEditingController heController,
    int maxLines = 1,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF13364A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Obx(() {
                    final active = controller.activeLanguages;
                    final List<Widget> fields = [];

                    if (active.contains('ar')) {
                      fields.add(
                        _buildLangField('Arabic', arController, maxLines),
                      );
                      fields.add(const SizedBox(height: 12));
                    }
                    if (active.contains('en')) {
                      fields.add(
                        _buildLangField('English', enController, maxLines),
                      );
                      fields.add(const SizedBox(height: 12));
                    }
                    if (active.contains('he')) {
                      fields.add(
                        _buildLangField('Hebrew', heController, maxLines),
                      );
                      fields.add(const SizedBox(height: 12));
                    }

                    if (fields.isNotEmpty) {
                      fields.removeLast();
                    }

                    return Column(children: fields);
                  }),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLangField(
    String lang,
    TextEditingController controller,
    int maxLines,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF13364A),
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF13364A),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLockedField({
    required BuildContext context,
    required DoctorEditProfileController controller,
    required IconData icon,
    required String value,
    bool isDropdown = false,
  }) {
    return GestureDetector(
      onTap: () => controller.showLockedFieldAlert(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          color: Colors.transparent, // Looks editable but isn't
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value.isEmpty ? 'Not set' : value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF13364A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isDropdown)
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF6B7280),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF13364A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: Color(0xFF6B7280),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLockedRow({
    required BuildContext context,
    required DoctorEditProfileController controller,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () => controller.showLockedFieldAlert(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF13364A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.lock_outline,
                      size: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOnlineScheduleDialog(
    BuildContext context,
    DoctorEditProfileController controller,
  ) {
    Get.dialog(_AddOnlineScheduleDialog(controller: controller));
  }
}

class _AddOnlineScheduleDialog extends StatefulWidget {
  final DoctorEditProfileController controller;
  const _AddOnlineScheduleDialog({required this.controller});

  @override
  State<_AddOnlineScheduleDialog> createState() =>
      _AddOnlineScheduleDialogState();
}

class _AddOnlineScheduleDialogState extends State<_AddOnlineScheduleDialog> {
  String selectedDay = 'saturday';
  int? fromHour;
  int? toHour;

  Future<void> _pickTime(BuildContext context, bool isFrom) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromHour = picked.hour;
        } else {
          toHour = picked.hour;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Online Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF13364A),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedDay,
              decoration: InputDecoration(
                labelText: 'Day',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items:
                  [
                        'saturday',
                        'sunday',
                        'monday',
                        'tuesday',
                        'wednesday',
                        'thursday',
                        'friday',
                      ]
                      .map(
                        (day) => DropdownMenuItem(
                          value: day,
                          child: Text(day.capitalizeFirst ?? day),
                        ),
                      )
                      .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedDay = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        fromHour != null ? '$fromHour:00' : 'From',
                        style: TextStyle(
                          color: fromHour != null
                              ? const Color(0xFF13364A)
                              : Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _pickTime(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        toHour != null ? '$toHour:00' : 'To',
                        style: TextStyle(
                          color: toHour != null
                              ? const Color(0xFF13364A)
                              : Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (fromHour != null && toHour != null) {
                    widget.controller.addOnlineSchedule(
                      selectedDay,
                      fromHour.toString(),
                      toHour.toString(),
                    );
                  } else {
                    Get.snackbar(
                      'Missing Info',
                      'Please select both start and end times.',
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Schedule',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
