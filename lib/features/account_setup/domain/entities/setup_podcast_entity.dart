class SetupPodcastEntity {
  final String id;
  final String title;
  final String? imageUrl;
  final String? author;
  final List<String> categories;
  final String? categoryGroup;

  const SetupPodcastEntity({
    required this.id,
    required this.title,
    this.imageUrl,
    this.author,
    this.categories = const [],
    this.categoryGroup,
  });
}
