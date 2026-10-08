import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';

class HtmlContentScreen extends StatelessWidget {
  final String title;
  final String collection;
  final String docId;
  final String fieldName;

  const HtmlContentScreen({
    super.key,
    required this.title,
    required this.collection,
    required this.docId,
    required this.fieldName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: AppFonts.dancingScript,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection(collection)
            .doc(docId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CommonLoadingIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading content',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Content not found',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final String htmlData = data?[fieldName] ?? '';

          if (htmlData.isEmpty) {
            return Center(
              child: Text(
                'Content is empty',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Html(
              data: htmlData,
              style: {
                "body": Style(
                  color: AppColors.textPrimary,
                  fontSize: FontSize(14.0),
                ),
              },
            ),
          );
        },
      ),
    );
  }
}
