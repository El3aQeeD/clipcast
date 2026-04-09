import '../../domain/entities/speaker_entity.dart';

class SpeakerModel extends SpeakerEntity {
  const SpeakerModel({
    required super.id,
    required super.name,
    super.photoUrl,
    super.externalPodcastIds,
    super.displayOrder,
  });

  factory SpeakerModel.fromJson(Map<String, dynamic> json) {
    return SpeakerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      photoUrl: json['photo_url'] as String?,
      externalPodcastIds: (json['external_podcast_ids'] as List<dynamic>?)
              ?.cast<String>() ??
          const [],
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }
}
