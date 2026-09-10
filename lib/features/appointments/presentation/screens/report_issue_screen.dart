import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../../../../core/theme/app_colors.dart';
import '../../../services_firestore/services/bookings_firestore_service.dart';
import '../../../services_firestore/models/booking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportIssueScreen extends StatefulWidget {
  final String bookingId;
  final bool isPatient;

  const ReportIssueScreen({super.key, required this.bookingId, required this.isPatient});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _textController = TextEditingController();
  File? _selectedImage;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _submitReport() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('reports/${widget.bookingId}_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(_selectedImage!);
        imageUrl = await ref.getDownloadURL();
      }

      final report = BookingReportModel(
        text: _textController.text.trim(),
        image: imageUrl,
        createdAt: DateTime.now(),
      );

      final Map<String, dynamic> updateData = {
        'status.current': 'under_investigation',
      };

      if (widget.isPatient) {
        updateData['patientReport'] = {
          'text': report.text,
          'image': report.image,
          'createdAt': Timestamp.fromDate(report.createdAt),
        };
      } else {
        updateData['doctorReport'] = {
          'text': report.text,
          'image': report.image,
          'createdAt': Timestamp.fromDate(report.createdAt),
        };
      }

      await FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).update(updateData);
      
      Get.back();
      Get.snackbar(
        AppLocalizations.of(context)!.reportIssue ?? 'Report Issue',
        'Submitted successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

    } catch (e) {
      Get.snackbar('Error', 'Failed to submit report', backgroundColor: AppColors.error, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(l10n.reportIssue ?? 'Report Issue', style: const TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _textController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: l10n.describeTheIssue ?? 'Describe the issue...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedImage != null)
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => setState(() => _selectedImage = null),
                      style: IconButton.styleFrom(backgroundColor: Colors.black54),
                    ),
                  ],
                )
              else
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: Text(l10n.attachImage ?? 'Attach Image'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(l10n.submitReport ?? 'Submit Report', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
