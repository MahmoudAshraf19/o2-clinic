// lib/features/booking/widgets/Ultrasound/ultrasound_card.dart

import 'package:flutter/material.dart';
import 'package:o2_clinic/core/widgets/cached_image_widget.dart';
import 'package:o2_clinic/features/booking/widgets/Ultrasound/ultrasound_data.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';

class UltrasoundCard extends StatelessWidget {
  const UltrasoundCard({
    super.key,
    required this.card,
    required this.selected,
    required this.onTap,
  });

  final UltrasoundModel card;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? AppColors.primary.withValues(alpha: .15)
                  : Colors.black.withValues(alpha: .05),
              blurRadius: selected ? 24 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Stack(
          children: [
            Positioned.fill(
              child: Hero(
                tag: card.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: CachedImageWidget(
                    imageUrl: card.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xff21897E),
                      const Color(0xff21897E).withValues(alpha: .75),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 22,
              right: 22,
              bottom: 22,
              child: Column(
                children: [
                  Text(
                    card.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    card.description,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: .92),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 16,
              right: 16,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: selected ? 1 : 0,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .88),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 28,
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

class UltrasoundCardColumn extends StatelessWidget {
  const UltrasoundCardColumn({
    super.key,
    required this.cards,
    required this.selectedIds,
    required this.onTap,
  });

  final List<UltrasoundModel> cards;

  final Set<String> selectedIds;

  final Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          UltrasoundCard(
            card: cards[i],
            selected: selectedIds.contains(cards[i].id),
            onTap: () => onTap(cards[i].id),
          ),

          if (i != cards.length - 1) const SizedBox(height: 22),
        ],
      ],
    );
  }
}
