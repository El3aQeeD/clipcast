import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.taddyGenre,
    super.parentId,
    super.iconName,
    super.displayOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      taddyGenre: json['taddy_genre'] as String,
      parentId: json['parent_id'] as String?,
      iconName: json['icon_name'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }
}
