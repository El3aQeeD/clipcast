import '../entities/category_entity.dart';
import '../entities/setup_podcast_entity.dart';
import '../entities/speaker_entity.dart';

abstract class AccountSetupRepository {
  Future<List<CategoryEntity>> getCategories({
    int offset = 0,
    int limit = 20,
  });

  Future<List<SpeakerEntity>> getSpeakers({
    int offset = 0,
    int limit = 20,
  });

  Future<List<SetupPodcastEntity>> getPodcastsGrouped({
    required List<String> categoryNames,
    int perCategory = 2,
    int offset = 0,
    int limit = 20,
  });

  Future<List<SetupPodcastEntity>> getPodcastsByCategory({
    required String categoryName,
    int offset = 0,
    int limit = 20,
  });

  Future<List<String>> saveOnboardingChoices({
    required String userId,
    required List<String> categoryIds,
    required List<String> speakerIds,
    required List<String> podcastIds,
  });
}
