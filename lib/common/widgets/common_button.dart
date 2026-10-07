import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'package:o2_clinic/common/widgets/common_loading_indicator.dart';

enum CommonButtonType { primary, secondary, outline, text, gradient }

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = CommonButtonType.primary,
    this.size = CommonButtonSize.medium,
    this.icon,
    this.customIconWidget,
    this.iconSize,
    this.iconColor,
    this.iconPosition = IconPosition.left,
    this.isLoading = false,
    this.disabled = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.gradient,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.width,
    this.height,
    this.shadow,
    this.elevation,
  });

  final String text;
  final VoidCallback? onPressed;
  final CommonButtonType type;
  final CommonButtonSize size;
  final IconData? icon;
  final Widget? customIconWidget;
  final double? iconSize;
  final Color? iconColor;
  final IconPosition iconPosition;
  final bool isLoading;
  final bool disabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double borderWidth;
  final Gradient? gradient;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final TextStyle? textStyle;
  final double? width;
  final double? height;
  final BoxShadow? shadow;
  final double? elevation;

  bool get isDisabled => disabled || isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    final buttonPadding = padding ?? _getDefaultPadding();
    final buttonTextStyle = textStyle ?? _getDefaultTextStyle();

    Widget buttonChild = _buildButtonContent(buttonTextStyle);

    if (isLoading) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CommonLoadingIndicator(
              strokeWidth: 2,
              color: _getLoadingColor(),
            ),
          ),
          if (text.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(text, style: buttonTextStyle),
          ],
        ],
      );
    }

    switch (type) {
      case CommonButtonType.text:
        return TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: TextButton.styleFrom(
            padding: buttonPadding,
            minimumSize: Size(width ?? 0, height ?? _getDefaultHeight()),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: buttonChild,
        );

      case CommonButtonType.outline:
        return OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: buttonPadding,
            minimumSize: Size(width ?? 0, height ?? _getDefaultHeight()),
            side: BorderSide(
              color: borderColor ?? _getDefaultBorderColor(),
              width: borderWidth,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? _getDefaultBorderRadius(),
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: buttonChild,
        );

      default:
        return ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? _getDefaultBackgroundColor(),
            foregroundColor: foregroundColor ?? _getDefaultForegroundColor(),
            padding: buttonPadding,
            minimumSize: Size(width ?? 0, height ?? _getDefaultHeight()),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? _getDefaultBorderRadius(),
            ),
            elevation: elevation ?? _getDefaultElevation(),
            shadowColor: shadow?.color,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: buttonChild,
        );
    }
  }

  Widget _buildButtonContent(TextStyle textStyle) {
    if (icon == null && customIconWidget == null) {
      return Text(text, style: textStyle);
    }

    final Widget iconWidget = customIconWidget ?? Icon(
      icon,
      size: iconSize ?? textStyle.fontSize ?? 14,
      color: iconColor ?? textStyle.color,
    );

    if (text.isEmpty) {
      return iconWidget;
    }

    switch (iconPosition) {
      case IconPosition.left:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Flexible(child: Text(text, style: textStyle)),
          ],
        );
      case IconPosition.right:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(text, style: textStyle)),
            const SizedBox(width: 8),
            iconWidget,
          ],
        );
      case IconPosition.top:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(height: 4),
            Text(text, style: textStyle),
          ],
        );
      case IconPosition.bottom:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: textStyle),
            const SizedBox(height: 4),
            iconWidget,
          ],
        );
    }
  }

  Color _getDefaultBackgroundColor() {
    switch (type) {
      case CommonButtonType.primary:
        return AppColors.primary;
      case CommonButtonType.secondary:
        return AppColors.secondary;
      case CommonButtonType.outline:
      case CommonButtonType.text:
        return AppColors.transparent;
      case CommonButtonType.gradient:
        return AppColors.transparent;
    }
  }

  Color _getDefaultForegroundColor() {
    switch (type) {
      case CommonButtonType.primary:
      case CommonButtonType.secondary:
      case CommonButtonType.gradient:
        return AppColors.white;
      case CommonButtonType.outline:
      case CommonButtonType.text:
        return AppColors.primary;
    }
  }

  Color _getDefaultBorderColor() {
    return AppColors.primary;
  }

  BorderRadius _getDefaultBorderRadius() {
    switch (size) {
      case CommonButtonSize.small:
        return BorderRadius.circular(12);
      case CommonButtonSize.medium:
        return BorderRadius.circular(14);
      case CommonButtonSize.large:
        return BorderRadius.circular(16);
      case CommonButtonSize.extraLarge:
        return BorderRadius.circular(18);
    }
  }

  EdgeInsets _getDefaultPadding() {
    switch (size) {
      case CommonButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case CommonButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 10);
      case CommonButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case CommonButtonSize.extraLarge:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
    }
  }

  double _getDefaultHeight() {
    switch (size) {
      case CommonButtonSize.small:
        return 32;
      case CommonButtonSize.medium:
        return 40;
      case CommonButtonSize.large:
        return 48;
      case CommonButtonSize.extraLarge:
        return 56;
    }
  }

  TextStyle _getDefaultTextStyle() {
    final fontSize = _getDefaultFontSize();
    final fontWeight = _getDefaultFontWeight();
    final color = isDisabled
        ? AppColors.grey
        : (foregroundColor ?? _getDefaultForegroundColor());

    return TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color);
  }

  double _getDefaultFontSize() {
    switch (size) {
      case CommonButtonSize.small:
        return 11;
      case CommonButtonSize.medium:
        return 12;
      case CommonButtonSize.large:
        return 14;
      case CommonButtonSize.extraLarge:
        return 16;
    }
  }

  FontWeight _getDefaultFontWeight() {
    return FontWeight.w800;
  }

  double _getDefaultElevation() {
    switch (type) {
      case CommonButtonType.primary:
      case CommonButtonType.secondary:
        return 0;
      case CommonButtonType.gradient:
        return 0;
      case CommonButtonType.outline:
      case CommonButtonType.text:
        return 0;
    }
  }

  Color _getLoadingColor() {
    return foregroundColor ?? _getDefaultForegroundColor();
  }
}

enum CommonButtonSize { small, medium, large, extraLarge }

enum IconPosition { left, right, top, bottom }
