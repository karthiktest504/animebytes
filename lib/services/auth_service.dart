import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import 'supabase_service.dart';

class AuthService extends ChangeNotifier {
  UserProfile? _cachedProfile;
  User? _currentUser;
  bool _isLoading = false;

  // Getters
  UserProfile? get currentUserProfile => _cachedProfile;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // Supabase client
  SupabaseClient get _client => SupabaseService.instance.client;

  AuthService() {
    _initAuthListener();
  }

  void _initAuthListener() {
    // Listen to auth state changes
    _client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      
      print('Auth state changed: $event');
      
      if (session?.user != null) {
        _currentUser = session!.user;
        _loadUserProfile();
      } else {
        _currentUser = null;
        _cachedProfile = null;
      }
      
      notifyListeners();
    });

    // Check initial session
    final session = _client.auth.currentSession;
    if (session?.user != null) {
      _currentUser = session!.user;
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser == null) return;
    
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', _currentUser!.id)
          .single();
      
      _cachedProfile = UserProfile.fromJson(response);
      notifyListeners();
    } catch (e) {
      print('Error loading user profile: $e');
      // Create profile if it doesn't exist
      await _createUserProfile();
    }
  }

  Future<void> _createUserProfile() async {
    if (_currentUser == null) return;
    
    try {
      final profileData = {
        'id': _currentUser!.id,
        'email': _currentUser!.email ?? '',
        'full_name': _currentUser!.userMetadata?['full_name'] ?? 
                     _currentUser!.userMetadata?['name'] ?? 
                     'Anime Fan',
        'avatar_url': _currentUser!.userMetadata?['avatar_url'] ?? 
                      _currentUser!.userMetadata?['picture'],
        'role': 'regular_user',
        'is_active': true,
        'daily_streak': 0,
        'preferred_genres': <String>[],
        'favorite_characters': <String>[],
        'push_notifications_enabled': true,
        'dark_mode_enabled': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('user_profiles').insert(profileData);
      _cachedProfile = UserProfile.fromJson(profileData);
      notifyListeners();
    } catch (e) {
      print('Error creating user profile: $e');
    }
  }

  // Email/Password Authentication
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _createUserProfile();
      }

      return response;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = response.user;
        await _loadUserProfile();
      }

      return response;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Social Authentication
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _client.auth.signInWithOAuth(
        Provider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signInWithApple() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _client.auth.signInWithOAuth(
        Provider.apple,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Password Reset
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _client.auth.signOut();
      _currentUser = null;
      _cachedProfile = null;
      
      // Clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update User Profile
  Future<UserProfile> updateUserProfile({
    String? fullName,
    String? avatarUrl,
    List<String>? preferredGenres,
    List<String>? favoriteCharacters,
    bool? pushNotificationsEnabled,
    bool? darkModeEnabled,
  }) async {
    if (_currentUser == null || _cachedProfile == null) {
      throw Exception('No authenticated user');
    }

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (preferredGenres != null) updates['preferred_genres'] = preferredGenres;
      if (favoriteCharacters != null) updates['favorite_characters'] = favoriteCharacters;
      if (pushNotificationsEnabled != null) updates['push_notifications_enabled'] = pushNotificationsEnabled;
      if (darkModeEnabled != null) updates['dark_mode_enabled'] = darkModeEnabled;

      await _client
          .from('user_profiles')
          .update(updates)
          .eq('id', _currentUser!.id);

      // Reload profile
      await _loadUserProfile();
      return _cachedProfile!;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDailyStreak() async {
    if (_currentUser == null) return;

    try {
      final today = DateTime.now();
      final lastLoginKey = 'last_login_${_currentUser!.id}';
      final streakKey = 'daily_streak_${_currentUser!.id}';
      
      final prefs = await SharedPreferences.getInstance();
      final lastLoginStr = prefs.getString(lastLoginKey);
      int currentStreak = prefs.getInt(streakKey) ?? 0;

      if (lastLoginStr != null) {
        final lastLogin = DateTime.parse(lastLoginStr);
        final daysDiff = today.difference(lastLogin).inDays;
        
        if (daysDiff == 1) {
          currentStreak += 1;
        } else if (daysDiff > 1) {
          currentStreak = 1;
        }
        // If daysDiff == 0, same day login, no change to streak
      } else {
        currentStreak = 1; // First login
      }

      await prefs.setString(lastLoginKey, today.toIso8601String());
      await prefs.setInt(streakKey, currentStreak);

      // Update profile in database
      await _client
          .from('user_profiles')
          .update({
            'daily_streak': currentStreak,
            'last_login_date': today.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _currentUser!.id);

      // Reload profile to reflect changes
      await _loadUserProfile();
    } catch (e) {
      print('Error updating daily streak: $e');
    }
  }

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    if (_cachedProfile != null) return _cachedProfile;
    if (_currentUser != null) {
      await _loadUserProfile();
    }
    return _cachedProfile;
  }
}