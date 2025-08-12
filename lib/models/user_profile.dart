class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String role;
  final bool isActive;
  final int dailyStreak;
  final DateTime? lastLoginDate;
  final List<String> preferredGenres;
  final List<String> favoriteCharacters;
  final bool pushNotificationsEnabled;
  final bool darkModeEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    required this.isActive,
    required this.dailyStreak,
    this.lastLoginDate,
    required this.preferredGenres,
    required this.favoriteCharacters,
    required this.pushNotificationsEnabled,
    required this.darkModeEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] ?? '',
        email: json['email'] ?? '',
        fullName: json['full_name'] ?? '',
        avatarUrl: json['avatar_url'],
        role: json['role'] ?? 'regular_user',
        isActive: json['is_active'] ?? true,
        dailyStreak: json['daily_streak'] ?? 0,
        lastLoginDate: json['last_login_date'] != null
            ? DateTime.parse(json['last_login_date'])
            : null,
        preferredGenres: json['preferred_genres'] != null
            ? List<String>.from(json['preferred_genres'])
            : [],
        favoriteCharacters: json['favorite_characters'] != null
            ? List<String>.from(json['favorite_characters'])
            : [],
        pushNotificationsEnabled: json['push_notifications_enabled'] ?? true,
        darkModeEnabled: json['dark_mode_enabled'] ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'role': role,
        'is_active': isActive,
        'daily_streak': dailyStreak,
        'last_login_date': lastLoginDate?.toIso8601String(),
        'preferred_genres': preferredGenres,
        'favorite_characters': favoriteCharacters,
        'push_notifications_enabled': pushNotificationsEnabled,
        'dark_mode_enabled': darkModeEnabled,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class UserStoryInteraction {
  final String id;
  final String userId;
  final String storyId;
  final String interactionType;
  final DateTime createdAt;

  UserStoryInteraction({
    required this.id,
    required this.userId,
    required this.storyId,
    required this.interactionType,
    required this.createdAt,
  });

  factory UserStoryInteraction.fromJson(Map<String, dynamic> json) =>
      UserStoryInteraction(
        id: json['id'] ?? '',
        userId: json['user_id'] ?? '',
        storyId: json['story_id'] ?? '',
        interactionType: json['interaction_type'] ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'story_id': storyId,
        'interaction_type': interactionType,
        'created_at': createdAt.toIso8601String(),
      };
}
