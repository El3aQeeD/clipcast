import 'package:flutter/material.dart';

import '../../theme/tokens/components.dart';
import '../../theme/tokens/semantic.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/tokens/typography.dart';

enum CcButtonVariant { primary, secondary, tertiary, disabled }

class CcButton extends StatelessWidget {
  const CcButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CcButtonVariant.primary,
    this.isLoading = false,
    this.expand = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final CcButtonVariant variant;
  final bool isLoading;
  final bool expand;
  final Widget? icon;

  bool get _isDisabled =>
      variant == CcButtonVariant.disabled || isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expand ? double.infinity : null,
      height: 48,
      child: _buildButton(),
    );
  }

  Widget _buildButton() {
    switch (variant) {
      case CcButtonVariant.primary:
        return _PrimaryButton(
          label: label,
          onPressed: _isDisabled ? null : onPressed,
          isLoading: isLoading,
          icon: icon,
        );
      case CcButtonVariant.secondary:
        return _SecondaryButton(
          label: label,
          onPressed: _isDisabled ? null : onPressed,
          isLoading: isLoading,
          icon: icon,
        );
      case CcButtonVariant.tertiary:
        return _TertiaryButton(
          label: label,
          onPressed: _isDisabled ? null : onPressed,
          isLoading: isLoading,
          icon: icon,
        );
      case CcButtonVariant.disabled:
        return _DisabledButton(label: label, icon: icon);
    }
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: ComponentColors.buttonPrimaryBg,
        foregroundColor: ComponentColors.buttonPrimaryText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: ComponentColors.buttonPrimaryText,
              ),
            )
          : _ButtonContent(label: label, icon: icon),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: ComponentColors.buttonSecondaryBg,
        foregroundColor: ComponentColors.buttonSecondaryText,
        side: const BorderSide(color: ComponentColors.buttonSecondaryBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: SemanticColors.textPrimary,
              ),
            )
          : _ButtonContent(
              label: label,
              icon: icon,
              textColor: ComponentColors.buttonSecondaryText,
            ),
    );
  }
}

class _TertiaryButton extends StatelessWidget {
  const _TertiaryButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: SemanticColors.textPrimary,
        side: const BorderSide(color: ComponentColors.buttonSecondaryBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: SemanticColors.textPrimary,
              ),
            )
          : _ButtonContent(
              label: label,
              icon: icon,
              textColor: SemanticColors.textPrimary,
            ),
    );
  }
}

class _DisabledButton extends StatelessWidget {
  const _DisabledButton({required this.label, this.icon});

  final String label;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ComponentColors.buttonDisabledBg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      alignment: Alignment.center,
      child: _ButtonContent(
        label: label,
        icon: icon,
        textColor: ComponentColors.buttonDisabledText,
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    this.icon,
    this.textColor,
  });

  final String label;
  final Widget? icon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: AppSpacing.sm + 2),
        ],
        Text(
          label,
          style: AppTypography.button.copyWith(color: textColor),
        ),
      ],
    );
  }
}
