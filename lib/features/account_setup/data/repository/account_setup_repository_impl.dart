import '../../../../core/errors/failures.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/setup_podcast_entity.dart';
import '../../domain/entities/speaker_entity.dart';
import '../../domain/repository/account_setup_repository.dart';
import '../source/account_setup_remote_source.dart';

class AccountSetupRepositoryImpl implements AccountSetupRepository {
  final AccountSetupRemoteSource _remoteSource;

  const AccountSetupRepositoryImpl(this._remoteSource);

  @override
  Future<List<CategoryEntity>> getCategories({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      return await _remoteSource.fetchCategories(
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<SpeakerEntity>> getSpeakers({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      return await _remoteSource.fetchSpeakers(
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<SetupPodcastEntity>> getPodcastsGrouped({
    required List<String> categoryNames,
    int perCategory = 2,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      return await _remoteSource.fetchPodcastsGrouped(
        categoryNames: categoryNames,
        perCategory: perCategory,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<SetupPodcastEntity>> getPodcastsByCategory({
    required String categoryName,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      return await _remoteSource.fetchPodcastsByCategory(
        categoryName: categoryName,
        offset: offset,
        limit: limit,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<String>> saveOnboardingChoices({
    required String userId,
    required List<String> categoryIds,
    required List<String> speakerIds,
    required List<String> podcastIds,
  }) async {
    try {
      return await _remoteSource.saveChoicesAndCurate(
        userId: userId,
        categoryIds: categoryIds,
        speakerIds: speakerIds,
        podcastIds: podcastIds,
      );
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
