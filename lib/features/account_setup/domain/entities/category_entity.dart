class CategoryEntity {
  final String id;
  final String name;
  final String taddyGenre;
  final String? parentId;
  final String? iconName;
  final int displayOrder;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.taddyGenre,
    this.parentId,
    this.iconName,
    this.displayOrder = 0,
  });
}
