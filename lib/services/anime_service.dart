
import '../models/anime_story.dart';
import '../models/user_profile.dart';

import 'supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AnimeService {
  Future<void> unlikeStoryLocally(String storyId) async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getStringList('liked_stories') ?? [];
    liked.remove(storyId);
    await prefs.setStringList('liked_stories', liked);
  }

  Future<bool> unlikeStory(String storyId) async {
    final client = SupabaseService.instance.client;
    try {
      // Start a transaction by decrementing the like count
      final res = await client.rpc('decrement_like_count', params: {'story_id': storyId});
      if (res.error != null) throw res.error;

      // Record the unlike interaction
      await client.from('user_story_interactions').insert({
        'story_id': storyId,
        'interaction_type': 'unlike',
      }).select();

      // Remove from local liked
      await unlikeStoryLocally(storyId);
      return true;
    } catch (e) {
      print('Error unliking story: $e');
      return false;
    }
  }
  // Returns local like/save state for a story
  Future<Map<String, bool>> getLocalInteractions(String storyId) async {
    final liked = await isStoryLiked(storyId);
    final saved = await isStorySaved(storyId);
    return {'liked': liked, 'saved': saved};
  }

  // Like a story globally (Supabase) and locally (device)
  // Local saves
  Future<List<String>> getSavedStoryIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('saved_stories') ?? [];
  }

  Future<void> saveStoryLocally(String storyId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_stories') ?? [];
    if (!saved.contains(storyId)) {
      saved.add(storyId);
      await prefs.setStringList('saved_stories', saved);
    }
  }

  Future<void> unsaveStoryLocally(String storyId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_stories') ?? [];
    saved.remove(storyId);
    await prefs.setStringList('saved_stories', saved);
  }

  Future<bool> isStorySaved(String storyId) async {
    final saved = await getSavedStoryIds();
    return saved.contains(storyId);
  }

  // Local shares (optional, for analytics)
  Future<List<String>> getSharedStoryIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('shared_stories') ?? [];
  }

  Future<void> markStorySharedLocally(String storyId) async {
    final prefs = await SharedPreferences.getInstance();
    final shared = prefs.getStringList('shared_stories') ?? [];
    if (!shared.contains(storyId)) {
      shared.add(storyId);
      await prefs.setStringList('shared_stories', shared);
    }
  }

  // Local likes (to prevent multiple likes per device)
  Future<List<String>> getLikedStoryIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('liked_stories') ?? [];
  }

  Future<void> markStoryLikedLocally(String storyId) async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getStringList('liked_stories') ?? [];
    if (!liked.contains(storyId)) {
      liked.add(storyId);
      await prefs.setStringList('liked_stories', liked);
    }
  }

  Future<bool> isStoryLiked(String storyId) async {
    final liked = await getLikedStoryIds();
    return liked.contains(storyId);
  }

  Future<List<AnimeStory>> getDailyFeedStories({
    int limit = 20,
    int offset = 0,
    String? tag,
  }) async {
    final client = SupabaseService.instance.client;
    dynamic data;
    if (tag != null && tag.isNotEmpty) {
      data = await client
        .from('anime_stories')
        .select('*, story_tags!inner(tag_id), anime_tags:story_tags(anime_tags(*))')
        .eq('status', 'published')
        .eq('story_tags.tag_id', tag)
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);
    } else {
      data = await client
        .from('anime_stories')
        .select('*, anime_tags:story_tags(anime_tags(*))')
        .eq('status', 'published')
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);
    }
    if (data == null) return [];
    return (data as List).map((e) => AnimeStory.fromJson(e)).toList();
  }

  Future<List<AnimeTag>> getTrendingTags({int limit = 10}) async {
    final client = SupabaseService.instance.client;
    final data = await client
        .from('anime_tags')
        .select()
        .eq('is_trending', true)
        .order('usage_count', ascending: false)
        .limit(limit);
    if (data == null) return [];
    return (data as List).map((e) => AnimeTag.fromJson(e)).toList();
  }

  Future<AnimeStory?> getStoryById(String storyId) async {
    final client = SupabaseService.instance.client;
    final data = await client
        .from('anime_stories')
        .select('*, anime_tags:story_tags(anime_tags(*))')
        .eq('id', storyId)
        .single();
    if (data == null) return null;
    return AnimeStory.fromJson(data);
  }


  Future<List<AnimeStory>> getSavedStoriesLocal({int limit = 20, int offset = 0}) async {
    final client = SupabaseService.instance.client;
    final savedIds = await getSavedStoryIds();
    if (savedIds.isEmpty) return [];
    final data = await client
        .from('anime_stories')
        .select()
        .inFilter('id', savedIds)
        .range(offset, offset + limit - 1);
    if (data == null) return [];
    return (data as List).map((e) => AnimeStory.fromJson(e)).toList();
  }


  Future<List<AnimeStory>> getLikedStoriesLocal({int limit = 20, int offset = 0}) async {
    final client = SupabaseService.instance.client;
    final likedIds = await getLikedStoryIds();
    if (likedIds.isEmpty) return [];
    final data = await client
        .from('anime_stories')
        .select()
        .inFilter('id', likedIds)
        .range(offset, offset + limit - 1);
    if (data == null) return [];
    return (data as List).map((e) => AnimeStory.fromJson(e)).toList();
  }


  // Like/unlike toggle: global and local
  Future<bool> toggleLikeStory(String storyId) async {
    final client = SupabaseService.instance.client;
    final isLiked = await isStoryLiked(storyId);
    try {
      if (isLiked) {
        // Unlike: decrement like count, record unlike, update local
        final res = await client.rpc('decrement_like_count', params: {'story_id': storyId});
        if (res.error != null) throw res.error;
        await client.from('user_story_interactions').insert({
          'story_id': storyId,
          'interaction_type': 'unlike',
        }).select();
        await unlikeStoryLocally(storyId);
        return false;
      } else {
        // Like: increment like count, record like, update local
        final res = await client.rpc('increment_like_count', params: {'story_id': storyId});
        if (res.error != null) throw res.error;
        await client.from('user_story_interactions').insert({
          'story_id': storyId,
          'interaction_type': 'like',
        }).select();
        await markStoryLikedLocally(storyId);
        return true;
      }
    } catch (e) {
      print('Error toggling like: $e');
      return isLiked;
    }
  }

  // Save: both local and in database for analytics
  Future<bool> toggleSaveStory(String storyId) async {
    try {
      final client = SupabaseService.instance.client;
      if (await isStorySaved(storyId)) {
        // Remove from local storage
        await unsaveStoryLocally(storyId);
        
        // Record unsave interaction
        await client.from('user_story_interactions').insert({
          'story_id': storyId,
          'interaction_type': 'save',
        }).select();
        
        return false;
      } else {
        // Add to local storage
        await saveStoryLocally(storyId);
        
        // Record save interaction
        await client.from('user_story_interactions').insert({
          'story_id': storyId,
          'interaction_type': 'save',
        }).select();
        
        return true;
      }
    } catch (e) {
      print('Error toggling save status: $e');
      // Revert local changes if database operation failed
      if (await isStorySaved(storyId)) {
        await unsaveStoryLocally(storyId);
      } else {
        await saveStoryLocally(storyId);
      }
      return await isStorySaved(storyId);
    }
  }

  Future<void> recordStoryView(String storyId) async {
    try {
      final client = SupabaseService.instance.client;
      
      // Increment view count
      await client.rpc('increment_view_count', params: {'story_id': storyId});
      
      // Record the view interaction
      await client.from('user_story_interactions').insert({
        'story_id': storyId,
        'interaction_type': 'view',
      }).select();
    } catch (e) {
      print('Error recording story view: $e');
      // Don't throw - view count is non-critical
    }
  }



  Future<List<AnimeStory>> searchStories(String query,
      {int limit = 20, int offset = 0}) async {
    final client = SupabaseService.instance.client;
    final data = await client
        .from('anime_stories')
        .select('*, anime_tags:story_tags(anime_tags(*))')
        .ilike('title', '%$query%')
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);
    if (data == null) return [];
    return (data as List).map((e) => AnimeStory.fromJson(e)).toList();
  }

  Future<List<AnimeStory>> getStoriesByTag(String tagName,
      {int limit = 20, int offset = 0}) async {
    final client = SupabaseService.instance.client;
    final data = await client
        .from('anime_stories')
        .select('*, anime_tags:story_tags(anime_tags(*))')
        .contains('anime_tags', [tagName])
        .order('published_at', ascending: false)
        .range(offset, offset + limit - 1);
    if (data == null) return [];
    return (data as List).map((e) => AnimeStory.fromJson(e)).toList();
  }

  Future<List<AnimeTag>> getAllTags() async {
    final client = SupabaseService.instance.client;
    final data = await client.from('anime_tags').select();
    if (data == null) return [];
    return (data as List).map((e) => AnimeTag.fromJson(e)).toList();
  }
}
