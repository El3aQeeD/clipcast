import 'package:flutter/material.dart';

import '../../../../theme/tokens/components.dart';
import '../../../../theme/tokens/semantic.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/typography.dart';
import '../components/onboarding_page_content.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingPageData> _pages = [
    OnboardingPageData(
      title: 'Find your favorite\npodcasts',
      subtitle: 'From creators and thought leaders you care about.',
      illustrationAsset: 'assets/images/onboarding_podcasts.png',
      activeIndex: 0,
    ),
    OnboardingPageData(
      title: 'Capture key\nmoments',
      subtitle:
          'Tap once to Save powerful ideas, quotes, and insights in seconds.',
      illustrationAsset: 'assets/images/onboarding_capture.png',
      activeIndex: 1,
    ),
    OnboardingPageData(
      title: 'Revisit and retain\nwhat you hear',
      subtitle: 'Turn passive listening into active learning.',
      illustrationAsset: 'assets/images/onboarding_retain.png',
      activeIndex: 2,
    ),
    OnboardingPageData(
      title: 'Share insights,\nnot just episodes',
      subtitle:
          'Easily share meaningful moments with friends and colleagues.',
      illustrationAsset: 'assets/images/onboarding_share.png',
      activeIndex: 3,
    ),
  ];

  @override
  void dispose() {
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
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return OnboardingPageContent(
                    data: _pages[index],
                    currentPage: _currentPage,
                  );
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
                        // TODO: Navigate to create account
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
                        // TODO: Navigate to login
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
