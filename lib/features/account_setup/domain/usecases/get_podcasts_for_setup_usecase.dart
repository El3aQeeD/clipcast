import '../entities/setup_podcast_entity.dart';
import '../repository/account_setup_repository.dart';

class GetPodcastsForSetupUseCase {
  final AccountSetupRepository _repository;

  const GetPodcastsForSetupUseCase(this._repository);

  Future<List<SetupPodcastEntity>> call(
    List<String> categoryNames, {
    int perCategory = 2,
    int offset = 0,
    int limit = 20,
  }) {
    return _repository.getPodcastsGrouped(
      categoryNames: categoryNames,
      perCategory: perCategory,
      offset: offset,
      limit: limit,
    );
  }
}
