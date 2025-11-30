import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../config/theme/design_system.dart';

/// Text field size variants
enum AppTextFieldSize {
  small,
  medium,
  large,
}

/// Customizable text field component using design system
class AppTextField extends StatelessWidget {
  const AppTextField({
    Key? key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.decoration,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.style,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onTap,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.enabled,
    this.cursorColor,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.autofocus = false,
    this.autovalidateMode,
    this.size = AppTextFieldSize.medium,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.filled = true,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool readOnly;
  final bool? showCursor;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final ValueChanged<String>? onChanged;
  final GestureTapCallback? onTap;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final Color? cursorColor;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final bool autofocus;
  final AutovalidateMode? autovalidateMode;
  final AppTextFieldSize size;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get text style based on size
    TextStyle textStyle;
    EdgeInsets contentPadding;

    switch (size) {
      case AppTextFieldSize.small:
        textStyle = AppTypography.bodySmall;
        contentPadding = AppSpacing.inputCompactPadding;
        break;
      case AppTextFieldSize.medium:
        textStyle = AppTypography.bodyMedium;
        contentPadding = AppSpacing.inputPadding;
        break;
      case AppTextFieldSize.large:
        textStyle = AppTypography.bodyLarge;
        contentPadding = AppSpacing.inputPadding.copyWith(
          top: AppSpacing.md,
          bottom: AppSpacing.md,
        );
        break;
    }

    final effectiveDecoration = (decoration ?? const InputDecoration()).copyWith(
      labelText: label,
      hintText: hint,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: filled,
      fillColor: filled
          ? theme.brightness == Brightness.light
              ? AppColors.gray100
              : AppColors.gray900
          : null,
      contentPadding: contentPadding,
      labelStyle: textStyle,
      hintStyle: textStyle.copyWith(
        color: theme.brightness == Brightness.light
            ? AppColors.lightTextHint
            : AppColors.darkTextHint,
      ),
      border: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSM,
        borderSide: filled ? BorderSide.none : const BorderSide(),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSM,
        borderSide: filled ? BorderSide.none : const BorderSide(),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSM,
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: AppSpacing.borderMedium,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSM,
        borderSide: const BorderSide(
          color: AppColors.error,
          width: AppSpacing.borderMedium,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusSM,
        borderSide: const BorderSide(
          color: AppColors.error,
          width: AppSpacing.borderMedium,
        ),
      ),
    );

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      decoration: effectiveDecoration,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      style: style ?? textStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      readOnly: readOnly,
      showCursor: showCursor,
      obscureText: obscureText,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      maxLengthEnforcement: maxLengthEnforcement,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      validator: validator,
      inputFormatters: inputFormatters,
      enabled: enabled,
      cursorColor: cursorColor ?? AppColors.primary,
      keyboardAppearance: keyboardAppearance,
      scrollPadding: scrollPadding,
      autofocus: autofocus,
      autovalidateMode: autovalidateMode,
    );
  }
}

/// Password text field with show/hide toggle
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    Key? key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.textInputAction,
    this.size = AppTextFieldSize.medium,
  }) : super(key: key);

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final AppTextFieldSize size;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      label: widget.label,
      hint: widget.hint,
      helperText: widget.helperText,
      errorText: widget.errorText,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      size: widget.size,
      keyboardType: TextInputType.visiblePassword,
      enableSuggestions: false,
      autocorrect: false,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: AppColors.gray600,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}
