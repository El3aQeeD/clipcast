import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    super.displayName,
    super.username,
    super.avatarUrl,
    super.bio,
    super.isPremium,
    super.isEmailVerified,
  });

  factory UserModel.fromSupabaseUser({
    required String id,
    String? email,
    bool isEmailVerified = false,
  }) {
    return UserModel(
      id: id,
      email: email,
      isEmailVerified: isEmailVerified,
    );
  }

  factory UserModel.fromProfileJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      isPremium: json['is_premium'] as bool? ?? false,
      isEmailVerified: true,
    );
  }

  Map<String, dynamic> toProfileJson() {
    return {
      'id': id,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (bio != null) 'bio': bio,
    };
  }
}
