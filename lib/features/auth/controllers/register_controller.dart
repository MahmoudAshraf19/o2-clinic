import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io' as io;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/countries.dart';
import '../../profile/models/dashboard_profile_model.dart';
import '../../services_firestore/user_firestore_service.dart';

class RegisterController extends GetxController {
  final name = TextEditingController();
  final username = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final bio = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  final selectedCountry = Countries.all.first.obs;
  final countryCode = '+20'.obs;
  final gender = 'Male'.obs;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;
  final emailError = ''.obs;
  final showPassword = false.obs;
  final showConfirm = false.obs;

  final imagePath = ''.obs;
  final hasStartedTypingPassword = false.obs;
  final hasStartedTypingConfirm = false.obs;
  final passwordMatch = false.obs;

  final picker = ImagePicker();

  bool isSocial = false;
  bool isEditMode = false;

  String socialUid = '';
  String providerId = '';
  String _editingUid = '';

  final generatedId = ''.obs;

  @override
  void onInit() {
    super.onInit();

    _log('REGISTER: controller initialized');

    password.addListener(checkPasswordMatch);
    confirmPassword.addListener(checkPasswordMatch);

    _applyArguments();
    _prepareForm();
  }

  void _applyArguments() {
    final args = Get.arguments;

    if (args is! Map) {
      _log('REGISTER: no route arguments found');
      return;
    }

    final map = Map<String, dynamic>.from(args);
    final mode = (map['mode'] ?? '').toString().toLowerCase();

    isEditMode = mode == 'edit';
    _log('REGISTER: route mode = $mode');

    if (isEditMode) {
      _editingUid = (map['uid'] ?? '').toString();
      final profile = map['profile'] ?? map['user'] ?? map['data'];

      if (profile is DashboardProfileModel) {
        _log('REGISTER: filling edit form from DashboardProfileModel');
        _fillFromModel(profile);
      } else if (profile is Map) {
        _log('REGISTER: filling edit form from raw map');
        _fillFromMap(Map<String, dynamic>.from(profile));
      }

      if (_editingUid.isEmpty) {
        _editingUid = username.text.trim();
      }

      _log('REGISTER: edit mode activated for uid=$_editingUid');
      return;
    }

    final socialMode = mode == 'social';
    if (socialMode) {
      isSocial = true;
      socialUid = (map['uid'] ?? '').toString();
      providerId = (map['providerId'] ?? '').toString();

      name.text = (map['name'] ?? '').toString();
      email.text = (map['email'] ?? '').toString();
      imagePath.value = (map['photoUrl'] ?? '').toString();

      _log('REGISTER: social mode detected');
      _log('REGISTER: socialUid = $socialUid');
      _log('REGISTER: providerId = $providerId');
    }
  }

  void _prepareForm() {
    if (isEditMode) {
      if (username.text.trim().isEmpty) {
        username.text = generatedId.value;
      }
      _log('REGISTER: edit form prepared');
      return;
    }

    _prepareAutoId();
  }

  void _fillFromModel(DashboardProfileModel profile) {
    name.text = profile.name;
    username.text = profile.username.isNotEmpty
        ? profile.username
        : profile.uid;
    email.text = profile.email;
    bio.text = profile.bio;
    gender.value = profile.gender.isNotEmpty ? profile.gender : 'Male';
    imagePath.value = profile.image;

    if (profile.phoneCountryCode.trim().isNotEmpty) {
      countryCode.value = profile.phoneCountryCode.trim();
      selectedCountry.value = _countryFromDialCode(profile.phoneCountryCode);
    }

    if (profile.phoneNumber.trim().isNotEmpty) {
      phone.text = profile.phoneNumber.trim();
    } else if (profile.phoneFullNumber.trim().isNotEmpty) {
      phone.text = _extractPhoneNumber(profile.phoneFullNumber);
    }

    _log('REGISTER: profile model loaded into form');
  }

