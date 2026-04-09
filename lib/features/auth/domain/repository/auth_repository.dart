import '../entities/user_entity.dart';

/// Abstract auth repository interface — pure Dart contract.
abstract class AuthRepository {
  /// Sign up with email and password.
  /// Supabase sends an OTP to the email for verification.
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Verify OTP code sent to email after sign-up.
  Future<UserEntity> verifyOtp({
    required String email,
    required String otp,
  });

  /// Upsert the user's display name into the profiles table.
  Future<void> upsertDisplayName({
    required String userId,
    required String displayName,
  });

  /// Resend OTP verification email.
  Future<void> resendOtp(String email);

  /// Sign in with email and password.
  /// Returns the authenticated user if credentials are valid.
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });
}
