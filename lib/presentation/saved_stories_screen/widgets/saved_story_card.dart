import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/anime_story.dart';
import '../../../theme/app_theme.dart';

class SavedStoryCard extends StatelessWidget {
  final AnimeStory story;
  final String viewType;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const SavedStoryCard({
    super.key,
    required this.story,
    required this.viewType,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Story image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  color: Colors.grey[300],
                  child: story.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: story.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.image, color: Colors.grey[500]),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: Icon(Icons.broken_image,
                                color: Colors.grey[500]),
                          ),
                        )
                      : Icon(Icons.help_outline,
                          color: Colors.grey[500], size: 8.w),
                ),
              ),

              SizedBox(width: 3.w),

              // Story content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      story.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 1.h),

                    // Summary
                    Text(
                      story.summary,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 1.h),

                    // Tags and metadata
                    Row(
                      children: [
                        // Featured badge
                        if (story.isFeatured)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.3.h),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'FEATURED',
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                        if (story.isFeatured) SizedBox(width: 2.w),

                        // First tag
                        if (story.tags != null && story.tags!.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.3.h),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(26),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: Colors.blue.withAlpha(77)),
                            ),
                            child: Text(
                              '${story.tags!.first.iconEmoji} ${story.tags!.first.displayName}',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                              ),
                            ),
                          ),

                        const Spacer(),

                        // Stats
                        _buildStatChip(
                          icon: Icons.visibility_outlined,
                          count: story.viewCount,
                          color: Colors.grey,
                        ),
                      ],
                    ),

                    SizedBox(height: 1.h),

                    // Actions row
                    Row(
                      children: [
                        // Published date
                        Text(
                          _formatDate(story.publishedAt),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[500],
                          ),
                        ),

                        const Spacer(),

                        // Action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildStatChip(
                              icon: Icons.favorite_outline,
                              count: story.likeCount,
                              color: Colors.red,
                            ),
                            SizedBox(width: 2.w),
                            _buildStatChip(
                              icon: Icons.bookmark_outline,
                              count: story.saveCount,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Remove button
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.grey[600],
                  size: 18.sp,
                ),
                onSelected: (value) {
                  if (value == 'remove') {
                    _showRemoveConfirmation(context);
                  } else if (value == 'share') {
                    // Implement share functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Share functionality coming soon!')),
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(
                          viewType == 'saved'
                              ? Icons.bookmark_remove
                              : Icons.favorite_border,
                          size: 16.sp,
                          color: Colors.red,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          viewType == 'saved' ? 'Remove from Saved' : 'Unlike',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share_outlined, size: 16.sp),
                        SizedBox(width: 2.w),
                        const Text('Share Story'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required int count,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12.sp,
          color: color,
        ),
        SizedBox(width: 0.5.w),
        Text(
          _formatCount(count),
          style: TextStyle(
            fontSize: 10.sp,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showRemoveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove from ${viewType == 'saved' ? 'Saved' : 'Liked'}?'),
        content: Text(
            'This will remove "${story.title}" from your ${viewType} stories.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRemove();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}