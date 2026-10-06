import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';

class BookingProgress extends StatelessWidget {
  final int currentStep;
  final double indicatorWidth;
  final double indicatorHeight;
  final double iconSize;
  final double labelFontSize;
  final double horizontalPadding;
  final double verticalPadding;

  const BookingProgress({
    super.key,
    this.currentStep = 0,
    this.indicatorWidth = 38,
    this.indicatorHeight = 32,
    this.iconSize = 18,
    this.labelFontSize = 11,
    this.horizontalPadding = 14,
    this.verticalPadding = 6,
  });

  IconData _getIcon(int index) {
    switch (index) {
      case 1:
        return Icons.design_services_rounded; // Service
      case 2:
        return Icons.person_rounded; // Doctor
      case 3:
        return Icons.access_time_rounded; // Time
      case 4:
        return Icons.verified_rounded; // Confirm
      default:
        return Icons.circle;
    }
  }

  String _getTitle(int index) {
    switch (index) {
      case 1:
        return "Service";
      case 2:
        return "Doctor";
      case 3:
        return "Time";
      case 4:
        return "Confirm";
      default:
        return "";
    }
  }

  TextStyle _labelStyle(bool active) {
    return TextStyle(
      fontSize: labelFontSize,
      fontWeight: FontWeight.w600,

      color: active ? AppColors.primary : AppColors.grey,
    );
  }

  Widget step(int index, bool active) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            tween: Tween<double>(begin: 0.85, end: 1.0),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: active ? scale : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: indicatorWidth,
                  height: indicatorHeight,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: active
                        ? LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.75),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: active ? null : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: active
                            ? AppColors.primary.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.08),
                        blurRadius: active ? 14 : 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Icon(
                      _getIcon(index),
                      key: ValueKey(active),
                      size: iconSize,
                      color: active ? Colors.white : AppColors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 500),
            style: _labelStyle(active),
            child: Text(_getTitle(index), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget line(bool active) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        height: 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: active
              ? LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.8),
                    AppColors.primary.withValues(alpha: 0.2),
                  ],
                )
              : null,
          color: active ? null : AppColors.border,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Row(
        children: [
          step(1, currentStep >= 1),
          line(currentStep >= 2),
          step(2, currentStep >= 2),
          line(currentStep >= 3),
          step(3, currentStep >= 3),
          line(currentStep >= 4),
          step(4, currentStep >= 4),
        ],
      ),
    );
  }
}
