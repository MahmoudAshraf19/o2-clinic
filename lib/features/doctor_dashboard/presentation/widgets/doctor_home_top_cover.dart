import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/doctor_app_bar.dart';
import '../../../notifications/presentation/controllers/notifications_controller.dart';
import '../../../notifications/presentation/widgets/notification_dropdown_widget.dart';
import 'package:get/get.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';

class DoctorHomeTopCover extends StatefulWidget {
  const DoctorHomeTopCover({super.key});

  @override
  State<DoctorHomeTopCover> createState() => _DoctorHomeTopCoverState();
}

class _DoctorHomeTopCoverState extends State<DoctorHomeTopCover> {
  String _doctorName = '';
  String _doctorImage = '';
  bool _isLoading = true;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _doctorSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToDoctorProfile();
  }

  void _subscribeToDoctorProfile() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _doctorSubscription?.cancel();
      if (user != null) {
        _doctorSubscription = FirebaseFirestore.instance
            .collection(AppFirestoreCollections.doctors)
            .where('auth_uid', isEqualTo: user.uid)
            .limit(1)
            .snapshots()
            .listen((snapshot) {
              if (snapshot.docs.isNotEmpty) {
                final data = snapshot.docs.first.data();

                // Handle localized name based on app locale, or just fallback to English for now
                // To be precise, we can just use name_en or the title_en depending on how it's stored.
                // But we will fetch name_en by default, and update with locale later if needed.
                String name =
                    data['name_en'] ?? data['name_ar'] ?? data['name_he'] ?? '';
                String image = data['image'] ?? '';

                if (mounted) {
                  setState(() {
                    _doctorName = name;
                    _doctorImage = image;
                    _isLoading = false;
                  });
                }
              } else {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _doctorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Current date format like "9 September, 2026"
    final String formattedDate = DateFormat(
      'd MMMM, yyyy',
    ).format(DateTime.now());

    // You can adjust the colors to match AppColors if needed
    final Color surface = AppColors.white;

    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      expandedHeight: 357.0,
      pinned: true,
      elevation: 0,
      stretch: true,
      toolbarHeight: 72.0,
      surfaceTintColor: AppColors.transparent,
      titleSpacing: 0, // Remove default title padding
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Calculate if we are collapsed or close to it
          final top = constraints.biggest.height;
          final safeAreaTop = MediaQuery.of(context).padding.top;
          final isCollapsed = top <= 72.0 + safeAreaTop + 20;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. The FlexibleSpaceBar (Cover Image and Bottom Greetings)
              FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_isLoading)
                          Container(
                            color: AppColors.grey200,
                            child: const Center(
                              child: CommonLoadingIndicator(),
                            ),
                          )
                        else if (_doctorImage.isEmpty)
                          Container(
                            color: AppColors.primaryContainer,
                            child: const Icon(
                              Icons.person,
                              size: 80,
                              color: AppColors.white,
                            ),
                          )
                        else
                          CachedNetworkImage(
                            imageUrl: _doctorImage,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.primaryContainer,
                              child: const Icon(
                                Icons.person,
                                size: 80,
                                color: AppColors.white,
                              ),
                            ),
                          ),

                        // Gradient overlay
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.color66000000, // Top shadow for icons
                                AppColors.color11000000, // Middle clear
                                AppColors.colorE6000000, // Bottom dark for text
                              ],
                              stops: [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),

                        // Bottom greeting
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isLoading
                                    ? 'Hi Dr...'
                                    : (_doctorName.isNotEmpty
                                          ? 'Hi $_doctorName'
                                          : 'Hi Doctor'),
                                style: const TextStyle(
                                  fontSize: 24,
                                  height: 1.3,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.white,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 8,
                                      color: AppColors.color99000000,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColors.white70,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppColors.white70,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. The DoctorAppBar that fades in when collapsed
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isCollapsed ? 1.0 : 0.0,
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: DoctorAppBar(),
                ),
              ),

              // 3. Top controls (Notification Icon) that fades OUT when collapsed
              Positioned(
                top: 16 + safeAreaTop,
                left: 20,
                right: 20,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isCollapsed ? 0.0 : 1.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.dialog(
                            const NotificationDropdownWidget(),
                            barrierColor: AppColors.transparent,
                          );
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: surface.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: surface.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: AppColors.white,
                                size: 24,
                              ),
                            ),
                            if (Get.isRegistered<NotificationsController>())
                              Obx(() {
                                final unreadCount =
                                    Get.find<NotificationsController>()
                                        .unreadCount;
                                if (unreadCount == 0) {
                                  return const SizedBox.shrink();
                                }
                                return Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      unreadCount > 9
                                          ? '9+'
                                          : unreadCount.toString(),
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
