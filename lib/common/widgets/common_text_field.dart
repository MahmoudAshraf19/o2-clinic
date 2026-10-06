import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart'; // Added import for DragStartBehavior

import '../../core/theme/app_colors.dart';

enum CommonTextFieldType {
  text,
  email,
  password,
  number,
  phone,
  search,
  multiline,
}

enum CommonTextFieldSize { small, medium, large }

class CommonTextField extends StatefulWidget {
  const CommonTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.type = CommonTextFieldType.text,
    this.size = CommonTextFieldSize.medium,
    this.label,
    this.hint,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.helperText,
    this.counterText,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.textAlign,
    this.textAlignVertical,
    this.textCapitalization,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.prefixStyle,
    this.suffixStyle,
    this.errorStyle,
    this.helperStyle,
    this.counterStyle,
    this.fillColor,
    this.borderColor,
    this.focusBorderColor,
    this.errorBorderColor,
    this.disabledBorderColor,
    this.focusedColor,
    this.hoverColor,
    this.borderRadius,
    this.contentPadding,
    this.filled = true,
    this.dense = false,
    this.showBorder = true,
    this.showCursor = true,
    this.cursorColor,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.scrollPadding,
    this.enableInteractiveSelection = true,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.expands = false,
    this.strutStyle,
    this.textDirection,
    this.dragStartBehavior = DragStartBehavior.start,
    this.mouseCursor,
    this.restorationId,
    this.scribbleEnabled = true,
    this.enableIMEPersonalizedLearning = true,
    this.canRequestFocus = true,
    this.spellCheckConfiguration,
    this.magnifierConfiguration,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final CommonTextFieldType type;
  final CommonTextFieldSize size;
  final String? label;
  final String? hint;
  final String? prefix;
  final String? suffix;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? errorText;
  final String? helperText;
  final String? counterText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextCapitalization? textCapitalization;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? prefixStyle;
  final TextStyle? suffixStyle;
  final TextStyle? errorStyle;
  final TextStyle? helperStyle;
  final TextStyle? counterStyle;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusBorderColor;
  final Color? errorBorderColor;
  final Color? disabledBorderColor;
  final Color? focusedColor;
  final Color? hoverColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? contentPadding;
  final bool filled;
  final bool dense;
  final bool showBorder;
  final bool showCursor;
  final Color? cursorColor;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final EdgeInsets? scrollPadding;
  final bool enableInteractiveSelection;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final bool expands;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final DragStartBehavior dragStartBehavior;
  final MouseCursor? mouseCursor;
  final String? restorationId;
  final bool scribbleEnabled;
  final bool enableIMEPersonalizedLearning;
  final bool canRequestFocus;
  final SpellCheckConfiguration? spellCheckConfiguration;
  final TextMagnifierConfiguration? magnifierConfiguration;

  @override
  State<CommonTextField> createState() => _CommonTextFieldState();
}

