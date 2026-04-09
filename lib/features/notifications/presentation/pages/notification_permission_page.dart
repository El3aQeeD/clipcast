import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/cc_button.dart';
import '../../../../theme/tokens/components.dart';
import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import '../controller/notification_permission_controller.dart';
import '../controller/notification_permission_state.dart';

class NotificationPermissionPage extends StatelessWidget {
  const NotificationPermissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationPermissionController,
        NotificationPermissionState>(
      listener: (context, state) {
        if (state.status == NotificationPermissionStatus.granted ||
            state.status == NotificationPermissionStatus.denied ||
            state.status == NotificationPermissionStatus.skipped) {
          context.go('/account-setup/categories');
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

                // ── Body ───────────────────────────────────────
                Expanded(
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // ── Illustration ─────────────────────────
                      Image.asset(
                        'assets/images/turn_on_notifications_frame.png',
                        width: 223,
                        height: 124,
                      ),

                      const SizedBox(height: 140),

                      // ── Title ────────────────────────────────
                      Text(
                        'Turn on push\nnotifications.',
                        textAlign: TextAlign.center,
                        style: AppTypography.displaySmall.copyWith(
                          color: SemanticColors.textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // ── Subtitle ─────────────────────────────
                      Text(
                        'Get updates about new clips,\nrecommendations, and more.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: SemanticColors.textSecondary,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const Spacer(flex: 3),

                      // ── CTA Buttons ──────────────────────────
                      BlocBuilder<NotificationPermissionController,
                          NotificationPermissionState>(
                        builder: (context, state) {
                          final isLoading = state.status ==
                              NotificationPermissionStatus.loading;
                          return CcButton(
                            label: 'Turn On Notifications',
                            onPressed: () => context
                                .read<NotificationPermissionController>()
                                .requestPermission(),
                            variant: CcButtonVariant.primary,
                            isLoading: isLoading,
                          );
                        },
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // ── Skip button ──────────────────────────
                      GestureDetector(
                        onTap: () => context
                            .read<NotificationPermissionController>()
                            .skip(),
                        child: SizedBox(
                          width: double.infinity,
                          height: 21,
                          child: Center(
                            child: Text(
                              'Skip For Now',
                              style: AppTypography.labelLarge.copyWith(
                                color: SemanticColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 1),

                      // ── Footer note ──────────────────────────
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.base),
                        child: Text(
                          'Manage your notification categories in\nSettings at any time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            height: 17 / 11,
                            letterSpacing: 0,
                            color: ComponentColors.inputPlaceholder,
                          ),
                        ),
                      ),
                    ],
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
