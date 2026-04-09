import 'auth_error_codes.dart';

/// Base failure class for domain-level errors.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class AuthFailure extends Failure {
  final AuthErrorCode code;

  const AuthFailure({
    String message = 'Authentication error',
    this.code = AuthErrorCode.unknown,
  }) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}
