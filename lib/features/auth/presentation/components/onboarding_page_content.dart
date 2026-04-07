import 'package:flutter/material.dart';

import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import 'onboarding_progress_indicator.dart';

class OnboardingPageData {
  final String title;
  final String subtitle;
  final String illustrationAsset;
  final int activeIndex;

  const OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.illustrationAsset,
    required this.activeIndex,
  });
}

class OnboardingPageContent extends StatelessWidget {
  final OnboardingPageData data;
  final int currentPage;

  const OnboardingPageContent({
    super.key,
    required this.data,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OnboardingProgressIndicator(
            totalSteps: 4,
            activeStep: data.activeIndex,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Image.asset(
                  'assets/images/clipcast_icon.png',
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Welcome to ClipCast',
                style: AppTypography.bodyMedium.copyWith(
                  color: SemanticColors.textPrimary,
                ),
              ),
            ],
          ),
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
