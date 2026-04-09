import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category_model.dart';
import '../models/setup_podcast_model.dart';
import '../models/speaker_model.dart';

abstract class AccountSetupRemoteSource {
  Future<List<CategoryModel>> fetchCategories({
    int offset = 0,
    int limit = 20,
  });

  Future<List<SpeakerModel>> fetchSpeakers({
    int offset = 0,
    int limit = 20,
  });

  Future<List<SetupPodcastModel>> fetchPodcastsGrouped({
    required List<String> categoryNames,
    int perCategory = 2,
    int offset = 0,
    int limit = 20,
  });

  Future<List<SetupPodcastModel>> fetchPodcastsByCategory({
    required String categoryName,
    int offset = 0,
    int limit = 20,
  });

  Future<List<String>> saveChoicesAndCurate({
    required String userId,
    required List<String> categoryIds,
    required List<String> speakerIds,
    required List<String> podcastIds,
  });
}

class AccountSetupRemoteSourceImpl implements AccountSetupRemoteSource {
  final SupabaseClient _client;

  const AccountSetupRemoteSourceImpl(this._client);

  @override
  Future<List<CategoryModel>> fetchCategories({
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _client
        .from('podcast_categories')
        .select()
        .order('display_order')
        .range(offset, offset + limit - 1);

    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Future<List<SpeakerModel>> fetchSpeakers({
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _client
        .from('podcast_speakers')
        .select()
        .order('display_order')
        .range(offset, offset + limit - 1);

    return data.map((json) => SpeakerModel.fromJson(json)).toList();
  }

  @override
  Future<List<SetupPodcastModel>> fetchPodcastsGrouped({
    required List<String> categoryNames,
    int perCategory = 2,
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _client.rpc('get_setup_podcasts_grouped', params: {
      'p_categories': categoryNames,
      'p_per_category': perCategory,
      'p_offset': offset,
      'p_limit': limit,
    });

    return (data as List)
        .map((json) => SetupPodcastModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SetupPodcastModel>> fetchPodcastsByCategory({
    required String categoryName,
    int offset = 0,
    int limit = 20,
  }) async {
    final data = await _client
        .from('podcasts')
        .select('id, title, artwork_url, author, categories')
        .contains('categories', [categoryName])
        .order('title')
        .range(offset, offset + limit - 1);

    return data.map((json) => SetupPodcastModel.fromJson(json)).toList();
  }

  @override
  Future<List<String>> saveChoicesAndCurate({
    required String userId,
    required List<String> categoryIds,
    required List<String> speakerIds,
    required List<String> podcastIds,
  }) async {
    final stopwatch = Stopwatch()..start();
    final response = await _client.functions.invoke(
      'curate-user-feed',
      body: {
        'user_id': userId,
        'category_ids': categoryIds,
        'speaker_ids': speakerIds,
        'podcast_ids': podcastIds,
      },
    );
    stopwatch.stop();
    // ignore: avoid_print
    print(
      '[curate-user-feed] call took ${stopwatch.elapsedMilliseconds}ms'
      ' | server reported ${response.data?["ms"] ?? "?"}ms',
    );

    return List<String>.from(
      response.data?['preview_artworks'] as List? ?? [],
    );
  }
}
