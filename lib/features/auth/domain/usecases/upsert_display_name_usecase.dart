import '../repository/auth_repository.dart';

class UpsertDisplayNameUseCase {
  final AuthRepository _repository;

  const UpsertDisplayNameUseCase(this._repository);

  Future<void> call({
    required String userId,
    required String displayName,
  }) {
    return _repository.upsertDisplayName(
      userId: userId,
      displayName: displayName,
    );
  }
}
