import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/cc_button.dart';
import '../../../../theme/tokens/primitives.dart';
import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import '../../../auth/presentation/components/auth_icons.dart';
import '../controller/account_setup_controller.dart';
import '../controller/account_setup_state.dart';

class GreatPicksPage extends StatelessWidget {
  const GreatPicksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SemanticColors.backgroundPrimary,
      body: SafeArea(
        child: BlocBuilder<AccountSetupController, AccountSetupState>(
          builder: (context, state) {
            final imageUrls = state.curatedPodcastImageUrls;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  const Spacer(),
                  _PodcastImageFan(imageUrls: imageUrls),
                  const SizedBox(height: 40),
                  Text(
                    'Great picks!',
                    style: AppTypography.displaySmall.copyWith(
                      color: SemanticColors.textPrimary,
                      fontSize: 30,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'We\'ve curated a personalized feed\nbased on your interests.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: SemanticColors.textSecondary,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  CcButton(
                    label: 'Start Listening For Free',
                    onPressed: () => context.go('/paywall'),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _PremiumUpsellCard(
                    onTap: () => context.go('/paywall'),
                  ),
                  const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Podcast Image Fan ──────────────────────────────────────────

class _PodcastImageFan extends StatelessWidget {
  const _PodcastImageFan({required this.imageUrls});

  final List<String> imageUrls;

  static const double _containerWidth = 293;
  static const double _containerHeight = 192;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _containerWidth,
      height: _containerHeight,
      child: Stack(
        children: [
          // Far-left card (index 1)
          if (imageUrls.length > 1)
            _FanCard(
              left: 23.3,
              top: 38.4,
              width: 86.4,
              height: 115.2,
              cardOpacity: 0.4,
              imageOpacity: 0.6,
              imageUrl: imageUrls[1],
            ),
          // Far-right card (index 2)
          if (imageUrls.length > 2)
            _FanCard(
              left: 183.3,
              top: 38.4,
              width: 86.4,
              height: 115.2,
              cardOpacity: 0.4,
              imageOpacity: 0.6,
              imageUrl: imageUrls[2],
            ),
          // Middle-left card (index 3)
          if (imageUrls.length > 3)
            _FanCard(
              left: 45.3,
              top: 27.6,
              width: 106.4,
              height: 136.8,
              cardOpacity: 0.7,
              imageOpacity: 0.8,
              imageUrl: imageUrls[3],
              hasShadow: true,
            ),
          // Middle-right card (index 4)
          if (imageUrls.length > 4)
            _FanCard(
              left: 141.3,
              top: 27.6,
              width: 106.4,
              height: 136.8,
              cardOpacity: 0.7,
              imageOpacity: 0.8,
              imageUrl: imageUrls[4],
              hasShadow: true,
            ),
          // Center card — top priority curated podcast (index 0)
          Positioned(
            left: 82.5,
            top: 32,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: PrimitiveColors.white100,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: PrimitiveColors.white20),
                boxShadow: const [
                  BoxShadow(
                    color: PrimitiveColors.white30,
                    blurRadius: 40,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: imageUrls.isNotEmpty
                    ? Image.network(
                        imageUrls[0],
                        fit: BoxFit.cover,
                        width: 128,
                        height: 128,
                        errorBuilder: (_, _, _) => Image.asset(
                          'assets/images/clipcast_icon.png',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/images/clipcast_icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.podcasts,
                          color: SemanticColors.backgroundPrimary,
                          size: 40,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FanCard extends StatelessWidget {
  const _FanCard({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.cardOpacity,
    required this.imageOpacity,
    this.imageUrl,
    this.hasShadow = false,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final double cardOpacity;
  final double imageOpacity;
  final String? imageUrl;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: cardOpacity,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: PrimitiveColors.white10),
            boxShadow: hasShadow
                ? const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 15,
                      offset: Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: imageUrl != null
                ? Opacity(
                    opacity: imageOpacity,
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      width: width,
                      height: height,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

// ── Premium Upsell Card ────────────────────────────────────────

class _PremiumUpsellCard extends StatelessWidget {
  const _PremiumUpsellCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: SemanticColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: SemanticColors.borderFaint),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AuthIcons.unlockPro,
                  color: SemanticColors.textPrimary.withValues(alpha: 0.9),
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Unlock AI Powers',
                  style: AppTypography.labelLarge.copyWith(
                    color: SemanticColors.textPrimary.withValues(alpha: 0.9),
                    fontSize: 15,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Get unlimited AI summaries &\ntranscripts.',
              style: AppTypography.bodySmall.copyWith(
                color: SemanticColors.textHint,
                fontSize: 13,
                letterSpacing: -0.5,
                height: 18 / 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Text(
              'View Premium Plan',
              style: AppTypography.labelLarge.copyWith(
                color: SemanticColors.textPrimary,
                decoration: TextDecoration.underline,
                decorationColor: SemanticColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
