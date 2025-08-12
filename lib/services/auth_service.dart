import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class AuthService {
  UserProfile? _cachedProfile;

  Future<UserProfile?> getCurrentUserProfile() async {
    // Offline: return a fixed local user profile
    _cachedProfile ??= UserProfile(
      id: 'local-user',
      email: 'local@animebytes.dev',
      fullName: 'Local User',
      avatarUrl: null,
      role: 'regular_user',
      isActive: true,
      dailyStreak: 0,
      lastLoginDate: null,
      preferredGenres: const [],
      favoriteCharacters: const [],
      pushNotificationsEnabled: true,
      darkModeEnabled: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    return _cachedProfile;
  }

  Future<void> signOut() async {}

  Future<UserProfile> updateUserProfile({
    String? fullName,
    String? avatarUrl,
    List<String>? preferredGenres,
    List<String>? favoriteCharacters,
    bool? pushNotificationsEnabled,
    bool? darkModeEnabled,
  }) async {
    final current = await getCurrentUserProfile();
    if (current == null) {
      throw Exception('No local user');
    }
    final updated = UserProfile(
      id: current.id,
      email: current.email,
      fullName: fullName ?? current.fullName,
      avatarUrl: avatarUrl ?? current.avatarUrl,
      role: current.role,
      isActive: current.isActive,
      dailyStreak: current.dailyStreak,
      lastLoginDate: current.lastLoginDate,
      preferredGenres: preferredGenres ?? current.preferredGenres,
      favoriteCharacters: favoriteCharacters ?? current.favoriteCharacters,
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? current.pushNotificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? current.darkModeEnabled,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );
    _cachedProfile = updated;
    return updated;
  }

  Future<void> updateDailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLogin = prefs.getString('last_login_date');
    final today = DateTime.now();
    int streak = prefs.getInt('daily_streak') ?? 0;

    if (lastLogin != null) {
      final last = DateTime.parse(lastLogin);
      final diff = today.difference(last).inDays;
      if (diff == 1) streak += 1; // consecutive day
      if (diff > 1) streak = 1; // reset
    } else {
      streak = 1; // first time
    }

    await prefs.setInt('daily_streak', streak);
    await prefs.setString('last_login_date', today.toIso8601String());
  }

  Future<void> resetPassword(String email) async {}

  bool get isAuthenticated => true;
}
