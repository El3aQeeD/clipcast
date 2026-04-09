import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/cc_button.dart';
import '../../../../theme/tokens/components.dart';
import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import '../components/premium_feature_row.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SemanticColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.base,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/home'),
                    child: const Icon(
                      Icons.close,
                      color: SemanticColors.textSecondary,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'View Premium Plan',
                    style: AppTypography.titleLarge.copyWith(
                      color: SemanticColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    _PremiumCard(),
                    const SizedBox(height: AppSpacing.xxl),
                    CcButton(
                      label: 'Start 7-day free trial',
                      onPressed: () => context.go('/premium-welcome'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Then \$49/year. Cancel anytime.',
                      style: AppTypography.bodySmall.copyWith(
                        color: SemanticColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: SemanticColors.borderDefault),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.base,
                          ),
                          child: Text(
                            'Or',
                            style: AppTypography.bodySmall.copyWith(
                              color: SemanticColors.textSecondary,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: SemanticColors.borderDefault),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    CcButton(
                      label: 'Continue with Basic Plan',
                      variant: CcButtonVariant.secondary,
                      onPressed: () => context.go('/home'),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FooterLink(
                          text: 'Terms of Use',
                          onTap: () {},
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text(
                            '·',
                            style: AppTypography.bodySmall.copyWith(
                              color: SemanticColors.textSecondary,
                            ),
                          ),
                        ),
                        _FooterLink(
                          text: 'Restore Subscription',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: SemanticColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        border: Border.all(color: ComponentColors.premiumCardBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: ComponentColors.premiumGoldColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.xxl),
            ),
            child: Text(
              'PREMIUM',
              style: AppTypography.labelSmall.copyWith(
                color: ComponentColors.premiumGoldColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          RichText(
            text: TextSpan(
              style: AppTypography.displayLarge.copyWith(
                color: SemanticColors.textPrimary,
              ),
              children: [
                const TextSpan(text: '\$49'),
                TextSpan(
                  text: '/year',
                  style: AppTypography.bodyLarge.copyWith(
                    color: SemanticColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const PremiumFeatureRow(text: 'Unlimited AI-powered clip creation'),
          const PremiumFeatureRow(text: 'Advanced podcast recommendations'),
          const PremiumFeatureRow(text: 'Offline listening & downloads'),
          const PremiumFeatureRow(text: 'Ad-free experience'),
          const PremiumFeatureRow(text: 'Priority support'),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: SemanticColors.textSecondary,
          decoration: TextDecoration.underline,
          decorationColor: SemanticColors.textSecondary,
        ),
      ),
    );
  }
}