  void _fillFromMap(Map<String, dynamic> data) {
    name.text = (data['name'] ?? '').toString();
    username.text = (data['username'] ?? data['id'] ?? data['uid'] ?? '')
        .toString();
    email.text = (data['email'] ?? '').toString();
    bio.text = (data['bio'] ?? '').toString();
    gender.value = (data['gender'] ?? 'Male').toString();
    imagePath.value = (data['image'] ?? '').toString();

    final phoneMap = _asMap(data['phone']);
    final countryCodeValue = (phoneMap['country_code'] ?? '').toString();
    final numberValue = (phoneMap['number'] ?? '').toString();
    final fullPhoneValue = (phoneMap['full_phone'] ?? '').toString();

    if (countryCodeValue.trim().isNotEmpty) {
      countryCode.value = countryCodeValue.trim();
      selectedCountry.value = _countryFromDialCode(countryCodeValue);
    }

    if (numberValue.trim().isNotEmpty) {
      phone.text = numberValue.trim();
    } else if (fullPhoneValue.trim().isNotEmpty) {
      phone.text = _extractPhoneNumber(fullPhoneValue);
    }

    _log('REGISTER: raw profile map loaded into form');
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _extractPhoneNumber(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length <= 1) return trimmed;

    return parts.sublist(1).join(' ').trim();
  }

  dynamic _countryFromDialCode(String dialCode) {
    final code = dialCode.trim();
    return Countries.all.firstWhere(
      (country) => country.dialCode == code,
      orElse: () => Countries.all.first,
    );
  }

  Future<void> _prepareAutoId() async {
    _log('REGISTER: generating unique username/id...');
    try {
      final id = await _generateUniqueId(
        seed: isSocial && socialUid.isNotEmpty ? socialUid : null,
      );

      generatedId.value = id;
      username.text = id;

      _log('REGISTER: unique id ready -> $id');
    } catch (e) {
      _log('REGISTER ERROR: failed to prepare auto ID -> $e');
      errorMessage.value = 'Failed to generate a unique ID.';
    }
  }

  String _baseId({String? seed}) {
    // Generate a clean numeric ID like O2-482910
    final rnd = Random.secure().nextInt(900000) + 100000; // 100000 to 999999
    return 'O2-$rnd';
  }

  Future<String> _generateUniqueId({String? seed}) async {
    final firestore = FirebaseFirestore.instance;

    for (int attempt = 1; attempt <= 5; attempt++) {
      final candidate = _baseId(seed: attempt == 1 ? seed : null);

      _log('REGISTER: checking ID candidate [$attempt] -> $candidate');

      final existing = await firestore
          .collection('users')
          .where('id', isEqualTo: candidate)
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        _log('REGISTER: candidate accepted -> $candidate');
        return candidate;
      }

      _log('REGISTER: collision detected, retrying...');
    }

    final fallback = _baseId(
      seed: '${seed ?? ''}_${DateTime.now().millisecondsSinceEpoch}',
    );

