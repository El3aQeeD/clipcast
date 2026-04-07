import 'package:flutter/material.dart';

import '../../theme/tokens/components.dart';
import '../../theme/tokens/semantic.dart';
import '../../theme/tokens/spacing.dart';
import '../../theme/tokens/typography.dart';

enum CcButtonVariant { primary, secondary }

class CcButton extends StatelessWidget {
  const CcButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CcButtonVariant.primary,
    this.isLoading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final CcButtonVariant variant;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == CcButtonVariant.primary;

    return SizedBox(
      width: expand ? double.infinity : null,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? ComponentColors.buttonPrimaryBg
              : ComponentColors.buttonSecondaryBg,
          foregroundColor: isPrimary
              ? ComponentColors.buttonPrimaryText
              : ComponentColors.buttonSecondaryText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: isPrimary
                ? BorderSide.none
                : const BorderSide(color: ComponentColors.buttonSecondaryBorder),
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
                  color: SemanticColors.textPrimary,
                ),
              )
            : Text(label, style: AppTypography.titleMedium),
      ),
    );
  }
}
