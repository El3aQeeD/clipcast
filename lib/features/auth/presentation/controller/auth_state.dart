import '../../../../core/errors/auth_error_codes.dart';
import '../../domain/entities/user_entity.dart';

enum AuthStatus {
  initial,
  loading,
  emailSubmitted,
  signUpSuccess,
  signInSuccess,
  otpVerified,
  nameSubmitted,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? email;
  final String? errorMessage;
  final AuthErrorCode? errorCode;
  final UserEntity? user;

  const AuthState({
    this.status = AuthStatus.initial,
    this.email,
    this.errorMessage,
    this.errorCode,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? errorMessage,
    AuthErrorCode? errorCode,
    UserEntity? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      errorMessage: errorMessage,
      errorCode: errorCode,
      user: user ?? this.user,
    );
  }
}
