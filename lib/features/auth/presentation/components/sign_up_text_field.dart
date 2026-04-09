import 'package:flutter/material.dart';

import '../../../../theme/tokens/components.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';

/// White-background text field used on sign-up screens.
///
/// Shows a cyan border when [isValid] is `true`, otherwise a subtle border.
class SignUpTextField extends StatelessWidget {
  const SignUpTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.focusNode,
    this.keyboardType,
    this.obscureText = false,
    this.isValid = false,
    this.suffixIcon,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool isValid;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: AppTypography.bodyLarge.copyWith(
        color: ComponentColors.inputLightText,
      ),
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        filled: true,
        fillColor: ComponentColors.inputLightBg,
        hintText: hintText,
        hintStyle: AppTypography.bodyLarge.copyWith(
          color: ComponentColors.inputLightPlaceholder,
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minHeight: 24,
          minWidth: 24,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md + 2,
        ),
        border: _border(ComponentColors.inputLightBorder),
        enabledBorder: _border(
          isValid
              ? ComponentColors.inputLightBorderFocused
              : ComponentColors.inputLightBorder,
        ),
        focusedBorder: _border(ComponentColors.inputLightBorderFocused),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.md),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }
}
