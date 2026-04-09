import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import 'step_progress_bar.dart';

class AccountSetupShell extends StatelessWidget {
  const AccountSetupShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentStep = _stepFromLocation(location);
    final showBack = currentStep > 1;

    return Scaffold(
      backgroundColor: SemanticColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: SemanticColors.backgroundPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                color: SemanticColors.textPrimary,
                onPressed: () {
                  if (location.contains('podcasts')) {
                    context.go('/account-setup/speakers');
                  } else if (location.contains('speakers')) {
                    context.go('/account-setup/categories');
                  }
                },
              )
            : null,
        title: Text(
          'Set Your Account',
          style: AppTypography.bodyMedium.copyWith(
            color: SemanticColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.xxl,
              AppSpacing.screenHorizontal,
              0,
            ),
            child: StepProgressBar(currentStep: currentStep),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _stepFromLocation(String location) {
    if (location.contains('categories')) return 1;
    if (location.contains('speakers')) return 2;
    if (location.contains('podcasts')) return 3;
    return 1;
  }
}
