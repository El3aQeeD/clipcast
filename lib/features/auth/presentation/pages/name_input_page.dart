import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/utils/input_validators.dart';
import '../../../../shared/widgets/cc_button.dart';
import '../../../../shared/widgets/cc_snackbar.dart';
import '../../../../theme/tokens/components.dart';
import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import '../components/auth_icons.dart';
import '../components/sign_up_header.dart';
import '../components/sign_up_text_field.dart';
import '../controller/auth_controller.dart';
import '../controller/auth_state.dart';

class NameInputPage extends StatefulWidget {
  const NameInputPage({super.key});

  @override
  State<NameInputPage> createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  final _nameController = TextEditingController();

  bool get _isValid => InputValidators.isNameValid(_nameController.text);

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_isValid) return;
    context.read<AuthController>().submitDisplayName(
          _nameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthController, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.nameSubmitted) {
          // Navigate to notification permission screen
          context.go('/notifications');
        } else if (state.status == AuthStatus.error &&
            state.errorMessage != null) {
          CcSnackbar.error(context, state.errorMessage!);
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
                  title: 'Sign Up',
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xxxl),
                        Text(
                          "What's your Name?",
                          style: AppTypography.displayMedium.copyWith(
                            color: SemanticColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'This will appear on your ClipCast profile.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: SemanticColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        SignUpTextField(
                          controller: _nameController,
                          hintText: 'Enter Your Name',
                          keyboardType: TextInputType.name,
                          isValid: _isValid,
                          suffixIcon: _isValid
                              ? const Icon(
                                  AuthIcons.correctCheckMark,
                                color: ComponentColors.inputValidCheckmark,
                                  size: 24,
                                )
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.xxxl + AppSpacing.md),
                        BlocBuilder<AuthController, AuthState>(
                          builder: (context, state) {
                            final isLoading =
                                state.status == AuthStatus.loading;
                            return CcButton(
                              label: 'Create Account',
                              onPressed: _isValid ? _submit : null,
                              variant: _isValid
                                  ? CcButtonVariant.primary
                                  : CcButtonVariant.disabled,
                              isLoading: isLoading,
                            );
                          },
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
