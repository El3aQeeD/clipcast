import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/auth_error_codes.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repository/auth_repository.dart';
import '../source/auth_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource _remoteSource;

  const AuthRepositoryImpl(this._remoteSource);

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _remoteSource.signUpWithEmail(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      final code = AuthErrorCode.fromSupabase(e.code);
      throw AuthFailure(message: code.userMessage, code: code);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      return await _remoteSource.verifyOtp(email: email, otp: otp);
    } on AuthException catch (e) {
      final code = AuthErrorCode.fromSupabase(e.code);
      throw AuthFailure(message: code.userMessage, code: code);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> upsertDisplayName({
    required String userId,
    required String displayName,
  }) async {
    try {
      await _remoteSource.upsertDisplayName(
        userId: userId,
        displayName: displayName,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> resendOtp(String email) async {
    try {
      await _remoteSource.resendOtp(email);
    } on AuthException catch (e) {
      final code = AuthErrorCode.fromSupabase(e.code);
      throw AuthFailure(message: code.userMessage, code: code);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _remoteSource.signInWithEmail(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      final code = AuthErrorCode.fromSupabase(e.code);
      throw AuthFailure(message: code.userMessage, code: code);
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
