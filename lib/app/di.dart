import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/account_setup/data/repository/account_setup_repository_impl.dart';
import '../features/account_setup/data/source/account_setup_remote_source.dart';
import '../features/account_setup/domain/repository/account_setup_repository.dart';
import '../features/account_setup/domain/usecases/get_categories_usecase.dart';
import '../features/account_setup/domain/usecases/get_podcasts_by_category_usecase.dart';
import '../features/account_setup/domain/usecases/get_podcasts_for_setup_usecase.dart';
import '../features/account_setup/domain/usecases/get_speakers_usecase.dart';
import '../features/account_setup/domain/usecases/save_onboarding_choices_usecase.dart';
import '../features/account_setup/presentation/controller/account_setup_controller.dart';
import '../features/auth/data/repository/auth_repository_impl.dart';
import '../features/auth/data/source/auth_remote_source.dart';
import '../features/auth/domain/repository/auth_repository.dart';
import '../features/auth/domain/usecases/resend_otp_usecase.dart';
import '../features/auth/domain/usecases/sign_in_usecase.dart';
import '../features/auth/domain/usecases/sign_up_usecase.dart';
import '../features/auth/domain/usecases/upsert_display_name_usecase.dart';
import '../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../features/auth/presentation/controller/auth_controller.dart';
import '../features/notifications/domain/usecases/request_notification_permission_usecase.dart';
import '../features/notifications/presentation/controller/notification_permission_controller.dart';

final GetIt getIt = GetIt.instance;

/// Initialise all dependency injection bindings.
/// Call this in main() before runApp().
Future<void> initDependencies() async {
  // ── Supabase client ──────────────────────────────────────────
  getIt.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // ── Data sources ─────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRemoteSource>(
    () => AuthRemoteSourceImpl(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<AccountSetupRemoteSource>(
    () => AccountSetupRemoteSourceImpl(getIt<SupabaseClient>()),
  );

  // ── Repositories ─────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteSource>()),
  );
  getIt.registerLazySingleton<AccountSetupRepository>(
    () => AccountSetupRepositoryImpl(getIt<AccountSetupRemoteSource>()),
  );

  // ── Use cases ────────────────────────────────────────────────
  getIt.registerLazySingleton(() => SignUpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => SignInUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => VerifyOtpUseCase(getIt<AuthRepository>()));
  getIt.registerLazySingleton(
    () => UpsertDisplayNameUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton(() => ResendOtpUseCase(getIt<AuthRepository>()));

  getIt.registerLazySingleton(
    () => GetCategoriesUseCase(getIt<AccountSetupRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetSpeakersUseCase(getIt<AccountSetupRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetPodcastsForSetupUseCase(getIt<AccountSetupRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetPodcastsByCategoryUseCase(getIt<AccountSetupRepository>()),
  );
  getIt.registerLazySingleton(
    () => SaveOnboardingChoicesUseCase(getIt<AccountSetupRepository>()),
  );

  // ── Controllers (Cubits) ─────────────────────────────────────
  getIt.registerFactory(
    () => AuthController(
      signUpUseCase: getIt<SignUpUseCase>(),
      signInUseCase: getIt<SignInUseCase>(),
      verifyOtpUseCase: getIt<VerifyOtpUseCase>(),
      upsertDisplayNameUseCase: getIt<UpsertDisplayNameUseCase>(),
      resendOtpUseCase: getIt<ResendOtpUseCase>(),
    ),
  );

  getIt.registerFactory(
    () => AccountSetupController(
      getCategoriesUseCase: getIt<GetCategoriesUseCase>(),
      getSpeakersUseCase: getIt<GetSpeakersUseCase>(),
      getPodcastsForSetupUseCase: getIt<GetPodcastsForSetupUseCase>(),
      getPodcastsByCategoryUseCase: getIt<GetPodcastsByCategoryUseCase>(),
      saveOnboardingChoicesUseCase: getIt<SaveOnboardingChoicesUseCase>(),
    ),
  );

  // ── Notifications ────────────────────────────────────────────
  getIt.registerLazySingleton(
    () => RequestNotificationPermissionUseCase(),
  );
  getIt.registerFactory(
    () => NotificationPermissionController(
      requestNotificationPermissionUseCase:
          getIt<RequestNotificationPermissionUseCase>(),
    ),
  );
}
