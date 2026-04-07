import 'package:flutter/material.dart';

import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int activeStep;

  const OnboardingProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.activeStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        return Padding(
          padding: EdgeInsets.only(
            right: index < totalSteps - 1 ? AppSpacing.sm : 0,
          ),
          child: Container(
            width: AppSpacing.xxxl,
            height: 6,
            decoration: BoxDecoration(
              color: index == activeStep
                  ? SemanticColors.interactivePrimary
                  : SemanticColors.borderSubtle,
            ),
          ),
        );
      }),
    );
  }
}
