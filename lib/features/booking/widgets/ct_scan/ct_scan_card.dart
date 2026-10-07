import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'ct_scan_data.dart';

class CTScanCard extends StatelessWidget {
  const CTScanCard({
    super.key,
    required this.card,
    required this.selected,
    required this.onTap,
  });

  final ScanCardData card;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border.withValues(alpha: .7),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? AppColors.primary.withValues(alpha: .3)
                    : AppColors.shadowLight.withValues(alpha: .03),
                blurRadius: selected ? 18 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: Row(
            children: [
              // ICON
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: selected
                      ? AppColors.white.withValues(alpha: .2)
                      : AppColors.surface,
                ),
                child: Icon(
                  card.icon,
                  size: 30,
                  color: selected ? AppColors.white : AppColors.primary,
                ),
              ),

              const SizedBox(width: 14),

              // CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? AppColors.white
                            : AppColors.textPrimary,
                      ),
                      child: Text(card.title),
                    ),

                    const SizedBox(height: 5),

                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? AppColors.white.withValues(alpha: .8)
                            : AppColors.textSecondary,
                      ),
                      child: Text(
                        card.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // CHECK
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: selected ? AppColors.white : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  selected ? Icons.check_rounded : Icons.add_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CTScanCardColumn extends StatelessWidget {
  const CTScanCardColumn({
    super.key,
    required this.cards,
    required this.selectedIds,
    required this.onTap,
  });

  final List<ScanCardData> cards;
  final Set<String> selectedIds;
  final Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          CTScanCard(
            card: cards[i],
            selected: selectedIds.contains(cards[i].id),
            onTap: () => onTap(cards[i].id),
          ),

          if (i != cards.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}
