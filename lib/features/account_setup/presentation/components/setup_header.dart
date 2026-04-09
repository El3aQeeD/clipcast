import 'package:flutter/material.dart';

import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import 'step_progress_bar.dart';

class SetupHeader extends StatelessWidget {
  const SetupHeader({
    super.key,
    required this.currentStep,
    required this.title,
    this.onBack,
  });

  final int currentStep;
  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Set Your Account',
              style: AppTypography.titleMedium.copyWith(
                color: SemanticColors.textSecondary,
              ),
            ),
            const Spacer(),
            if (onBack != null)
              GestureDetector(
                onTap: onBack,
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: SemanticColors.textSecondary,
                  size: 18,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        StepProgressBar(currentStep: currentStep),
        const SizedBox(height: AppSpacing.xl),
        Text(
          title,
          style: AppTypography.displayMedium.copyWith(
            color: SemanticColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
