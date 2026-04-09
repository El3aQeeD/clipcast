import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/auth_error_codes.dart';
import '../../../../shared/utils/input_validators.dart';
import '../../../../shared/widgets/cc_button.dart';
import '../../../../shared/widgets/cc_snackbar.dart';
import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import '../components/auth_icons.dart';
import '../components/password_criteria.dart';
import '../components/sign_up_header.dart';
import '../components/sign_up_text_field.dart';
import '../controller/auth_controller.dart';
import '../controller/auth_state.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late bool _isLogin;

  bool get _hasMinLength =>
      InputValidators.hasMinLength(_passwordController.text);

  bool get _hasNumberOrSpecial =>
      InputValidators.hasNumberOrSpecial(_passwordController.text);

  bool get _isValid =>
      _isLogin ? _passwordController.text.isNotEmpty : _hasMinLength && _hasNumberOrSpecial;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isLogin = GoRouterState.of(context).extra as bool? ?? false;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_isValid) return;
    final email = context.read<AuthController>().state.email;
    if (email == null) return;
    if (_isLogin) {
      context.read<AuthController>().signIn(
            email: email,
            password: _passwordController.text,
          );
    } else {
      context.read<AuthController>().signUp(
            email: email,
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthController, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.signUpSuccess) {
          context.push('/sign-up/otp');
        } else if (state.status == AuthStatus.signInSuccess) {
          context.go('/home');
        } else if (state.status == AuthStatus.error) {
          final code = state.errorCode;
          if (code == AuthErrorCode.userAlreadyExists ||
              code == AuthErrorCode.emailExists) {
            CcSnackbar.error(
              context,
              state.errorMessage ?? code!.userMessage,
            );
          } else if (state.errorMessage != null) {
            CcSnackbar.error(context, state.errorMessage!);
          }
          context.read<AuthController>().clearError();
        }
      },
      child: Scaffold(
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
                              ? 'Enter Your Password'
                              : 'Create a password',
                          style: AppTypography.displayMedium.copyWith(
                            color: SemanticColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        SignUpTextField(
                          controller: _passwordController,
                          hintText: 'Enter Password',
                          obscureText: _obscurePassword,
                          isValid: _isValid,
                          suffixIcon: GestureDetector(
                            onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            child: Icon(
                              AuthIcons.removeRedEye,
                              color: _obscurePassword
                                  ? SemanticColors.textSecondary
                                  : SemanticColors.interactivePrimary,
                              size: 26,
                            ),
                          ),
                        ),
                        if (_isLogin) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                // TODO: Navigate to forgot password
                              },
                              child: Text(
                                'Forgot password?',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: SemanticColors.textSecondary,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      SemanticColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (!_isLogin &&
                            _passwordController.text.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Your password must be at least 8 characters long.',
                            style: AppTypography.bodySmall.copyWith(
                              color: SemanticColors.textSecondary,
                            ),
                          ),
                        ],
                        if (!_isLogin) ...[
                          const SizedBox(height: AppSpacing.xl),
                          PasswordCriteria(
                            label: 'At least 8 characters',
                            isMet: _hasMinLength,
                            isActive: _passwordController.text.isNotEmpty,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          PasswordCriteria(
                            label: 'Contains a number or special character',
                            isMet: _hasNumberOrSpecial,
                            isActive: _passwordController.text.isNotEmpty,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xxxl + AppSpacing.md),
                        BlocBuilder<AuthController, AuthState>(
                          builder: (context, state) {
                            final isLoading =
                                state.status == AuthStatus.loading;
                            return CcButton(
                              label: _isLogin ? 'Sign In' : 'Continue',
                              onPressed: _isValid ? _submit : null,
                              variant: _isValid
                                  ? CcButtonVariant.primary
                                  : CcButtonVariant.disabled,
                              isLoading: isLoading,
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
                if (_isLogin) ...[
                  _BottomLink(
                    text: "Don't have an account? ",
                    linkText: 'Sign up',
                    onTap: () =>
                        context.go('/sign-up-method', extra: false),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ],
            ),
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
