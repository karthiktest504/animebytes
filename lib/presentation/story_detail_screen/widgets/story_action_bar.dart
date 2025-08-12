import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class StoryActionBar extends StatefulWidget {
  final bool isLiked;
  final bool isSaved;
  final int likeCount;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onComment;

  const StoryActionBar({
    super.key,
    required this.isLiked,
    required this.isSaved,
    required this.likeCount,
    required this.onLike,
    required this.onSave,
    required this.onShare,
    required this.onComment,
  });

  @override
  State<StoryActionBar> createState() => _StoryActionBarState();
}

class _StoryActionBarState extends State<StoryActionBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateLike() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              context,
              icon: widget.isLiked ? 'favorite' : 'favorite_outline',
              label: widget.likeCount.toString(),
              isActive: widget.isLiked,
              onTap: () {
                HapticFeedback.lightImpact();
                if (!widget.isLiked) _animateLike();
                widget.onLike();
              },
              theme: theme,
              colorScheme: colorScheme,
              animation: _scaleAnimation,
            ),
            _buildActionButton(
              context,
              icon: widget.isSaved ? 'bookmark' : 'bookmark_outline',
              label: 'Save',
              isActive: widget.isSaved,
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onSave();
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            _buildActionButton(
              context,
              icon: 'share',
              label: 'Share',
              isActive: false,
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onShare();
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
            _buildActionButton(
              context,
              icon: 'comment',
              label: 'Comment',
              isActive: false,
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onComment();
              },
              theme: theme,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required ThemeData theme,
    required ColorScheme colorScheme,
    Animation<double>? animation,
  }) {
    Widget iconWidget = CustomIconWidget(
      iconName: icon,
      color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
      size: 24,
    );

    if (animation != null) {
      iconWidget = AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.scale(
            scale: animation.value,
            child: iconWidget,
          );
        },
      );
    }

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconWidget,
                SizedBox(height: 0.5.h),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isActive
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
