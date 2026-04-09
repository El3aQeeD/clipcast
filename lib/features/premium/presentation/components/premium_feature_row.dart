import 'package:flutter/material.dart';

import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';

class PremiumFeatureRow extends StatelessWidget {
  const PremiumFeatureRow({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: SemanticColors.interactivePrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: SemanticColors.textOnPrimary,
              size: 12,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: SemanticColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
