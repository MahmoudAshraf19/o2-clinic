import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:o2_clinic/common/widgets/common_snackbar.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';

import '../../../../common/widgets/common_button.dart';
import '../../../../common/widgets/common_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../booking/data/models/fs_booking_model.dart';

class ReportIssueScreen extends StatefulWidget {
  final String bookingId;
  final bool isPatient;

  const ReportIssueScreen({
    super.key,
    required this.bookingId,
    required this.isPatient,
  });

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  static const int _minChars = 10;
  static const int _maxChars = 500;

  final _textController = TextEditingController();

  /// Bytes (not a File) so the same code works on mobile and web.
  Uint8List? _imageBytes;
  String? _errorText;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final length = _textController.text.trim().length;
    if (_errorText != null && length >= _minChars && length <= _maxChars) {
      setState(() => _errorText = null);
    }
  }

  bool get _isAr => Localizations.localeOf(context).languageCode == 'ar';

  Future<void> _pickImage() async {
    final isAr = _isAr;
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => _imageBytes = bytes);
    } catch (_) {
      CommonSnackbar.showError(
        title: AppLocalizations.of(context)!.errorTitle,
        message: AppLocalizations.of(context)!.couldNotPickImage,
      );
    }
  }

  Future<void> _submitReport() async {
    final isAr = _isAr;
    final l10n = AppLocalizations.of(context)!;
    final text = _textController.text.trim();

    if (text.length < _minChars) {
      setState(() {
        _errorText = l10n.reportDescLengthError(_minChars);
      });
      return;
    }
    if (text.length > _maxChars) {
      setState(() {
        _errorText = l10n.reportDescMaxLengthError(_maxChars);
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      String? imageUrl;
      final bytes = _imageBytes;
      if (bytes != null) {
        final ref = FirebaseStorage.instance.ref().child(
          'reports/${widget.bookingId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        imageUrl = await ref.getDownloadURL();
      }

      final report = BookingReportModel(
        text: text,
        image: imageUrl,
        createdAt: DateTime.now(),
      );

      final reportMap = {
        'text': report.text,
        'image': report.image,
        'createdAt': Timestamp.fromDate(report.createdAt),
      };

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
            'status.current': 'under_investigation',
            if (widget.isPatient)
              'patientReport': reportMap
            else
              'doctorReport': reportMap,
          });

      Get.back();
      CommonSnackbar.showSuccess(
        title: l10n.reportIssue,
        message: l10n.reportSubmittedSuccess,
      );
    } catch (_) {
      CommonSnackbar.showError(
        title: l10n.errorTitle,
        message: l10n.reportSubmitFailed,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = _isAr;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            l10n.reportIssue,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
          elevation: 0,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInfoBanner(isAr),
                        const SizedBox(height: 16),
                        CommonTextField(
                          controller: _textController,
                          maxLines: 5,
                          hint: l10n.describeTheIssue,
                          type: CommonTextFieldType.multiline,
                        ),
                        const SizedBox(height: 6),
                        _buildHelperRow(),
                        const SizedBox(height: 16),
                        _buildImageSection(l10n),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CommonButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  text: l10n.submitReport,
                  type: CommonButtonType.primary,
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  borderRadius: BorderRadius.circular(12),
                  isLoading: _isSubmitting,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner(bool isAr) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.orange700.withValues(alpha: 0.1) 
            : AppColors.orange50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: AppColors.orange700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isAr
                  ? 'سيقوم فريقنا بمراجعة بلاغك، وستتغير حالة الحجز إلى "قيد المراجعة".'
                  : 'Our team will review your report and the booking status will change to "Under review".',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.orange700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelperRow() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _textController,
      builder: (context, value, _) {
        final length = value.text.trim().length;
        final overLimit = length > _maxChars;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _errorText == null
                  ? const SizedBox.shrink()
                  : Text(
                      _errorText!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.red,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            Text(
              '$length/$_maxChars',
              style: TextStyle(
                fontSize: 12,
                color: overLimit ? AppColors.red : AppColors.grey500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageSection(AppLocalizations l10n) {
    final bytes = _imageBytes;

    if (bytes == null) {
      return CommonButton(
        onPressed: _isSubmitting ? null : _pickImage,
        icon: Icons.image,
        text: l10n.attachImage,
        type: CommonButtonType.outline,
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: BorderRadius.circular(12),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        PositionedDirectional(
          top: 6,
          end: 6,
          child: IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: _isSubmitting
                ? null
                : () => setState(() => _imageBytes = null),
            style: IconButton.styleFrom(backgroundColor: AppColors.black54),
          ),
        ),
      ],
    );
  }
}
