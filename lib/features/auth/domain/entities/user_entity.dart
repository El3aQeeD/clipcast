class UserEntity {
  final String id;
  final String? email;
  final String? displayName;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final bool isPremium;
  final bool isEmailVerified;

  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.username,
    this.avatarUrl,
    this.bio,
    this.isPremium = false,
    this.isEmailVerified = false,
  });
}
