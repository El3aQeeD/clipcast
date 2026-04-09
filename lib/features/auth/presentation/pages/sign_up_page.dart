import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/utils/input_validators.dart';
import '../../../../shared/widgets/cc_button.dart';
import '../../../../theme/tokens/components.dart';
import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import '../components/auth_icons.dart';
import '../components/sign_up_header.dart';
import '../components/sign_up_text_field.dart';
import '../controller/auth_controller.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  late bool _isLogin;

  bool get _isValid =>
      _emailController.text.isNotEmpty &&
      InputValidators.isEmailValid(_emailController.text);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isLogin = GoRouterState.of(context).extra as bool? ?? false;
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_isValid) return;
    context.read<AuthController>().setEmail(_emailController.text.trim());
    context.push('/sign-up/password', extra: _isLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SemanticColors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              SignUpHeader(
                onBack: () => context.pop(),
                title: _isLogin ? 'Sign In' : 'Sign Up',
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xxxl),
                      Text(
                        _isLogin
                            ? 'Enter Your Email'
                            : "What's your email?",
                        style: AppTypography.displayMedium.copyWith(
                          color: SemanticColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SignUpTextField(
                        controller: _emailController,
                        hintText: 'Enter Your Email',
                        keyboardType: TextInputType.emailAddress,
                        isValid: _isValid,
                        suffixIcon: _isValid
                            ? const Icon(
                                AuthIcons.correctCheckMark,
                                color: ComponentColors.inputValidCheckmark,
                                size: 24,
                              )
                            : null,
                        onSubmitted: (_) => _continue(),
                      ),
                      const SizedBox(height: AppSpacing.xxxl + AppSpacing.md),
                      CcButton(
                        label: 'Continue',
                        onPressed: _isValid ? _continue : null,
                        variant: _isValid
                            ? CcButtonVariant.primary
                            : CcButtonVariant.disabled,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
              _BottomLink(
                text: _isLogin
                    ? "Don't have an account? "
                    : 'Already have an account? ',
                linkText: _isLogin ? 'Sign up' : 'Log In',
                onTap: () =>
                    context.go('/sign-up-method', extra: !_isLogin),
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
