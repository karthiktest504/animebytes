import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:sizer/sizer.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/anime_story.dart';

class StoryCardWidget extends StatelessWidget {
  String _getAuthorInitial(AnimeStory story) {
    final name = _getAuthorName(story);
    if (name.isNotEmpty) return name[0].toUpperCase();
    return 'A';
  }

  String _getAuthorName(AnimeStory story) {
    // If you have author name in the story, use it. Otherwise fallback.
    // You can enhance this to fetch author name from a user profile if needed.
    return story.authorId ?? 'AnimeBot';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
  final AnimeStory story;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onTap;
  final bool isLiked;
  final bool isSaved;

  const StoryCardWidget({
    super.key,
    required this.story,
    required this.onLike,
    required this.onSave,
    required this.onShare,
    required this.onTap,
    this.isLiked = false,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 92.w,
        margin: EdgeInsets.symmetric(vertical: 2.5.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 3.2.h, horizontal: 4.5.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 18,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top row: news icon and time
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 0.7.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.13),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.article, color: Colors.amber, size: 13.sp),
                            SizedBox(width: 1.w),
                            Text('NEWS', style: TextStyle(fontSize: 9.sp, color: Colors.amber, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.white54, size: 11.sp),
                          SizedBox(width: 0.7.w),
                          Text(_formatTimeAgo(story.publishedAt), style: TextStyle(fontSize: 8.5.sp, color: Colors.white54)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 2.2.h),
                  // Title
                  Text(
                    story.title,
                    style: TextStyle(fontSize: 15.5.sp, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 1.1.h),
                  // Content or Summary
                  Text(
                    (story.content != null && story.content!.trim().isNotEmpty)
                        ? story.content!
                        : story.summary,
                    style: TextStyle(fontSize: 10.5.sp, color: Colors.white70, height: 1.4),
                  ),
                  SizedBox(height: 1.1.h),
                  // ...removed Read More button and spacing...
                  // Author row
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.amber,
                        radius: 15,
                        child: Text(_getAuthorInitial(story), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(width: 1.5.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AnimeBot', style: TextStyle(fontSize: 10.5.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                          Text('Curated Full Article', style: TextStyle(fontSize: 9.sp, color: Colors.white54)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 1.7.h),
                  // Divider
                  Divider(color: Colors.white12, thickness: 1),
                  SizedBox(height: 1.1.h),
                  // Action row
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.favorite_border,
                        activeIcon: Icons.favorite,
                        count: story.likeCount,
                        onPressed: onLike,
                        isActive: isLiked,
                      ),
                      SizedBox(width: 4.5.w),
                      _buildActionButton(
                        icon: Icons.bookmark_border,
                        activeIcon: Icons.bookmark,
                        onPressed: onSave,
                        isActive: isSaved,
                      ),
                      SizedBox(width: 4.5.w),
                      _buildActionButton(
                        icon: Icons.share_outlined,
                        activeIcon: Icons.share,
                        onPressed: () {
                          final text = 'Check out this story!\n\n${story.title}\n\n${story.summary}';
                          Share.share(text);
                        },
                        isActive: false,
                      ),
                      // Removed bottom right icon as requested
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryContent() {
    // You can add more story content here, e.g. title, summary, etc.
    return Container();
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Like button
        _buildActionButton(
          icon: Icons.favorite_border,
          activeIcon: Icons.favorite,
          count: story.likeCount,
          onPressed: onLike,
          isActive: isLiked,
        ),
        SizedBox(width: 6.w),
        // Save button
        _buildActionButton(
          icon: Icons.bookmark_border,
          activeIcon: Icons.bookmark,
          count: story.saveCount,
          onPressed: onSave,
          isActive: isSaved,
        ),
        SizedBox(width: 6.w),
        // Share button
        _buildActionButton(
          icon: Icons.share_outlined,
          activeIcon: Icons.share,
          count: story.shareCount,
          onPressed: () {
            final text = 'Check out this story!\n\n${story.title}\n\n${story.summary}';
            Share.share(text);
          },
          isActive: false,
        ),
        const Spacer(),
        // View count
        Row(
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 16.sp,
              color: Colors.white70,
            ),
            SizedBox(width: 1.w),
            Text(
              _formatCount(story.viewCount),
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required IconData activeIcon,
    int? count,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1.0, end: isActive ? 1.18 : 1.0),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.7.h),
            decoration: BoxDecoration(
              color: isActive ? Colors.red.withOpacity(0.13) : Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Transform.scale(
                  scale: scale,
                  child: Icon(
                    isActive ? activeIcon : icon,
                    size: 19.sp,
                    color: isActive ? Colors.red : Colors.white,
                  ),
                ),
                if (count != null) ...[
                  SizedBox(height: 0.3.h),
                  Text(
                    _formatCount(count),
                    style: TextStyle(
                      fontSize: 9.5.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTagsRow() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: story.tags!.take(3).map((tag) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withAlpha(77)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tag.iconEmoji,
                style: TextStyle(fontSize: 12.sp),
              ),
              SizedBox(width: 1.w),
              Text(
                tag.displayName,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}
