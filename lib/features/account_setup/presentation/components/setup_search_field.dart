import 'package:flutter/material.dart';

import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';

class SetupSearchField extends StatelessWidget {
  const SetupSearchField({
    super.key,
    required this.onChanged,
    this.hintText = 'Search',
  });

  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: AppTypography.bodyMedium.copyWith(
        color: SemanticColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: SemanticColors.textSecondary,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: SemanticColors.textSecondary,
          size: 24,
        ),
        filled: true,
        fillColor: SemanticColors.backgroundSecondary,
        contentPadding: const EdgeInsets.all(AppSpacing.base),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: SemanticColors.textPrimary.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: SemanticColors.textPrimary.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(
            color: SemanticColors.interactivePrimary,
          ),
        ),
      ),
    );
  }
}