class _CommonTextFieldState extends State<CommonTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: widget.labelStyle ?? _getLabelStyle()),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          textInputAction: widget.textInputAction,
          keyboardType: _getKeyboardType(),
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          onEditingComplete: widget.onEditingComplete,
          inputFormatters: widget.inputFormatters ?? _getInputFormatters(),
          maxLength: widget.maxLength,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          textAlign: widget.textAlign ?? TextAlign.start,
          textAlignVertical: widget.textAlignVertical,
          textCapitalization:
              widget.textCapitalization ?? TextCapitalization.sentences,
          style: widget.style ?? _getTextStyle(),
          cursorColor: widget.cursorColor ?? AppColors.primary,
          cursorWidth: widget.cursorWidth,
          cursorHeight: widget.cursorHeight,
          cursorRadius: widget.cursorRadius ?? const Radius.circular(2),
          scrollPadding: widget.scrollPadding ?? const EdgeInsets.all(20.0),
          enableInteractiveSelection: widget.enableInteractiveSelection,
          autocorrect: widget.autocorrect,
          smartDashesType: widget.smartDashesType,
          smartQuotesType: widget.smartQuotesType,
          enableSuggestions: widget.enableSuggestions,
          expands: widget.expands,
          strutStyle: widget.strutStyle,
          textDirection: widget.textDirection,
          dragStartBehavior: widget.dragStartBehavior,
          mouseCursor: widget.mouseCursor,
          restorationId: widget.restorationId,
          scribbleEnabled: widget.scribbleEnabled,
          enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning,
          canRequestFocus: widget.canRequestFocus,
          spellCheckConfiguration: widget.spellCheckConfiguration,
          magnifierConfiguration: widget.magnifierConfiguration,
          decoration: _getInputDecoration(),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(widget.errorText!, style: widget.errorStyle ?? _getErrorStyle()),
        ],
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: widget.helperStyle ?? _getHelperStyle(),
          ),
        ],
      ],
    );
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
      hintText: widget.hint,
      hintStyle: widget.hintStyle ?? _getHintStyle(),
      prefixText: widget.prefix,
      suffixText: widget.suffix,
      prefixStyle: widget.prefixStyle,
      suffixStyle: widget.suffixStyle,
      prefixIcon: widget.prefixIcon != null
          ? Icon(
              widget.prefixIcon,
              color: _getIconColor(),
              size: _getIconSize(),
            )
          : null,
      suffixIcon: _buildSuffixIcon(),
      counterText: widget.counterText,
      counterStyle: widget.counterStyle,
      filled: widget.filled,
      fillColor: widget.fillColor ?? _getFillColor(),
      contentPadding: widget.contentPadding ?? _getContentPadding(),
      border: widget.showBorder ? _getInputBorder() : InputBorder.none,
      enabledBorder: widget.showBorder ? _getEnabledBorder() : InputBorder.none,
      focusedBorder: widget.showBorder ? _getFocusedBorder() : InputBorder.none,
      errorBorder: widget.showBorder ? _getErrorBorder() : InputBorder.none,
      focusedErrorBorder: widget.showBorder
          ? _getFocusedErrorBorder()
          : InputBorder.none,
      disabledBorder: widget.showBorder
          ? _getDisabledBorder()
          : InputBorder.none,
      isDense: widget.dense,
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.suffixIcon != null) {
      return Icon(
        widget.suffixIcon,
        color: _getIconColor(),
        size: _getIconSize(),
      );
    }

    if (widget.type == CommonTextFieldType.password) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: _getIconColor(),
          size: _getIconSize(),
        ),
        onPressed: _toggleObscureText,
      );
    }

    return null;
  }

  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case CommonTextFieldType.email:
        return TextInputType.emailAddress;
      case CommonTextFieldType.phone:
        return TextInputType.phone;
      case CommonTextFieldType.number:
        return TextInputType.number;
      case CommonTextFieldType.multiline:
        return TextInputType.multiline;
      default:
        return widget.keyboardType ?? TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    switch (widget.type) {
      case CommonTextFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case CommonTextFieldType.phone:
        return [FilteringTextInputFormatter.digitsOnly];
      default:
        return [];
    }
  }

  TextStyle _getTextStyle() {
    final fontSize = _getFontSize();
    final fontWeight = _getFontWeight();
    final color = widget.enabled ? AppColors.black : AppColors.grey;

    return TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color);
  }

  TextStyle _getLabelStyle() {
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,

      color: AppColors.black,
    );
  }

  TextStyle _getHintStyle() {
    return const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,

      color: Color(0xFF9CA3AF),
    );
  }

  TextStyle _getErrorStyle() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,

      color: Color(0xFFEF4444),
    );
  }

  TextStyle _getHelperStyle() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,

      color: Color(0xFF6B7280),
    );
  }

  double _getFontSize() {
    switch (widget.size) {
      case CommonTextFieldSize.small:
        return 12;
      case CommonTextFieldSize.medium:
        return 14;
      case CommonTextFieldSize.large:
        return 16;
    }
  }

  FontWeight _getFontWeight() {
    switch (widget.size) {
      case CommonTextFieldSize.small:
        return FontWeight.w500;
      case CommonTextFieldSize.medium:
        return FontWeight.w600;
      case CommonTextFieldSize.large:
        return FontWeight.w700;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case CommonTextFieldSize.small:
        return 18;
      case CommonTextFieldSize.medium:
        return 20;
      case CommonTextFieldSize.large:
        return 24;
    }
  }

  Color _getIconColor() {
    if (!widget.enabled) return AppColors.grey;
    if (widget.errorText != null) return const Color(0xFFEF4444);
    return _isFocused ? AppColors.primary : const Color(0xFF6E7977);
  }

  Color _getFillColor() {
    if (!widget.enabled) return AppColors.lightGrey;
    if (_isFocused) return AppColors.white;
    return AppColors.cardBackground;
  }

  EdgeInsets _getContentPadding() {
    switch (widget.size) {
      case CommonTextFieldSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case CommonTextFieldSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case CommonTextFieldSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  BorderRadius _getBorderRadius() {
    switch (widget.size) {
      case CommonTextFieldSize.small:
        return BorderRadius.circular(12);
      case CommonTextFieldSize.medium:
        return BorderRadius.circular(16);
      case CommonTextFieldSize.large:
        return BorderRadius.circular(20);
    }
  }

  InputBorder _getInputBorder() {
    return OutlineInputBorder(
      borderRadius: widget.borderRadius ?? _getBorderRadius(),
      borderSide: BorderSide(
        color: widget.borderColor ?? AppColors.border,
        width: 1,
      ),
    );
  }

  InputBorder _getEnabledBorder() {
    return OutlineInputBorder(
      borderRadius: widget.borderRadius ?? _getBorderRadius(),
      borderSide: BorderSide(
        color: widget.borderColor ?? AppColors.border,
        width: 1,
      ),
    );
  }

  InputBorder _getFocusedBorder() {
    return OutlineInputBorder(
      borderRadius: widget.borderRadius ?? _getBorderRadius(),
      borderSide: BorderSide(
        color: widget.focusBorderColor ?? AppColors.primary,
        width: 2,
      ),
    );
  }

  InputBorder _getErrorBorder() {
    return OutlineInputBorder(
      borderRadius: widget.borderRadius ?? _getBorderRadius(),
      borderSide: BorderSide(
        color: widget.errorBorderColor ?? const Color(0xFFEF4444),
        width: 1,
      ),
    );
  }

  InputBorder _getFocusedErrorBorder() {
    return OutlineInputBorder(
      borderRadius: widget.borderRadius ?? _getBorderRadius(),
      borderSide: BorderSide(
        color: widget.errorBorderColor ?? const Color(0xFFEF4444),
        width: 2,
      ),
    );
  }

  InputBorder _getDisabledBorder() {
    return OutlineInputBorder(
      borderRadius: widget.borderRadius ?? _getBorderRadius(),
      borderSide: BorderSide(
        color: widget.disabledBorderColor ?? AppColors.border,
        width: 1,
      ),
    );
  }
}
