import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/cc_button.dart';
import '../../../../shared/widgets/cc_snackbar.dart';
import '../../../../theme/tokens/components.dart';
import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import '../components/auth_icons.dart';
import '../components/sign_up_header.dart';
import '../controller/auth_controller.dart';
import '../controller/auth_state.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String get _otp => _controllers.map((c) => c.text).join();
  bool get _isComplete => _otp.length == 6;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});

    if (_isComplete) {
      _submit();
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      setState(() {});
    }
  }

  void _submit() {
    if (!_isComplete) return;
    FocusScope.of(context).unfocus();
    context.read<AuthController>().verifyOtp(otp: _otp);
  }

  @override
  Widget build(BuildContext context) {
    final email =
        context.select<AuthController, String?>((c) => c.state.email) ?? '';

    return BlocListener<AuthController, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.otpVerified) {
          context.push('/sign-up/name');
        } else if (state.status == AuthStatus.error &&
            state.errorMessage != null) {
          CcSnackbar.error(context, state.errorMessage!);
          context.read<AuthController>().clearError();
          // Clear OTP fields on error
          for (final c in _controllers) {
            c.clear();
          }
          _focusNodes.first.requestFocus();
          setState(() {});
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
                  title: 'Sign Up',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.xxxl + AppSpacing.xl),
                        // Email icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: SemanticColors.backgroundSurface,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/otp_image_email.png',
                              width: 30,
                              height: 30,
                              color: SemanticColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          'Check Your Email',
                          style: AppTypography.headlineLarge.copyWith(
                            color: SemanticColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          "We've sent a 6-digit code to",
                          style: AppTypography.bodyMedium.copyWith(
                            color: SemanticColors.textSecondary,
                          ),
                        ),
                        Text(
                          email,
                          style: AppTypography.bodyMedium.copyWith(
                            color: SemanticColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        // OTP fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (i) {
                            return Padding(
                              padding: EdgeInsets.only(
                                left: i == 0 ? 0 : AppSpacing.sm,
                              ),
                              child: _OtpDigitField(
                                controller: _controllers[i],
                                focusNode: _focusNodes[i],
                                onChanged: (v) => _onDigitChanged(i, v),
                                onKeyEvent: (e) => _onKeyEvent(i, e),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        BlocBuilder<AuthController, AuthState>(
                          builder: (context, state) {
                            return CcButton(
                              label: 'Verify',
                              onPressed: _isComplete ? _submit : null,
                              variant: _isComplete
                                  ? CcButtonVariant.primary
                                  : CcButtonVariant.disabled,
                              isLoading: state.status == AuthStatus.loading,
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        // Resend / Change email links
                        GestureDetector(
                          onTap: () {
                            context.read<AuthController>().resendOtp();
                            CcSnackbar.info(context, 'Code resent to $email');
                          },
                          child: Text(
                            "Didn't receive a code?",
                            style: AppTypography.bodyMedium.copyWith(
                              color: SemanticColors.interactivePrimary,
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  SemanticColors.interactivePrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.base),
                        GestureDetector(
                          onTap: () => context.go('/sign-up'),
                          child: Text(
                            'Change Email Address',
                            style: AppTypography.bodyMedium.copyWith(
                              color: SemanticColors.textSecondary,
                              decoration: TextDecoration.underline,
                              decorationColor: SemanticColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpDigitField extends StatelessWidget {
  const _OtpDigitField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.isNotEmpty;

    return KeyboardListener(
      focusNode: FocusNode(), // intermediate listener
      onKeyEvent: onKeyEvent,
      child: SizedBox(
        width: 48,
        height: 56,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          maxLength: 1,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTypography.headlineLarge.copyWith(
            color: ComponentColors.otpFieldText,
          ),
          onChanged: onChanged,
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: ComponentColors.otpFieldBg,
            contentPadding: EdgeInsets.zero,
            border: _border(ComponentColors.otpFieldBorder),
            enabledBorder: _border(
              hasValue
                  ? ComponentColors.otpFieldBorderFocused
                  : ComponentColors.otpFieldBorder,
            ),
            focusedBorder: _border(ComponentColors.otpFieldBorderFocused),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }
}
