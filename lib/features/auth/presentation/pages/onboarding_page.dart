import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/tokens/components.dart';
import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import '../components/onboarding_page_content.dart';
import '../components/onboarding_progress_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoAdvanceTimer;
  bool _isAutoAdvancing = false;

  static const List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Find your favorite\npodcasts',
      subtitle: 'From creators and thought leaders you care about.',
      illustrationAsset: 'assets/images/onboarding_podcasts.png',
    ),
    OnboardingPageData(
      title: 'Capture key\nmoments',
      subtitle:
          'Tap once to Save powerful ideas, quotes, and insights in seconds.',
      illustrationAsset: 'assets/images/onboarding_capture.png',
    ),
    OnboardingPageData(
      title: 'Revisit and retain\nwhat you hear',
      subtitle: 'Turn passive listening into active learning.',
      illustrationAsset: 'assets/images/onboarding_retain.png',
    ),
    OnboardingPageData(
      title: 'Share insights,\nnot just episodes',
      subtitle:
          'Easily share meaningful moments with friends and colleagues.',
      illustrationAsset: 'assets/images/onboarding_share.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer = Timer.periodic(
      const Duration(milliseconds: 3000),
      (_) {
        if (_currentPage < _pages.length - 1) {
          _isAutoAdvancing = true;
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        } else {
          _autoAdvanceTimer?.cancel();
        }
      },
    );
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SemanticColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.xl,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OnboardingProgressIndicator(
                    totalSteps: _pages.length,
                    activeStep: _currentPage,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: Image.asset(
                          'assets/images/clipcast_icon.png',
                          width: AppSpacing.lg,
                          height: AppSpacing.lg,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Welcome to ClipCast',
                        style: AppTypography.bodyMedium.copyWith(
                          color: SemanticColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  if (!_isAutoAdvancing) {
                    _autoAdvanceTimer?.cancel();
                  }
                  _isAutoAdvancing = false;
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return OnboardingPageContent(data: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.xxl,
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/sign-up-method', extra: false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ComponentColors.buttonPrimaryBg,
                        foregroundColor: ComponentColors.buttonPrimaryText,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md + 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Create Account',
                        style: AppTypography.button,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context.push('/sign-up-method', extra: true);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: ComponentColors.buttonSecondaryBg,
                        foregroundColor: ComponentColors.buttonSecondaryText,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md + 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        side: const BorderSide(
                          color: ComponentColors.buttonSecondaryBorder,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Log In',
                        style: AppTypography.button,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
