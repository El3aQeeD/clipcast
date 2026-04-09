import '../repository/auth_repository.dart';

class ResendOtpUseCase {
  final AuthRepository _repository;

  const ResendOtpUseCase(this._repository);

  Future<void> call(String email) {
    return _repository.resendOtp(email);
  }
}
