import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isInitializing = true;
  String _loadingText = 'Initializing...';
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Initialize SharedPreferences
      setState(() => _loadingText = 'Loading preferences...');
      await Future.delayed(const Duration(milliseconds: 500));
      final prefs = await SharedPreferences.getInstance();

      // Check authentication status
      setState(() => _loadingText = 'Checking authentication...');
      await Future.delayed(const Duration(milliseconds: 500));
      final isAuthenticated = prefs.getBool('is_authenticated') ?? false;
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      // Load user preferences
      setState(() => _loadingText = 'Loading user settings...');
      await Future.delayed(const Duration(milliseconds: 500));
      await _loadUserPreferences(prefs);

      // Fetch trending anime tags
      setState(() => _loadingText = 'Fetching trending content...');
      await Future.delayed(const Duration(milliseconds: 500));
      await _fetchTrendingTags();

      // Prepare cached story content
      setState(() => _loadingText = 'Preparing stories...');
      await Future.delayed(const Duration(milliseconds: 500));
      await _prepareCachedContent();

      setState(() => _isInitializing = false);

      // Wait for animation to complete
      await _animationController.forward();
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate based on authentication status
      if (mounted) {
        _navigateToNextScreen(isAuthenticated, hasSeenOnboarding);
      }
    } catch (e) {
      // Handle initialization errors
      if (mounted) {
        _showRetryOption();
      }
    }
  }

  Future<void> _loadUserPreferences(SharedPreferences prefs) async {
    // Load theme preference
    final isDarkMode = prefs.getBool('dark_mode') ?? false;

    // Load favorite genres
    final favoriteGenres = prefs.getStringList('favorite_genres') ?? [];

    // Load notification settings
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    // Load login streak
    final loginStreak = prefs.getInt('login_streak') ?? 0;

    // Update last login date
    final now = DateTime.now();
    await prefs.setString('last_login', now.toIso8601String());
  }

  Future<void> _fetchTrendingTags() async {
    // Mock trending tags data
    final List<Map<String, dynamic>> trendingTags = [
      {"id": 1, "name": "Attack on Titan", "count": 1250, "trending": true},
      {"id": 2, "name": "Demon Slayer", "count": 980, "trending": true},
      {"id": 3, "name": "One Piece", "count": 2100, "trending": false},
      {"id": 4, "name": "Jujutsu Kaisen", "count": 850, "trending": true},
      {"id": 5, "name": "My Hero Academia", "count": 720, "trending": false},
      {"id": 6, "name": "Chainsaw Man", "count": 650, "trending": true},
      {"id": 7, "name": "Spy x Family", "count": 590, "trending": true},
      {"id": 8, "name": "Tokyo Revengers", "count": 480, "trending": false},
    ];

    // Cache trending tags
    final prefs = await SharedPreferences.getInstance();
    final tagsJson = trendingTags.map((tag) => tag.toString()).toList();
    await prefs.setStringList('cached_trending_tags', tagsJson);
  }

  Future<void> _prepareCachedContent() async {
    // Mock story content for caching
    final List<Map<String, dynamic>> storyContent = [
      {
        "id": 1,
        "title": "Attack on Titan Final Season Gets New Trailer",
        "summary":
            "Studio WIT releases stunning new footage showcasing the epic conclusion to Eren's journey.",
        "imageUrl":
            "https://images.unsplash.com/photo-1578662996442-48f60103fc96?fm=jpg&q=60&w=3000",
        "category": "News",
        "timestamp":
            DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        "likes": 1250,
        "isLiked": false,
        "isSaved": false,
        "tags": ["Attack on Titan", "Final Season", "Trailer"]
      },
      {
        "id": 2,
        "title": "Demon Slayer Movie Breaks Box Office Records",
        "summary":
            "Mugen Train becomes highest-grossing anime film worldwide with stunning animation quality.",
        "imageUrl":
            "https://images.unsplash.com/photo-1606918801925-e2c914c4b503?fm=jpg&q=60&w=3000",
        "category": "Box Office",
        "timestamp":
            DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        "likes": 980,
        "isLiked": false,
        "isSaved": false,
        "tags": ["Demon Slayer", "Movie", "Box Office"]
      },
      {
        "id": 3,
        "title": "Studio Ghibli Announces New Project",
        "summary":
            "Hayao Miyazaki returns with mysterious new film featuring environmental themes and magic.",
        "imageUrl":
            "https://images.unsplash.com/photo-1578662996442-48f60103fc96?fm=jpg&q=60&w=3000",
        "category": "Announcement",
        "timestamp":
            DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        "likes": 2100,
        "isLiked": false,
        "isSaved": false,
        "tags": ["Studio Ghibli", "Miyazaki", "New Project"]
      }
    ];

    // Cache story content
    final prefs = await SharedPreferences.getInstance();
    final contentJson = storyContent.map((story) => story.toString()).toList();
    await prefs.setStringList('cached_stories', contentJson);
  }

  void _navigateToNextScreen(bool isAuthenticated, bool hasSeenOnboarding) {
    String nextRoute;

    if (!hasSeenOnboarding) {
      nextRoute = '/onboarding-flow-screen';
    } else if (isAuthenticated) {
      nextRoute = '/daily-feed-screen';
    } else {
      nextRoute =
          '/daily-feed-screen'; // For demo purposes, go directly to feed
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  void _showRetryOption() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Connection Error',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Unable to initialize the app. Please check your internet connection and try again.',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeApp();
            },
            child: Text(
              'Retry',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F0F23),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // App Logo
                              Container(
                                width: 25.w,
                                height: 25.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.lightTheme.colorScheme.primary,
                                      AppTheme.lightTheme.colorScheme.secondary,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: 'play_circle_filled',
                                    color: Colors.white,
                                    size: 12.w,
                                  ),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              // App Name
                              Text(
                                'AnimeBytes',
                                style: AppTheme
                                    .lightTheme.textTheme.headlineMedium
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              // Tagline
                              Text(
                                'Your Daily Anime Stories',
                                style: AppTheme.lightTheme.textTheme.bodyLarge
                                    ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Loading Section
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Loading Indicator
                    SizedBox(
                      width: 8.w,
                      height: 8.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // Loading Text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _loadingText,
                        key: ValueKey(_loadingText),
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Version Info
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  'Version 1.0.0',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
