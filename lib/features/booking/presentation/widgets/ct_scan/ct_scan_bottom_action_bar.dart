import 'package:o2_clinic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../../common/widgets/common_button.dart';

import '../../../../../core/theme/app_colors.dart';

class CTScanBottomActionBar extends StatelessWidget {
  const CTScanBottomActionBar({
    super.key,
    required this.selectedCount,
    required this.onContinue,
  });

  final int selectedCount;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.border.withValues(alpha: .7)),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.selected,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    '$selectedCount Scan${selectedCount == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: SizedBox(
                height: 52,
                child: CommonButton(
                  onPressed: onContinue,
                  text: AppLocalizations.of(context)!.continueAction,
                  type: CommonButtonType.primary,
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 0,
                  icon: Icons.arrow_forward_rounded,
                  textStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
