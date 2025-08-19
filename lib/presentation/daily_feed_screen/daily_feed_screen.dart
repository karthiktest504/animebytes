import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'dart:ui';

import '../../core/app_export.dart';
import '../../models/anime_story.dart';
import '../../models/user_profile.dart';
import '../../services/anime_service.dart';
import '../../services/auth_service.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/side_navigation_drawer.dart';
import './widgets/story_card_widget.dart';
import './widgets/trending_tags_widget.dart';

class DailyFeedScreen extends StatefulWidget {
  const DailyFeedScreen({super.key});

  @override
  State<DailyFeedScreen> createState() => _DailyFeedScreenState();
}

class _DailyFeedScreenState extends State<DailyFeedScreen> {
  final AnimeService _animeService = AnimeService();
  late AuthService _authService;
  final PageController _pageController = PageController();
  bool _isNavigating = false;

  List<AnimeStory> _stories = [];
  List<AnimeTag> _trendingTags = [];
  UserProfile? _userProfile;
  int _currentStoryIndex = 0;
  bool _isLoading = true;
  String? _selectedTag; // This will now store the tag UUID
  List<String> _preferredGenres = const [];
  Map<String, Map<String, bool>> _storyLocalInteractions = {};

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _loadInitialData();
    _loadUserProfile();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);

      // Load onboarding preferences to personalize feed
      final prefs = await SharedPreferences.getInstance();
      _preferredGenres = prefs.getStringList('selected_genres') ?? const [];
      
      print('Fetching stories...');  // Debug log

      final stories = await _animeService.getDailyFeedStories(
        limit: 20,
        tag: _selectedTag,
      );
      final trendingTags = await _animeService.getTrendingTags(limit: 10);
      // No real user profile needed for no-auth mode
      Map<String, Map<String, bool>> localInteractions = {};
      for (final s in stories) {
        localInteractions[s.id] = await _animeService.getLocalInteractions(s.id);
      }
      setState(() {
        _stories = stories;
        _trendingTags = trendingTags;
        _storyLocalInteractions = localInteractions;
        _isLoading = false;
      });

      // Prefetch images to reduce frame drops when swiping
      if (mounted) {
        for (final s in _stories) {
          final url = s.imageUrl;
          if (url != null && url.isNotEmpty) {
            precacheImage(CachedNetworkImageProvider(url), context);
          }
        }
      }
    } catch (error, stackTrace) {
      print('Error loading data: $error');  // Debug log
      print('Stack trace: $stackTrace');    // Debug log
      setState(() => _isLoading = false);
      _showError('Failed to load content: $error');
    }
  }

  Future<void> _updateDailyStreak() async {
    try {
      await _authService.updateDailyStreak();
    } catch (error) {
      // Silent fail for streak update
    }
  }

  Future<void> _onTagSelected(String? tagName) async {
    setState(() {
      _selectedTag = tagName; // tagName is now the tag UUID
      _currentStoryIndex = 0;
    });
    await _loadInitialData();
    _pageController.animateToPage(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _onStoryInteraction(
      String storyId, String interactionType) async {
    try {
      bool result = false;
      if (interactionType == 'like') {
        result = await _animeService.toggleLikeStory(storyId);
      } else if (interactionType == 'save') {
        result = await _animeService.toggleSaveStory(storyId);
      }
      // Reload the story and local interaction state for real-time update
      final updatedStory = await _animeService.getStoryById(storyId);
      final updatedInteraction = await _animeService.getLocalInteractions(storyId);
      setState(() {
        final storyIndex = _stories.indexWhere((story) => story.id == storyId);
        if (storyIndex != -1 && updatedStory != null) {
          _stories[storyIndex] = updatedStory;
          _storyLocalInteractions[storyId] = updatedInteraction;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result
              ? (interactionType == 'like'
                  ? ((_storyLocalInteractions[storyId]?['liked'] ?? false) ? 'Liked story!' : 'Unliked story!')
                  : 'Saved story!')
              : (interactionType == 'like' ? 'Unliked story!' : 'Unsaved story!')),
          duration: const Duration(seconds: 1)));
    } catch (error) {
      _showError('Failed to $interactionType story');
    }
  }

  void _onPageChanged(int index) async {
    setState(() {
      _currentStoryIndex = index;
    });
    if (index < _stories.length) {
      final story = _stories[index];
      await _animeService.recordStoryView(story.id);
      // Optionally reload story for real-time view count
      final updatedStory = await _animeService.getStoryById(story.id);
      if (updatedStory != null) {
        setState(() {
          _stories[index] = updatedStory;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
      drawer: SideNavigationDrawer(userProfile: _userProfile),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: AppBar(
              backgroundColor: Colors.black.withOpacity(0.55),
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: Row(children: [
                Icon(Icons.blur_on, color: Colors.amberAccent, size: 18.sp),
                SizedBox(width: 2.w),
                Text('AnimeBytes',
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ]),
              actions: [
                if (_userProfile != null)
                  Padding(
                    padding: EdgeInsets.only(right: 4.w),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/profile-settings-screen');
                        },
                        child: CircleAvatar(
                          radius: 16.sp,
                          backgroundColor: Colors.white.withAlpha(26),
                          child: Icon(Icons.account_circle, size: 18.sp, color: Colors.white),
                        ),
                      ),
                  ),
              ],
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              'https://qtrypzzcjebvfcihiynt.supabase.co/storage/v1/object/public/base44-prod/public/367ba39f1_bgbg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Main content
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _stories.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        // Trending tags section
                        Container(
                          margin: EdgeInsets.only(top: 12.h),
                          child: TrendingTagsWidget(
                            tags: _trendingTags,
                            selectedTag: _selectedTag,
                            onTagSelected: _onTagSelected,
                          ),
                        ),
                        // Stories section
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            scrollDirection: Axis.vertical,
                            onPageChanged: _onPageChanged,
                            itemCount: _stories.length,
                            itemBuilder: (context, index) {
                              final story = _stories[index];
                              final interaction = _storyLocalInteractions[story.id] ?? {'liked': false, 'saved': false};
                              return StoryCardWidget(
                                story: story,
                                isLiked: interaction['liked'] ?? false,
                                isSaved: interaction['saved'] ?? false,
                                onLike: () => _onStoryInteraction(story.id, 'like'),
                                onSave: () => _onStoryInteraction(story.id, 'save'),
                                onShare: () => _onStoryInteraction(story.id, 'share'),
                                onTap: () {
                                  if (_isNavigating) return;
                                  _isNavigating = true;
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.storyDetail,
                                    arguments: story.id,
                                  ).whenComplete(() {
                                    _isNavigating = false;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        // Progress indicator
                        ProgressIndicatorWidget(
                          currentIndex: _currentStoryIndex,
                          progress: _stories.isNotEmpty ? (_currentStoryIndex + 1) / _stories.length : 0.0,
                          totalStories: _stories.length,
                        ),
                      ],
                    ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.help_outline, size: 64.sp, color: Colors.grey),
      SizedBox(height: 2.h),
      Text('No stories available',
          style: TextStyle(fontSize: 18.sp, color: Colors.grey[600])),
      SizedBox(height: 1.h),
      Text(
          _selectedTag != null
              ? 'Try selecting a different tag'
              : 'Check back later for updates',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
      if (_selectedTag != null) ...[
        SizedBox(height: 2.h),
        ElevatedButton(
            onPressed: () => _onTagSelected(null),
            child: const Text('Show All Stories')),
      ],
    ]));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}