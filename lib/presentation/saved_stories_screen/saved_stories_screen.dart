import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/anime_story.dart';
import '../../models/user_profile.dart';
import '../../services/anime_service.dart';
import '../../services/auth_service.dart';
import './widgets/empty_saved_state.dart';
import './widgets/filter_chips_row.dart';
import './widgets/saved_story_card.dart';
import './widgets/search_bar_widget.dart';

class SavedStoriesScreen extends StatefulWidget {
  const SavedStoriesScreen({super.key});

  @override
  State<SavedStoriesScreen> createState() => _SavedStoriesScreenState();
}

class _SavedStoriesScreenState extends State<SavedStoriesScreen> {
  final AnimeService _animeService = AnimeService();
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();

  List<AnimeStory> _stories = [];
  List<AnimeStory> _filteredStories = [];
  List<AnimeTag> _allTags = [];
  UserProfile? _userProfile;
  SavedStoriesFilter _selectedFilter = SavedStoriesFilter.all;
  String _searchQuery = '';
  bool _isLoading = true;
  String _viewType = 'saved'; // 'saved' or 'liked'

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments as String?;
      if (arguments == 'liked') {
        setState(() => _viewType = 'liked');
      }
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);

      final userProfile = await _authService.getCurrentUserProfile();
      if (userProfile == null) {
        setState(() => _isLoading = false);
        return;
      }

      final futures = await Future.wait([
      _viewType == 'saved'
        ? _animeService.getSavedStoriesLocal(limit: 20)
        : _animeService.getLikedStoriesLocal(limit: 20),
        _animeService.getAllTags(),
      ]);

      setState(() {
        _userProfile = userProfile;
        _stories = futures[0] as List<AnimeStory>;
        _allTags = futures[1] as List<AnimeTag>;
        _filteredStories = _stories;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      _showError('Failed to load ${_viewType} stories: $error');
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more stories if needed
      _loadMoreStories();
    }
  }

  Future<void> _loadMoreStories() async {
    if (_userProfile == null) return;

    try {
      final moreStories = _viewType == 'saved'
            ? await _animeService.getSavedStoriesLocal(limit: 20, offset: _stories.length)
            : await _animeService.getLikedStoriesLocal(limit: 20, offset: _stories.length);

      if (moreStories.isNotEmpty) {
        setState(() {
          _stories.addAll(moreStories);
          _applyFilters();
        });
      }
    } catch (error) {
      _showError('Failed to load more stories');
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _applyFilters();
    });
  }

  void _onFilterSelected(SavedStoriesFilter filter) {
    setState(() {
      _selectedFilter = filter;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<AnimeStory> filtered = List<AnimeStory>.from(_stories);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((story) {
        return story.title.toLowerCase().contains(_searchQuery) ||
            story.summary.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // Apply enum-based filter
    switch (_selectedFilter) {
      case SavedStoriesFilter.all:
        // No additional filtering
        break;
      case SavedStoriesFilter.dateSaved:
        // Sort by createdAt descending as a proxy for "recently saved"
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SavedStoriesFilter.animeSeries:
        // Requires series metadata; keeping as no-op for now
        break;
      case SavedStoriesFilter.readingStatus:
        // Placeholder; no-op until reading status is available
        break;
      case SavedStoriesFilter.unread:
        // Placeholder; no-op until read status is available
        break;
      case SavedStoriesFilter.read:
        // Placeholder; no-op until read status is available
        break;
    }

    setState(() => _filteredStories = filtered);
  }

  Future<void> _onStoryRemoved(String storyId) async {
    try {
      if (_viewType == 'saved') {
        await _animeService.toggleSaveStory(storyId);
      } else {
        await _animeService.likeStory(storyId);
      }
      setState(() {
        _stories.removeWhere((story) => story.id == storyId);
        _filteredStories.removeWhere((story) => story.id == storyId);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Story removed from ${_viewType} items'),
          duration: const Duration(seconds: 2)));
    } catch (error) {
      _showError('Failed to remove story');
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
        backgroundColor:
            Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
                onPressed: () => Navigator.pop(context)),
            title: Text(
                _viewType == 'saved' ? 'Saved Stories' : 'Liked Stories',
                style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)),
            actions: [
              // Switch between saved and liked
              PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black),
                  onSelected: (value) {
                    if (value != _viewType) {
                      setState(() => _viewType = value);
                      _loadInitialData();
                    }
                  },
                  itemBuilder: (context) => [
                        PopupMenuItem(
                            value: 'saved',
                            child: Row(children: [
                              Icon(Icons.bookmark_outline,
                                  color: _viewType == 'saved'
                                      ? Colors.blue
                                      : null),
                              SizedBox(width: 2.w),
                              Text('Saved Stories'),
                            ])),
                        PopupMenuItem(
                            value: 'liked',
                            child: Row(children: [
                              Icon(Icons.favorite_outline,
                                  color:
                                      _viewType == 'liked' ? Colors.red : null),
                              SizedBox(width: 2.w),
                              Text('Liked Stories'),
                            ])),
                      ]),
            ]),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _userProfile == null
                ? _buildSignInPrompt()
                : Column(children: [
                    // Search bar
                    Padding(
                        padding: EdgeInsets.all(4.w),
                        child:
                            SearchBarWidget(onSearchChanged: _onSearchChanged)),

                    // Filter chips
                    if (_allTags.isNotEmpty)
                      FilterChipsRow(
                        selectedFilter: _selectedFilter,
                        onFilterChanged: _onFilterSelected,
                      ),

                    // Results count
                    if (_filteredStories.isNotEmpty)
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 1.h),
                          child: Row(children: [
                            Text(
                                '${_filteredStories.length} ${_viewType} ${_filteredStories.length == 1 ? 'story' : 'stories'}',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500)),
                          ])),

                    // Stories list
                    Expanded(
                        child: _filteredStories.isEmpty
                            ? EmptySavedState(
                                onGoToFeed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRoutes.dailyFeed,
                                    (route) => false,
                                  );
                                },
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                itemCount: _filteredStories.length,
                                itemBuilder: (context, index) {
                                  return SavedStoryCard(
                                      story: _filteredStories[index],
                                      viewType: _viewType,
                                      onRemove: () => _onStoryRemoved(
                                          _filteredStories[index].id),
                                      onTap: () => Navigator.pushNamed(
                                          context, AppRoutes.storyDetail,
                                          arguments:
                                              _filteredStories[index].id));
                                })),
                  ]));
  }

  Widget _buildSignInPrompt() {
    return Center(
        child: Padding(
            padding: EdgeInsets.all(6.w),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.account_circle_outlined,
                  size: 80.sp, color: Colors.grey),
              SizedBox(height: 3.h),
              Text('Sign In Required',
                  style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)),
              SizedBox(height: 2.h),
              Text(
                  'Sign in to view your ${_viewType} stories and sync across devices.',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  textAlign: TextAlign.center),
              SizedBox(height: 4.h),
              ElevatedButton(
                  onPressed: () {
                    // Navigate to auth screen when implemented
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Authentication screen coming soon!')));
                  },
                  style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25))),
                  child: Text('Sign In',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w600))),
            ])));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}