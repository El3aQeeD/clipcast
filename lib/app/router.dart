import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../features/account_setup/presentation/components/account_setup_shell.dart';
import '../features/account_setup/presentation/controller/account_setup_controller.dart';
import '../features/account_setup/presentation/pages/choose_categories_page.dart';
import '../features/account_setup/presentation/pages/choose_podcasts_page.dart';
import '../features/account_setup/presentation/pages/choose_speakers_page.dart';
import '../features/account_setup/presentation/pages/great_picks_page.dart';
import '../features/auth/presentation/controller/auth_controller.dart';
import '../features/auth/presentation/pages/name_input_page.dart';
import '../features/auth/presentation/pages/onboarding_page.dart';
import '../features/auth/presentation/pages/otp_verification_page.dart';
import '../features/auth/presentation/pages/password_page.dart';
import '../features/auth/presentation/pages/sign_up_choose_method_page.dart';
import '../features/auth/presentation/pages/sign_up_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/feed/presentation/pages/feed_page.dart';
import '../features/notifications/presentation/controller/notification_permission_controller.dart';
import '../features/notifications/presentation/pages/notification_permission_page.dart';
import '../features/premium/presentation/pages/paywall_page.dart';
import '../features/premium/presentation/pages/premium_welcome_page.dart';
import 'di.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const FeedPage(),
    ),
    // ── Sign-up flow (shares a single AuthController) ──────────
    ShellRoute(
      builder: (context, state, child) {
        return BlocProvider(
          create: (_) => getIt<AuthController>(),
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/sign-up-method',
          builder: (context, state) => const SignUpChooseMethodPage(),
        ),
        GoRoute(
          path: '/sign-up',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: '/sign-up/password',
          builder: (context, state) => const PasswordPage(),
        ),
        GoRoute(
          path: '/sign-up/otp',
          builder: (context, state) => const OtpVerificationPage(),
        ),
        GoRoute(
          path: '/sign-up/name',
          builder: (context, state) => const NameInputPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<NotificationPermissionController>(),
        child: const NotificationPermissionPage(),
      ),
    ),
    // ── Account setup flow (shares a single AccountSetupController) ──
    ShellRoute(
      builder: (context, state, child) {
        return BlocProvider(
          create: (_) => getIt<AccountSetupController>(),
          child: child,
        );
      },
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return AccountSetupShell(child: child);
          },
          routes: [
            GoRoute(
              path: '/account-setup/categories',
              builder: (context, state) => const ChooseCategoriesPage(),
            ),
            GoRoute(
              path: '/account-setup/speakers',
              builder: (context, state) => const ChooseSpeakersPage(),
            ),
            GoRoute(
              path: '/account-setup/podcasts',
              builder: (context, state) => const ChoosePodcastsPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/account-setup/great-picks',
          builder: (context, state) => const GreatPicksPage(),
        ),
      ],
    ),
    // ── Premium / Paywall ──────────────────────────────────────
    GoRoute(
      path: '/paywall',
      builder: (context, state) => const PaywallPage(),
    ),
    GoRoute(
      path: '/premium-welcome',
      builder: (context, state) => const PremiumWelcomePage(),
    ),
  ],
);
