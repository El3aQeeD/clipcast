import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/cc_button.dart';
import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';

class PremiumWelcomePage extends StatelessWidget {
  const PremiumWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SemanticColors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _CrownIcon(),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Welcome to\nClipCast Premium.',
                style: AppTypography.displaySmall.copyWith(
                  color: SemanticColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Enjoy unlimited AI-powered clips, advanced\nrecommendations, and an ad-free experience.',
                style: AppTypography.bodyMedium.copyWith(
                  color: SemanticColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              CcButton(
                label: 'Start Now',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _CrownIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SemanticColors.backgroundCard,
        border: Border.all(
          color: SemanticColors.borderDefault.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: SemanticColors.interactivePrimary.withValues(alpha: 0.1),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: SemanticColors.backgroundSecondary,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/premium_crown.png',
              width: 56,
              height: 56,
              errorBuilder: (_, _, _) => const Icon(
                Icons.workspace_premium,
                color: SemanticColors.premiumGold,
                size: 48,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
