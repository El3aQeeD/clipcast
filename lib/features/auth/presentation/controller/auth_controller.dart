import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/auth_error_codes.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/upsert_display_name_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_state.dart';

class AuthController extends Cubit<AuthState> {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final UpsertDisplayNameUseCase _upsertDisplayNameUseCase;
  final ResendOtpUseCase _resendOtpUseCase;

  AuthController({
    required SignUpUseCase signUpUseCase,
    required SignInUseCase signInUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required UpsertDisplayNameUseCase upsertDisplayNameUseCase,
    required ResendOtpUseCase resendOtpUseCase,
  })  : _signUpUseCase = signUpUseCase,
        _signInUseCase = signInUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _upsertDisplayNameUseCase = upsertDisplayNameUseCase,
        _resendOtpUseCase = resendOtpUseCase,
        super(const AuthState());

  void setEmail(String email) {
    emit(state.copyWith(
      status: AuthStatus.emailSubmitted,
      email: email,
    ));
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _signUpUseCase(email: email, password: password);
      emit(state.copyWith(
        status: AuthStatus.signUpSuccess,
        email: email,
        user: user,
      ));
    } on AuthFailure catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
        errorCode: e.code,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
        errorCode: AuthErrorCode.unknown,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
        errorCode: AuthErrorCode.unknown,
      ));
    }
  }

  Future<void> verifyOtp({
    required String otp,
  }) async {
    final email = state.email;
    if (email == null) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Email not found. Please restart sign up.',
      ));
      return;
    }
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _verifyOtpUseCase(email: email, otp: otp);
      emit(state.copyWith(
        status: AuthStatus.otpVerified,
        user: user,
      ));
    } on AuthFailure catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
        errorCode: e.code,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> submitDisplayName(String displayName) async {
    final userId = state.user?.id;
    if (userId == null) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'User not found. Please restart sign up.',
      ));
      return;
    }
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      await _upsertDisplayNameUseCase(
        userId: userId,
        displayName: displayName,
      );
      emit(state.copyWith(status: AuthStatus.nameSubmitted));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> resendOtp() async {
    final email = state.email;
    if (email == null) return;
    try {
      await _resendOtpUseCase(email);
    } catch (_) {
      // Silently fail — user can retry
    }
  }

  void clearError() {
    emit(state.copyWith(status: AuthStatus.initial));
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _signInUseCase(email: email, password: password);
      emit(state.copyWith(
        status: AuthStatus.signInSuccess,
        email: email,
        user: user,
      ));
    } on AuthFailure catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
        errorCode: e.code,
      ));
    } on Failure catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
        errorCode: AuthErrorCode.unknown,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
        errorCode: AuthErrorCode.unknown,
      ));
    }
  }
}
