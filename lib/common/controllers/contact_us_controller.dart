import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../features/services_firestore/contact_us_firestore_service.dart';
import '../../features/services_firestore/models/contact_us_model.dart';

class ContactUsController extends GetxController {
  final ContactUsFirestoreService _service = ContactUsFirestoreService();
  
  final Rx<ContactUsModel?> contactUsData = Rx<ContactUsModel?>(null);
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchContactUsData();
  }

  void _fetchContactUsData() {
    _service.watchContactUsData().listen(
      (data) {
        contactUsData.value = data;
        isLoading.value = false;
        error.value = '';
      },
      onError: (err) {
        isLoading.value = false;
        error.value = 'Failed to load contact info';
        print('Error in ContactUsController: $err');
      },
    );
  }

  String getLocalizedText(LocalizedContactString? localizedString, BuildContext context) {
    if (localizedString == null) return '';
    final langCode = Localizations.localeOf(context).languageCode;
    if (langCode == 'ar') return localizedString.ar;
    if (langCode == 'he') return localizedString.he;
    return localizedString.en;
  }
}
