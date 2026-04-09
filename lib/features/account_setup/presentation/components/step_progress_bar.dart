import 'package:flutter/material.dart';

import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';

class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        return Padding(
          padding: EdgeInsets.only(
            right: index < totalSteps - 1 ? AppSpacing.sm : 0,
          ),
          child: Container(
            width: AppSpacing.xxxl,
            height: 6,
            decoration: BoxDecoration(
              color: isActive
                  ? SemanticColors.interactivePrimary
                  : SemanticColors.borderSubtle,
            ),
          ),
        );
      }),
    );
  }
}
