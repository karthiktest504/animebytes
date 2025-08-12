import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/account_section_widget.dart';
import './widgets/app_preferences_widget.dart';
import './widgets/daily_streak_widget.dart';
import './widgets/feedback_section_widget.dart';
import './widgets/notification_settings_widget.dart';
import './widgets/personalization_section_widget.dart';
import './widgets/profile_header_widget.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  // User Profile Data
  final String _username = 'AnimeOtaku2024';
  final String _avatarUrl =
      'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1';
  final int _currentStreak = 15;
  final int _longestStreak = 42;

  // Personalization Settings
  List<String> _selectedAnime = [
    'Attack on Titan',
    'Demon Slayer',
    'One Piece'
  ];
  List<String> _selectedGenres = ['Action', 'Adventure', 'Fantasy'];
  List<String> _selectedCharacters = [
    'Goku',
    'Naruto Uzumaki',
    'Tanjiro Kamado'
  ];

  // Notification Settings
  bool _pushAlertsEnabled = true;
  bool _trendingAlertsEnabled = true;
  bool _dailyDigestEnabled = true;
  String _digestTime = '8:00 AM';

  // App Preferences
  bool _darkModeEnabled = false;
  bool _autoPlayEnabled = true;
  double _readingSpeed = 1.0;

  // Account Data
  final String _referralCode = 'ANIME2024XYZ';
  final int _totalRewards = 1250;
  // Removed invite/friends logic

  // Daily Streak Data
  final int _nextBadgeProgress = 15;
  final int _nextBadgeTarget = 30;
  final List<Map<String, dynamic>> _badges = [
    {
      'name': 'Rookie',
      'emoji': '🌟',
      'requirement': 7,
      'unlocked': true,
    },
    {
      'name': 'Dedicated',
      'emoji': '🔥',
      'requirement': 14,
      'unlocked': true,
    },
    {
      'name': 'Champion',
      'emoji': '🏆',
      'requirement': 30,
      'unlocked': false,
    },
    {
      'name': 'Legend',
      'emoji': '👑',
      'requirement': 60,
      'unlocked': false,
    },
    {
      'name': 'Master',
      'emoji': '⚡',
      'requirement': 100,
      'unlocked': false,
    },
  ];

  int _currentBottomBarIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkModeEnabled = prefs.getBool('dark_mode') ?? false;
      _pushAlertsEnabled = prefs.getBool('push_alerts') ?? true;
      _trendingAlertsEnabled = prefs.getBool('trending_alerts') ?? true;
      _dailyDigestEnabled = prefs.getBool('daily_digest') ?? true;
      _digestTime = prefs.getString('digest_time') ?? '8:00 AM';
      _autoPlayEnabled = prefs.getBool('auto_play') ?? true;
      _readingSpeed = prefs.getDouble('reading_speed') ?? 1.0;
      _selectedAnime = prefs.getStringList('selected_anime') ??
          ['Attack on Titan', 'Demon Slayer', 'One Piece'];
      _selectedGenres = prefs.getStringList('selected_genres') ??
          ['Action', 'Adventure', 'Fantasy'];
      _selectedCharacters = prefs.getStringList('selected_characters') ??
          ['Goku', 'Naruto Uzumaki', 'Tanjiro Kamado'];
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _darkModeEnabled);
    await prefs.setBool('push_alerts', _pushAlertsEnabled);
    await prefs.setBool('trending_alerts', _trendingAlertsEnabled);
    await prefs.setBool('daily_digest', _dailyDigestEnabled);
    await prefs.setString('digest_time', _digestTime);
    await prefs.setBool('auto_play', _autoPlayEnabled);
    await prefs.setDouble('reading_speed', _readingSpeed);
    await prefs.setStringList('selected_anime', _selectedAnime);
    await prefs.setStringList('selected_genres', _selectedGenres);
    await prefs.setStringList('selected_characters', _selectedCharacters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.maybePop(context);
          },
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: CustomIconWidget(
              iconName: 'logout',
              color: colorScheme.error,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            ProfileHeaderWidget(
              username: _username,
              avatarUrl: _avatarUrl,
              currentStreak: _currentStreak,
              longestStreak: _longestStreak,
            ),
            SizedBox(height: 4.h),
            PersonalizationSectionWidget(
              selectedAnime: _selectedAnime,
              selectedGenres: _selectedGenres,
              selectedCharacters: _selectedCharacters,
              onAnimeChanged: (anime) {
                setState(() {
                  _selectedAnime = anime;
                });
                _saveSettings();
              },
              onGenresChanged: (genres) {
                setState(() {
                  _selectedGenres = genres;
                });
                _saveSettings();
              },
              onCharactersChanged: (characters) {
                setState(() {
                  _selectedCharacters = characters;
                });
                _saveSettings();
              },
            ),
            SizedBox(height: 4.h),
            NotificationSettingsWidget(
              pushAlertsEnabled: _pushAlertsEnabled,
              trendingAlertsEnabled: _trendingAlertsEnabled,
              dailyDigestEnabled: _dailyDigestEnabled,
              digestTime: _digestTime,
              onPushAlertsChanged: (value) {
                setState(() {
                  _pushAlertsEnabled = value;
                });
                _saveSettings();
              },
              onTrendingAlertsChanged: (value) {
                setState(() {
                  _trendingAlertsEnabled = value;
                });
                _saveSettings();
              },
              onDailyDigestChanged: (value) {
                setState(() {
                  _dailyDigestEnabled = value;
                });
                _saveSettings();
              },
              onDigestTimeChanged: (time) {
                setState(() {
                  _digestTime = time;
                });
                _saveSettings();
              },
            ),
            SizedBox(height: 4.h),
            AppPreferencesWidget(
              darkModeEnabled: _darkModeEnabled,
              autoPlayEnabled: _autoPlayEnabled,
              readingSpeed: _readingSpeed,
              onDarkModeChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
                _saveSettings();
                _showThemeChangeSnackBar();
              },
              onAutoPlayChanged: (value) {
                setState(() {
                  _autoPlayEnabled = value;
                });
                _saveSettings();
              },
              onReadingSpeedChanged: (speed) {
                setState(() {
                  _readingSpeed = speed;
                });
                _saveSettings();
              },
            ),
            SizedBox(height: 4.h),
            // Removed AccountSectionWidget (invite/friends logic)
            SizedBox(height: 4.h),
            DailyStreakWidget(
              currentStreak: _currentStreak,
              longestStreak: _longestStreak,
              badges: _badges,
              nextBadgeProgress: _nextBadgeProgress,
              nextBadgeTarget: _nextBadgeTarget,
            ),
            SizedBox(height: 4.h),
            FeedbackSectionWidget(
              onFeedbackSubmitted: () {
                // Handle feedback submission
              },
            ),
            SizedBox(height: 10.h), // Bottom padding for navigation
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomBarIndex,
        onTap: (index) {
          setState(() {
            _currentBottomBarIndex = index;
          });
          _handleBottomNavigation(index);
        },
        variant: BottomBarVariant.standard,
        showLabels: true,
      ),
    );
  }

  void _handleBottomNavigation(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/daily-feed-screen');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/saved-stories-screen');
        break;
      case 2:
        // Current screen - do nothing
        break;
    }
  }

  // Removed invite/friends logic

  // Removed rewards and invite/friends logic

  void _showThemeChangeSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _darkModeEnabled
              ? 'Dark mode enabled! Restart app to see full changes.'
              : 'Light mode enabled! Restart app to see full changes.',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Logout',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to logout? Your settings will be saved.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Logout',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performLogout() {
    // Clear user session and navigate to splash screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/splash-screen',
      (route) => false,
    );
  }
}
