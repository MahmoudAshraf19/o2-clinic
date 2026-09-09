import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:o2_clinic/core/models/language_model.dart';
import 'package:o2_clinic/core/localization/locale_controller.dart';

class ChangeLanguageController extends ChangeNotifier {
  final LocaleController localeController;
  
  LanguageModel? _selectedLanguage;
  LanguageModel? get selectedLanguage => _selectedLanguage;

  List<LanguageModel> _languageList = [];
  List<LanguageModel> get languageList => _languageList;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ChangeLanguageController({required this.localeController}) {
    _fetchLanguages();
  }

  Future<void> _fetchLanguages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('languages').get();
      
      _languageList = querySnapshot.docs
          .map((doc) => LanguageModel.fromJson(doc.data()))
          .where((lang) => lang.isActive) // Only show active languages
          .toList();

      // Set initially selected language
      final currentCode = localeController.currentLanguageCode;
      for (var lang in _languageList) {
        if (lang.slug == currentCode) {
          _selectedLanguage = lang;
          break;
        }
      }
      
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('[ChangeLanguageController] _fetchLanguages Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectLanguage(LanguageModel language) {
    if (_selectedLanguage?.slug != language.slug) {
      _selectedLanguage = language;
      localeController.changeLocale(language.slug);
      notifyListeners();
    }
  }
}
