import '../../domain/entities/setup_podcast_entity.dart';

class SetupPodcastModel extends SetupPodcastEntity {
  const SetupPodcastModel({
    required super.id,
    required super.title,
    super.imageUrl,
    super.author,
    super.categories,
    super.categoryGroup,
  });

  factory SetupPodcastModel.fromJson(Map<String, dynamic> json) {
    return SetupPodcastModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      imageUrl: json['artwork_url'] as String?,
      author: json['author'] as String?,
      categories: (json['categories'] as List<dynamic>?)?.cast<String>() ??
          const [],
      categoryGroup: json['category_group'] as String?,
    );
  }
}
