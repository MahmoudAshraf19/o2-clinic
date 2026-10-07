import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum CommonDropdownSize { small, medium, large }

class CommonDropdown<T> extends StatefulWidget {
  const CommonDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.hint,
    this.label,
    this.size = CommonDropdownSize.medium,
    this.enabled = true,
    this.errorText,
    this.prefixIcon,
    this.borderColor,
    this.focusBorderColor,
    this.borderRadius,
    this.fillColor,
    this.dropdownColor,
    this.icon,
    this.iconColor,
    this.textStyle,
    this.isExpanded = false,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?)? onChanged;
  final String? hint;
  final String? label;
  final CommonDropdownSize size;
  final bool enabled;
  final String? errorText;
  final IconData? prefixIcon;
  final Color? borderColor;
  final Color? focusBorderColor;
  final BorderRadius? borderRadius;
  final Color? fillColor;
  final Color? dropdownColor;
  final Widget? icon;
  final Color? iconColor;
  final TextStyle? textStyle;
  final bool isExpanded;

  @override
  State<CommonDropdown<T>> createState() => _CommonDropdownState<T>();
}

class _CommonDropdownState<T> extends State<CommonDropdown<T>> {
  bool _isFocused = false;

  TextStyle _getLabelStyle() {
    return TextStyle(
      fontSize: _getFontSize(),
      fontWeight: _getFontWeight(),
      color: widget.errorText != null ? AppColors.colorFFEF4444 : (_isFocused ? AppColors.primary : AppColors.grey),
    );
  }

  TextStyle _getTextStyle() {
    return TextStyle(
      fontSize: _getFontSize(),
      fontWeight: _getFontWeight(),
      color: widget.enabled ? AppColors.textPrimary : AppColors.disabled,
    );
  }

  double _getFontSize() {
    switch (widget.size) {
      case CommonDropdownSize.small:
        return 12;
      case CommonDropdownSize.medium:
        return 14;
      case CommonDropdownSize.large:
        return 16;
    }
  }

  FontWeight _getFontWeight() {
    switch (widget.size) {
      case CommonDropdownSize.small:
        return FontWeight.w500;
      case CommonDropdownSize.medium:
        return FontWeight.w600;
      case CommonDropdownSize.large:
        return FontWeight.w700;
    }
  }

  Color _getFillColor() {
    if (widget.fillColor != null) return widget.fillColor!;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (!widget.enabled) {
      return isDark ? AppColors.colorFF333333 : AppColors.lightGrey;
    }
    if (_isFocused) return Theme.of(context).cardColor;
    return isDark ? AppColors.colorFF1E1E1E : AppColors.cardBackground;
  }

  EdgeInsets _getContentPadding() {
    switch (widget.size) {
      case CommonDropdownSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case CommonDropdownSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case CommonDropdownSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  BorderRadius _getBorderRadius() {
    if (widget.borderRadius != null) return widget.borderRadius!;
    switch (widget.size) {
      case CommonDropdownSize.small:
        return BorderRadius.circular(12);
      case CommonDropdownSize.medium:
        return BorderRadius.circular(16);
      case CommonDropdownSize.large:
        return BorderRadius.circular(20);
    }
  }

  InputBorder _getInputBorder() {
    return OutlineInputBorder(
      borderRadius: _getBorderRadius(),
      borderSide: BorderSide(
        color: widget.borderColor ?? AppColors.border,
        width: 1,
      ),
    );
  }

  InputBorder _getFocusedBorder() {
    return OutlineInputBorder(
      borderRadius: _getBorderRadius(),
      borderSide: BorderSide(
        color: widget.focusBorderColor ?? AppColors.primary,
        width: 2,
      ),
    );
  }

  InputBorder _getErrorBorder() {
    return OutlineInputBorder(
      borderRadius: _getBorderRadius(),
      borderSide: const BorderSide(
        color: AppColors.colorFFEF4444,
        width: 1,
      ),
    );
  }

  InputBorder _getFocusedErrorBorder() {
    return OutlineInputBorder(
      borderRadius: _getBorderRadius(),
      borderSide: const BorderSide(
        color: AppColors.colorFFEF4444,
        width: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: _getLabelStyle(),
          ),
          const SizedBox(height: 8),
        ],
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: DropdownButtonFormField<T>(
            initialValue: widget.value, // Keep using value for DropdownButtonFormField or change to initialValue? DropdownButtonFormField uses value as well? Ah wait, DropdownButtonFormField uses initialValue or value depending on use. value is actually fine, but the analyzer said "Use initialValue instead. This feature was deprecated after v3.33.0-1.0.pre."
            items: widget.items,
            onChanged: widget.enabled ? widget.onChanged : null,
            style: _getTextStyle(),
            dropdownColor: _getFillColor(),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: widget.enabled ? AppColors.grey : AppColors.disabled,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                fontSize: _getFontSize(),
                color: AppColors.grey,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: _getFontSize() + 4,
                      color: widget.errorText != null
                          ? AppColors.colorFFEF4444
                          : (_isFocused ? AppColors.primary : AppColors.grey),
                    )
                  : null,
              filled: true,
              fillColor: _getFillColor(),
              contentPadding: _getContentPadding(),
              border: _getInputBorder(),
              enabledBorder: _getInputBorder(),
              focusedBorder: _getFocusedBorder(),
              errorBorder: _getErrorBorder(),
              focusedErrorBorder: _getFocusedErrorBorder(),
              disabledBorder: _getInputBorder(),
              errorText: widget.errorText,
            ),
          ),
        ),
      ],
    );
  }
}
