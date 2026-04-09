import '../repository/account_setup_repository.dart';

class SaveOnboardingChoicesUseCase {
  final AccountSetupRepository _repository;

  const SaveOnboardingChoicesUseCase(this._repository);

  Future<List<String>> call({
    required String userId,
    required List<String> categoryIds,
    required List<String> speakerIds,
    required List<String> podcastIds,
  }) {
    return _repository.saveOnboardingChoices(
      userId: userId,
      categoryIds: categoryIds,
      speakerIds: speakerIds,
      podcastIds: podcastIds,
    );
  }
}
