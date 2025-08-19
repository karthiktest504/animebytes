import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../models/anime_story.dart';
import '../../models/user_profile.dart';
import '../../services/anime_service.dart';
import '../../services/auth_service.dart';
import './widgets/reading_progress_indicator.dart';
import './widgets/related_stories_carousel.dart';
import './widgets/story_action_bar.dart';
import './widgets/story_content_section.dart';
import './widgets/story_hero_header.dart';

class StoryDetailScreen extends StatefulWidget {
  const StoryDetailScreen({super.key});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final AnimeService _animeService = AnimeService();
  final AuthService _authService = AuthService();
  AnimeStory? _story;
  UserProfile? _userProfile;
  bool _isLiked = false;
  bool _isSaved = false;
  int _likeCount = 0;
  double _readingProgress = 0.0;
  bool _showProgress = false;
  bool _isLoading = true;


  // Only one initState should exist. If you see another initState below, remove it.

  // Remove any duplicate initState below (if present)

  Future<void> _loadStory() async {
    setState(() => _isLoading = true);
    final args = ModalRoute.of(context)?.settings.arguments;
    String? storyId;
    if (args is String) {
      storyId = args;
    }
    final userProfile = await _authService.getCurrentUserProfile();
    AnimeStory? story;
    Map<String, bool> interaction = {'liked': false, 'saved': false};
    if (storyId != null) {
      story = await _animeService.getStoryById(storyId);
      if (userProfile != null && story != null) {
        interaction = await _animeService.getLocalInteractions(story.id);
      }
    }
    setState(() {
      _story = story;
      _userProfile = userProfile;
      _isLiked = interaction['liked'] ?? false;
      _isSaved = interaction['saved'] ?? false;
      _likeCount = story?.likeCount ?? 0;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStory().then((_) {
        if (_story != null) {
          _animeService.recordStoryView(_story!.id);
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll > 0) {
      final progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
      setState(() {
        _readingProgress = progress;
        _showProgress = progress > 0.1;
      });
    }
  }

  Future<void> _handleLike() async {
    if (_userProfile == null || _story == null) return;
    final result = await _animeService.toggleLikeStory(_story!.id);
    await _loadStory();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result ? 'Liked story!' : 'Unliked story!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_userProfile == null || _story == null) return;
  final result = await _animeService.toggleSaveStory(_story!.id);
    await _loadStory();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result ? 'Story saved!' : 'Story removed from saved'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleShare() {
    // Simulate share functionality
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Story shared successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleComment() {
    // Navigate to comments or show comment sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCommentSheet(),
    );
  }

  void _handleRelatedStoryTap(Map<String, dynamic> story) {
    // Navigate to the related story with its id to avoid route loops
    Navigator.pushNamed(
      context,
      AppRoutes.storyDetail,
      arguments: story['id'],
    );
  }

  Future<void> _handleRefresh() async {
    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_story == null) {
      return Scaffold(
        body: Center(child: Text('Story not found')),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background image with blur and dark overlay (matching story card)
          Positioned.fill(
            child: Stack(
              children: [
                if (_story!.imageUrl != null)
                  Image.network(
                    _story!.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.center,
                    cacheWidth: MediaQuery.of(context).size.width.toInt(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: colorScheme.surface,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colorScheme.surface,
                      child: Center(
                        child: Icon(
                          Icons.error_outline,
                          color: colorScheme.error,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content
          RefreshIndicator(
            onRefresh: _loadStory,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                StoryHeroHeader(
                  imageUrl: _story!.imageUrl ?? '',
                  title: _story!.title,
                  publishDate: _story!.publishedAt.toIso8601String(),
                  source: _story!.authorId ?? '',
                  scrollController: _scrollController,
                ),
                StoryContentSection(
                  content: _story!.content ?? '',
                  tags: (_story!.tags ?? []).map((t) => t.displayName).toList(),
                ),
                // TODO: RelatedStoriesCarousel can be implemented with real data
                SliverToBoxAdapter(
                  child: SizedBox(height: 10.h),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReadingProgressIndicator(
                  progress: _readingProgress,
                  isVisible: _showProgress,
                ),
                StoryActionBar(
                  isLiked: _isLiked,
                  isSaved: _isSaved,
                  likeCount: _likeCount,
                  onLike: _handleLike,
                  onSave: _handleSave,
                  onShare: _handleShare,
                  onComment: _handleComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSheet() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 60.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 1.h),
            width: 12.w,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: colorScheme.onSurface,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'comment',
                    color: colorScheme.onSurfaceVariant,
                    size: 48,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No comments yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Be the first to share your thoughts!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        // Handle comment submission
                      },
                      icon: CustomIconWidget(
                        iconName: 'send',
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
