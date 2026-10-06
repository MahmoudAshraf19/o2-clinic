import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../common/controllers/app_constants_controller.dart';
import '../widgets/Ultrasound/ultrasound_background.dart';
import '../widgets/Ultrasound/ultrasound_bottom_bar.dart';
import '../widgets/Ultrasound/ultrasound_card.dart';
import '../widgets/Ultrasound/ultrasound_data.dart';
import 'ultrasound_booking_page.dart';

class UltrasoundScreen extends StatefulWidget {
  const UltrasoundScreen({super.key});

  @override
  State<UltrasoundScreen> createState() => _UltrasoundScreenState();
}

class _UltrasoundScreenState extends State<UltrasoundScreen> {
  final Set<String> _selectedIds = {};
  List<UltrasoundModel> ultrasoundData = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    try {
      final currency = Get.find<AppConstantsController>().currencySymbol.value;
      print(
        "🖨️ [UltrasoundScreen] Screen initialized. Current Currency: '$currency'",
      );
    } catch (e) {
      print("🖨️ [UltrasoundScreen] Could not read currency: $e");
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await UltrasoundData.loadFromFirestore();
      if (mounted) {
        setState(() {
          ultrasoundData = data;
        });
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _showTopSnack({required String title, required String message}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isNarrow = size.width < 360;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const UltrasoundBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.ultrasound,
                              style: TextStyle(
                                fontSize: isNarrow ? 23 : 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontFamily: AppFonts.dancingScript,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              AppLocalizations.of(
                                context,
                              )!.selectUltrasoundType,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary.withValues(
                                  alpha: .75,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _isLoading
                        ? const Center(
                            key: ValueKey('loading'),
                            child: CircularProgressIndicator(),
                          )
                        : _errorMessage != null
                        ? _buildErrorState()
                        : _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: UltrasoundBottomBar(
        selectedCount: _selectedIds.length,
        onContinue: () {
          if (_selectedIds.isEmpty) {
            _showTopSnack(
              title: AppLocalizations.of(context)!.noSelection,
              message: 'Please select at least one ultrasound type',
            );
            return;
          }

          final model = ultrasoundData.firstWhere(
            (e) => e.id == _selectedIds.first,
          );

          Get.to(() => UltrasoundBookingPage(model: model));
        },
      ),
    );
  }

  Widget _buildContent() {
    if (ultrasoundData.isEmpty) {
      return _buildEmptyState(
        title: AppLocalizations.of(context)!.noUltrasoundTypesFound,
        subtitle: AppLocalizations.of(context)!.pleaseCheckTheFirestoreDocument,
        icon: Icons.medical_information_outlined,
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.selectUltrasoundType,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,

                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  AppLocalizations.of(
                    context,
                  )!.chooseTheRequiredDiagnosticProcedure,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,

                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 12),
                UltrasoundCardColumn(
                  cards: ultrasoundData,
                  selectedIds: _selectedIds,
                  onTap: _toggleSelection,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.failedToLoadUltrasoundData,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: AppColors.primary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

