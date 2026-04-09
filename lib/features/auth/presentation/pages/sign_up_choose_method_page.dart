import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/cc_button.dart';
import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import '../components/auth_icons.dart';
import '../components/sign_up_header.dart';

class SignUpChooseMethodPage extends StatelessWidget {
  const SignUpChooseMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLogin = GoRouterState.of(context).extra as bool? ?? false;

    return Scaffold(
      backgroundColor: SemanticColors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              // Header with back button and logo
              SignUpHeader(onBack: () => context.go('/onboarding')),
              const SizedBox(height: AppSpacing.xxxl + AppSpacing.xxl),
              // Title
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLogin
                          ? 'Sign in to ClipCast'
                          : 'Sign Up to start\nclipping',
                      style: AppTypography.displayMedium.copyWith(
                        color: SemanticColors.textPrimary,
                      ),
                    ),
                    if (isLogin) ...[
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Welcome back! Enter your details below.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: SemanticColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Continue with Email
              CcButton(
                label: 'Continue with Email',
                onPressed: () => context.push('/sign-up', extra: isLogin),
                icon: Icon(
                  AuthIcons.mail,
                  size: 18,
                  color: SemanticColors.textOnPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg - 2),
              // Continue with Google
              CcButton(
                label: 'Continue with Google',
                variant: CcButtonVariant.tertiary,
                onPressed: () {
                  // TODO: Google sign-in
                },
                icon: const Icon(
                  AuthIcons.google,
                  size: 18,
                  color: SemanticColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg - 2),
              // Continue with Apple
              CcButton(
                label: 'Continue with Apple',
                variant: CcButtonVariant.tertiary,
                onPressed: () {
                  // TODO: Apple sign-in
                },
                icon: const Icon(
                  AuthIcons.appleIcon,
                  size: 18,
                  color: SemanticColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Bottom text
              _BottomLink(
                text: isLogin
                    ? "Don't have an account? "
                    : 'Already have an account? ',
                linkText: isLogin ? 'Sign up' : 'Log In',
                onTap: () =>
                    context.go('/sign-up-method', extra: !isLogin),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomLink extends StatelessWidget {
  const _BottomLink({
    required this.text,
    required this.linkText,
    required this.onTap,
  });

  final String text;
  final String linkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: AppTypography.bodyMedium.copyWith(
            color: SemanticColors.textSecondary,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: AppTypography.bodyMedium.copyWith(
              color: SemanticColors.interactivePrimary,
              decoration: TextDecoration.underline,
              decorationColor: SemanticColors.interactivePrimary,
            ),
          ),
        ),
      ],
    );
  }
}
