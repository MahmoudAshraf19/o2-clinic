import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;

import '../../../../l10n/app_localizations.dart';
import '../../services_firestore/models/doctor_model.dart';
import 'doctor_profile_controller.dart';

class DoctorEditProfileController extends GetxController {
  final DoctorProfileController _profileController =
      Get.find<DoctorProfileController>();

  final formKey = GlobalKey<FormState>();

  final nameArController = TextEditingController();
  final nameEnController = TextEditingController();
  final nameHeController = TextEditingController();

  final titleArController = TextEditingController();
  final titleEnController = TextEditingController();
  final titleHeController = TextEditingController();

  final descArController = TextEditingController();
  final descEnController = TextEditingController();
  final descHeController = TextEditingController();

  final emailController = TextEditingController();
  final onlinePriceController = TextEditingController();

  final isOnlineAvailable = false.obs;

  final Rx<XFile?> selectedImage = Rx<XFile?>(null);
  Uint8List? webImageBytes;
  String existingImageUrl = '';

  // Hardcoded locked variables for UI display
  String specialty = '';
  int yearsExperience = 0;
  String regularPrice = '';
  Map<String, String> availabilityDay = {};
  final RxMap<String, List<Map<String, String>>> onlineSchedule =
      <String, List<Map<String, String>>>{}.obs;

  final activeLanguages = <String>['ar', 'en', 'he'].obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  void _initData() {
    final doctor = _profileController.doctor.value;
    if (doctor != null) {
      nameArController.text = doctor.nameAr;
      nameEnController.text = doctor.nameEn;
      nameHeController.text = doctor.nameHe;

      titleArController.text = doctor.titleAr;
      titleEnController.text = doctor.titleEn;
      titleHeController.text = doctor.titleHe;

      descArController.text = doctor.descriptionAr;
      descEnController.text = doctor.descriptionEn;
      descHeController.text = doctor.descriptionHe;

      emailController.text = doctor.email;

      onlinePriceController.text = doctor.priceForOnline.toString();
      isOnlineAvailable.value = doctor.isOnlineConsultationAvailable;
      existingImageUrl = doctor.image;

      specialty = doctor.specialty;
      yearsExperience = doctor.yearsExperience;
      regularPrice = doctor.price.toString();
      availabilityDay = doctor.availabilityDay;
      onlineSchedule.value = Map<String, List<Map<String, String>>>.from(
        doctor.availabilityDayOnline.map(
          (k, v) => MapEntry(k, List<Map<String, String>>.from(v)),
        ),
      );
    }

    _fetchActiveLanguages();
  }

  Future<void> _fetchActiveLanguages() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('languages')
          .where('isActive', isEqualTo: true)
          .get();
      if (snapshot.docs.isNotEmpty) {
        activeLanguages.value = snapshot.docs
            .map((doc) => doc.data()['slug'] as String)
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching languages: $e');
    }
  }

  void addOnlineSchedule(String day, String from, String to) {
    final fromTime = int.tryParse(from) ?? 0;
    final toTime = int.tryParse(to) ?? 0;

    if (fromTime >= toTime) {
      Get.snackbar(
        'Invalid Time',
        'Start time must be before end time.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final currentDaySchedules = onlineSchedule[day] ?? [];

    bool hasOverlap = false;
    for (var schedule in currentDaySchedules) {
      final existingFrom = int.tryParse(schedule['from']!) ?? 0;
      final existingTo = int.tryParse(schedule['to']!) ?? 0;

      if (fromTime < existingTo && toTime > existingFrom) {
        hasOverlap = true;
        break;
      }
    }

    if (hasOverlap) {
      Get.snackbar(
        'Conflict',
        'This time slot overlaps with an existing schedule for ${day.capitalizeFirst}.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    currentDaySchedules.add({'from': from, 'to': to});

    currentDaySchedules.sort((a, b) {
      final aFrom = int.tryParse(a['from']!) ?? 0;
      final bFrom = int.tryParse(b['from']!) ?? 0;
      return aFrom.compareTo(bFrom);
    });

    onlineSchedule[day] = currentDaySchedules;
    Get.back();
  }

  void removeOnlineScheduleSlot(String day, int index) {
    if (onlineSchedule.containsKey(day)) {
      final list = onlineSchedule[day]!;
      list.removeAt(index);
      if (list.isEmpty) {
        onlineSchedule.remove(day);
      } else {
        onlineSchedule[day] = list;
      }
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = pickedFile;
      if (kIsWeb) {
        webImageBytes = await pickedFile.readAsBytes();
      }
    }
  }

  void toggleOnline(bool val) {
    isOnlineAvailable.value = val;
  }

  void showLockedFieldAlert(BuildContext context) {
    Get.snackbar(
      AppLocalizations.of(context)!.warning,
      AppLocalizations.of(context)!.contactAdminToEdit,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;

    _profileController.isLoading.value = true;

    try {
      String finalImageUrl = existingImageUrl;

      // 1. Upload image if selectedImage != null
      if (selectedImage.value != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('doctors_profiles')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        if (kIsWeb) {
          // Image compression via flutter_image_compress is not supported on web natively
          // We bypass it on Web and upload bytes directly
          try {
            if (webImageBytes == null) {
              webImageBytes = await selectedImage.value!.readAsBytes();
            }
            await ref.putData(webImageBytes!);
          } catch (e) {
            debugPrint('Image upload failed on web: $e');
            throw Exception('File upload failed on Web: $e');
          }
        } else {
          final bytes = await FlutterImageCompress.compressWithFile(
            selectedImage.value!.path,
            quality: 60,
          );

          if (bytes != null) {
            await ref.putData(bytes);
          } else {
            await ref.putFile(File(selectedImage.value!.path));
          }
        }

        finalImageUrl = await ref.getDownloadURL();
      }

      // 2. Prepare data map
      final Map<String, dynamic> data = {
        'name_ar': nameArController.text.trim(),
        'name_en': nameEnController.text.trim(),
        'name_he': nameHeController.text.trim(),
        'title_ar': titleArController.text.trim(),
        'title_en': titleEnController.text.trim(),
        'title_he': titleHeController.text.trim(),
        'description_ar': descArController.text.trim(),
        'description_en': descEnController.text.trim(),
        'description_he': descHeController.text.trim(),
        'email': emailController.text.trim(),
        'is_online_consultation_available': isOnlineAvailable.value,
        'image': finalImageUrl,
      };

      if (isOnlineAvailable.value) {
        final onlinePrice = double.tryParse(onlinePriceController.text.trim());
        if (onlinePrice != null) {
          data['pirce_for_online'] = onlinePrice;
        }
        data['availability_day_online'] = onlineSchedule;
      }

      // 3. Call _profileController.updateProfile(data)
      final success = await _profileController.updateProfile(data);
      if (success) {
        Get.back();
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error saving profile: $e');
      debugPrint('Stacktrace: $stackTrace');

      Get.snackbar(
        'Error',
        'Failed to save profile: ${e.toString()}',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _profileController.isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameArController.dispose();
    nameEnController.dispose();
    nameHeController.dispose();
    titleArController.dispose();
    titleEnController.dispose();
    titleHeController.dispose();
    descArController.dispose();
    descEnController.dispose();
    descHeController.dispose();
    emailController.dispose();
    onlinePriceController.dispose();
    super.onClose();
  }
}
