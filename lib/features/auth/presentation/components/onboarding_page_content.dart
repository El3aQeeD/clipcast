import 'package:flutter/material.dart';

import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String illustrationAsset;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.illustrationAsset,
  });
}

class OnboardingPageContent extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPageContent({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xxl),
          Text(
            data.title,
            style: AppTypography.displayLarge.copyWith(
              color: SemanticColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            data.subtitle,
            style: AppTypography.bodyLarge.copyWith(
              color: SemanticColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Expanded(
            child: Center(
              child: Image.asset(
                data.illustrationAsset,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