    _log('REGISTER: fallback ID used -> $fallback');
    return fallback;
  }

  void checkPasswordMatch() {
    if (password.text.isNotEmpty) hasStartedTypingPassword.value = true;
    if (confirmPassword.text.isNotEmpty) hasStartedTypingConfirm.value = true;

    final pass = password.text;
    final confirm = confirmPassword.text;

    if (pass.isEmpty || confirm.isEmpty) {
      passwordMatch.value = false;
      return;
    }

    passwordMatch.value = pass == confirm;
  }

  Future<void> pickImage() async {
    _log('REGISTER: opening image picker...');
    try {
      final img = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (img == null) {
        _log('REGISTER: image picking cancelled by user');
        return;
      }

      _log('REGISTER: image selected -> ${img.path}');
      final compressedPath = await _compressImageIfPossible(img.path);

      imagePath.value = compressedPath;
      _log(
        'REGISTER: image ready -> ${imagePath.value} '
        '(compressed=${compressedPath != img.path})',
      );
    } catch (e) {
      _log('REGISTER ERROR: image picking failed -> $e');
      errorMessage.value = 'Could not pick the image.';
      Get.snackbar(
        'Image Error',
        'Could not pick the image.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<String> _compressImageIfPossible(String path) async {
    if (kIsWeb) {
      _log('REGISTER: compression skipped on web');
      return path;
    }

    try {
      _log('REGISTER: compressing image...');

      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        path,
        targetPath,
        quality: 75,
        minWidth: 1024,
        minHeight: 1024,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        _log('REGISTER: compression returned null, using original file');
        return path;
      }

      _log('REGISTER: compression done -> ${result.path}');
      return result.path;
    } catch (e) {
      _log('REGISTER: compression failed, using original file -> $e');
      return path;
    }
  }

  bool _validate() {
    _log('REGISTER: validation started');

    if (isEditMode) {
      if (_editingUid.trim().isEmpty) return _error('User ID is missing');
      if (username.text.trim().isEmpty) return _error('Username is missing');
      if (email.text.trim().isEmpty) return _error('Email is missing');
      if (name.text.trim().isEmpty) return _error('Enter name');
      if (phone.text.trim().isEmpty) return _error('Enter phone');
      _log('REGISTER: edit validation passed');
      return true;
    }

    if (generatedId.value.isEmpty) return _error('ID is not ready yet');
    if (username.text.trim().isEmpty) {
      return _error('Username is not ready yet');
    }
    if (name.text.trim().isEmpty) return _error('Enter name');
    if (phone.text.trim().isEmpty) return _error('Enter phone');

    if (!isSocial) {
      if (email.text.trim().isEmpty) return _error('Enter email');
      if (password.text.length < 6) {
        return _error('Password must be at least 6 characters');
      }
      if (!passwordMatch.value) {
        return _error('Passwords do not match');
      }
    }

    _log('REGISTER: create validation passed');
    return true;
  }

  bool _error(String msg) {
    _log('REGISTER ERROR: $msg');
    errorMessage.value = msg;
    successMessage.value = '';

    Get.snackbar(
      'Oops',
      msg,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withValues(alpha: 0.15),
      barBlur: 15,
      colorText: const Color(0xFFB71C1C),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      borderRadius: 20,
      icon: const Icon(
        Icons.error_outline_rounded,
        color: Color(0xFFB71C1C),
        size: 30,
      ),
      duration: const Duration(seconds: 4),
      borderWidth: 1,
      borderColor: Colors.red.withValues(alpha: 0.2),
    );
    return false;
  }

  Future<void> submitForm() async {
    if (isLoading.value) return;

    _log('----------------------------------------');
    _log('REGISTER: submitForm() initiated');

    if (!_validate()) {
      _log('REGISTER ERROR: validation failed.');
      _log('----------------------------------------');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      successMessage.value = '';
      emailError.value = '';

      if (isEditMode) {
        final uid = _editingUid.isNotEmpty
            ? _editingUid
            : FirebaseAuth.instance.currentUser?.uid ?? '';

        if (uid.isEmpty) {
          throw Exception('Missing user uid');
        }

        _log('REGISTER: edit mode - updating Firestore for uid: $uid');

        String finalImageUrl = imagePath.value.trim();
        if (finalImageUrl.isNotEmpty &&
            !finalImageUrl.startsWith('https://firebasestorage')) {
          finalImageUrl = await _uploadProfileImage(uid, finalImageUrl);
        }

        final updateData = _buildUpdateData(finalImageUrl);

        await UserFirestoreService.instance.updateUser(
          uid: uid,
          data: updateData,
        );

        _log('REGISTER SUCCESS: Profile updated successfully.');

        successMessage.value = 'Profile updated successfully 🎉';

        await Future.delayed(const Duration(milliseconds: 900));

        _log('REGISTER: navigating back to previous screen...');
        Get.back(result: true);
        return;
      }

      _log('REGISTER: create mode - starting registration process');

      if (!isSocial) {
        final emailValue = email.text.trim();
        _log('REGISTER: checking if email exists in Firestore...');
        final isExists = await UserFirestoreService.instance.isEmailExists(
          emailValue,
        );
        if (isExists) {
          emailError.value = 'This email is already in use by another account.';
          isLoading.value = false;
          _log('REGISTER ERROR: Email already exists in Firestore.');
          _log('----------------------------------------');
          return;
        }
      }

      String? fcmToken;
      if (!kIsWeb) {
        _log('REGISTER: requesting FCM token...');
        fcmToken = await FirebaseMessaging.instance.getToken();
        _log('REGISTER: FCM token received -> ${fcmToken ?? "null"}');
      } else {
        _log('🌐 Web platform detected. FCM token generation skipped.');
      }

      String uid;
      String emailValue;

      if (isSocial) {
        _log('REGISTER: processing social account data');

        uid = socialUid.isNotEmpty
            ? socialUid
            : FirebaseAuth.instance.currentUser?.uid ?? '';

        if (uid.isEmpty) {
          throw Exception('Missing social UID');
        }

        emailValue = email.text.trim().isNotEmpty
            ? email.text.trim()
            : (FirebaseAuth.instance.currentUser?.email ?? '');

        _log('REGISTER: social uid -> $uid');
        _log('REGISTER: social email -> $emailValue');
      } else {
        _log('REGISTER: creating Firebase Auth account...');

        final auth = FirebaseAuth.instance;
        emailValue = email.text.trim();

        if (emailValue.isEmpty) {
          throw Exception('Email is empty');
        }

        final cred = await auth.createUserWithEmailAndPassword(
          email: emailValue,
          password: password.text.trim(),
        );

        uid = cred.user?.uid ?? '';

        if (uid.isEmpty) {
          throw Exception('Auth UID is empty');
        }

        _log('REGISTER: auth account created -> $uid');
      }

      if (generatedId.value.isEmpty) {
        _log('REGISTER: generated id missing, regenerating...');
        final fresh = await _generateUniqueId(seed: isSocial ? socialUid : uid);
        generatedId.value = fresh;
        username.text = fresh;
      }

      String finalImageUrl = imagePath.value.trim();
      if (finalImageUrl.isNotEmpty &&
          !finalImageUrl.startsWith('https://firebasestorage')) {
        finalImageUrl = await _uploadProfileImage(uid, finalImageUrl);
      }

      _log('REGISTER: preparing Firestore payload...');
      final userData = _buildCreateData(
        uid: uid,
        fcmToken: fcmToken ?? '',
        emailValue: emailValue,
        imageUrl: finalImageUrl,
      );

      _log('REGISTER: saving user document to Firestore...');
      await UserFirestoreService.instance.createUser(
        docId: generatedId.value,
        uid: uid,
        data: userData,
      );

      _log('REGISTER SUCCESS: Account/Profile created successfully.');

      _log('REGISTER: redirecting to main navigation');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', 'patient');

      Get.offAllNamed(AppRoutes.mainNavigation);

      Get.snackbar(
        'Success 🎉',
        isSocial ? 'Profile completed' : 'Account created',
        snackPosition: SnackPosition.TOP,
      );
    } on TimeoutException {
      _log('REGISTER ERROR: timeout while saving profile.');
      _error('Saving profile took too long. Check your connection.');
    } on FirebaseAuthException catch (e) {
      _log('REGISTER ERROR: Auth [${e.code}] - ${e.message}');
      if (e.code == 'email-already-in-use') {
        emailError.value = 'This email is already in use by another account.';
      } else {
        _error(e.message ?? 'Authentication error');
      }
    } on FirebaseException catch (e) {
      _log('REGISTER ERROR: Firebase [${e.code}] - ${e.message}');
      _error(_firebaseMessage(e));
    } catch (e) {
      _log('REGISTER ERROR: ${e.runtimeType} - $e');
      _error(_friendlyMessage(e));
    } finally {
      isLoading.value = false;
      _log('REGISTER: loading finished.');
      _log('----------------------------------------');
    }
  }

  Future<void> createAccount() async {
    await submitForm();
  }

  String _firebaseMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Firestore permission denied. Check your rules.';
      case 'unavailable':
        return 'Firestore is temporarily unavailable.';
      case 'deadline-exceeded':
        return 'Firestore request timed out.';
      case 'not-found':
        return 'Requested document was not found.';
      default:
        return 'Error: ${e.message ?? e.code}';
    }
  }

  String _friendlyMessage(Object e) {
    final text = e.toString();

    if (text.contains('network-request-failed')) {
      return 'No internet connection. Please check your network.';
    }
    if (text.contains('email-already-in-use')) {
      return 'This email is already used.';
    }
    if (text.contains('weak-password')) {
      return 'Password is too weak.';
    }

    return 'Something went wrong. Please try again.';
  }

  Map<String, dynamic> _buildCreateData({
    required String uid,
    required String fcmToken,
    required String emailValue,
    required String imageUrl,
  }) {
    _log('REGISTER: building create payload');

    return {
      'id': generatedId.value,
      'uid': uid,
      'name': name.text.trim(),
      'username': generatedId.value,
      'email': emailValue,
      'phone': {
        'country_code': countryCode.value,
        'number': phone.text.trim(),
        'full_phone': '${countryCode.value} ${phone.text.trim()}',
      },
      'gender': gender.value,
      'bio': bio.text.trim(),
      'image': imageUrl,
      'isBlocked': false,
      'lastVisit': {'date': '', 'type': ''},
      'settings': {
        'language': {'slug': 'en', 'title': 'English', 'is_rtl': false},
        'notifications': {'enabled': true, 'allow_push': true},
        'appearance': {'dark_mode': false},
      },
      'auth': {
        'fcm_token': fcmToken,
        'provider': isSocial ? providerId : 'password',
      },
      'app_info': {
        'currency': {'name': 'USD', 'symbol': r'$'},
        'version': '1.0',
      },
      'contact': {
        'address': '',
        'email': emailValue,
        'phone': '${countryCode.value}${phone.text.trim()}',
      },
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _buildUpdateData(String imageUrl) {
    _log('REGISTER: building update payload');

    final updateData = <String, dynamic>{
      'name': name.text.trim(),
      'phone': {
        'country_code': countryCode.value,
        'number': phone.text.trim(),
        'full_phone': '${countryCode.value} ${phone.text.trim()}',
      },
      'gender': gender.value,
      'bio': bio.text.trim(),
      'contact': {
        'address': '',
        'email': email.text.trim(),
        'phone': '${countryCode.value}${phone.text.trim()}',
      },
      'lastVisit': {'type': '', 'date': ''},
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (imageUrl.isNotEmpty) {
      updateData['image'] = imageUrl;
      _log('REGISTER: image included in update payload');
    }

    return updateData;
  }

  ImageProvider? getAvatarProvider() {
    final v = imagePath.value.trim();
    if (v.isEmpty) return null;

    if (!kIsWeb) {
      final isLocalPath =
          v.startsWith('/') || RegExp(r'^[a-zA-Z]:\\').hasMatch(v);
      if (isLocalPath) {
        return FileImage(io.File(v));
      }
    }

    if (v.startsWith('http')) {
      return CachedNetworkImageProvider(v);
    }

    return null;
  }

  Future<String> _uploadProfileImage(String uid, String localPath) async {
    if (localPath.trim().isEmpty) return '';
    if (localPath.startsWith('https://firebasestorage')) return localPath;

    _log('REGISTER: uploading profile image to Firebase Storage...');
    try {
      final bytes = await XFile(localPath).readAsBytes();
      final ext = 'jpg'; // Use a default extension for safety across platforms
      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(uid)
          .child('profile_image_$uid.$ext');

      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      _log('REGISTER: image uploaded successfully -> $downloadUrl');
      return downloadUrl;
    } catch (e) {
      _log('REGISTER ERROR: image upload failed -> $e');
      throw Exception('Failed to upload image. Please try again.');
    }
  }

  void _log(String msg) {
    if (kDebugMode) {
      debugPrint(msg);
    }
  }

  @override
  void onClose() {
    name.dispose();
    username.dispose();
    email.dispose();
    phone.dispose();
    bio.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}
