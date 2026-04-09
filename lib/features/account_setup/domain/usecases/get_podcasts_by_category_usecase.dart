import '../entities/setup_podcast_entity.dart';
import '../repository/account_setup_repository.dart';

class GetPodcastsByCategoryUseCase {
  final AccountSetupRepository _repository;

  const GetPodcastsByCategoryUseCase(this._repository);

  Future<List<SetupPodcastEntity>> call({
    required String categoryName,
    int offset = 0,
    int limit = 20,
  }) {
    return _repository.getPodcastsByCategory(
      categoryName: categoryName,
      offset: offset,
      limit: limit,
    );
  }
}
