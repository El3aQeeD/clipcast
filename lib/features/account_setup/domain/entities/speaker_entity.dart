class SpeakerEntity {
  final String id;
  final String name;
  final String? photoUrl;
  final List<String> externalPodcastIds;
  final int displayOrder;

  const SpeakerEntity({
    required this.id,
    required this.name,
    this.photoUrl,
    this.externalPodcastIds = const [],
    this.displayOrder = 0,
  });
}
