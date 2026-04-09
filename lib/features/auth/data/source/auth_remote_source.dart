import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

abstract class AuthRemoteSource {
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<UserModel> verifyOtp({
    required String email,
    required String otp,
  });

  Future<void> upsertDisplayName({
    required String userId,
    required String displayName,
  });

  Future<void> resendOtp(String email);

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });
}

class AuthRemoteSourceImpl implements AuthRemoteSource {
  final SupabaseClient _client;

  const AuthRemoteSourceImpl(this._client);

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Sign up failed. Please try again.');
    }

    // Supabase returns a user with empty identities when the email is
    // already registered (to prevent enumeration). Treat this as
    // "user already exists" so the UI can guide them to log in instead.
    if (user.identities == null || user.identities!.isEmpty) {
      throw const AuthException(
        'An account with this email already exists.',
        statusCode: '422',
        code: 'user_already_exists',
      );
    }

    return UserModel.fromSupabaseUser(
      id: user.id,
      email: user.email,
      isEmailVerified: false,
    );
  }

  @override
  Future<UserModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _client.auth.verifyOTP(
      email: email,
      token: otp,
      type: OtpType.signup,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('OTP verification failed.');
    }

    return UserModel.fromSupabaseUser(
      id: user.id,
      email: user.email,
      isEmailVerified: true,
    );
  }

  @override
  Future<void> upsertDisplayName({
    required String userId,
    required String displayName,
  }) async {
    await _client.from('profiles').upsert({
      'id': userId,
      'display_name': displayName,
      'username': displayName.toLowerCase().replaceAll(' ', '_'),
    });
  }

  @override
  Future<void> resendOtp(String email) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Sign in failed. Please try again.');
    }

    return UserModel.fromSupabaseUser(
      id: user.id,
      email: user.email,
      isEmailVerified: user.emailConfirmedAt != null,
    );
  }
}
