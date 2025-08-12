import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class InteractiveDemoWidget extends StatefulWidget {
  final String demoType;
  final VoidCallback? onInteraction;

  const InteractiveDemoWidget({
    super.key,
    required this.demoType,
    this.onInteraction,
  });

  @override
  State<InteractiveDemoWidget> createState() => _InteractiveDemoWidgetState();
}

class _InteractiveDemoWidgetState extends State<InteractiveDemoWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _feedbackController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _feedbackAnimation;

  bool _isLiked = false;
  bool _isSaved = false;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _feedbackAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleInteraction() {
    if (!_hasInteracted) {
      setState(() {
        _hasInteracted = true;
      });
      _pulseController.stop();
      widget.onInteraction?.call();
    }
  }

  void _handleLike() {
    HapticFeedback.lightImpact();
    setState(() {
      _isLiked = !_isLiked;
    });
    _feedbackController.forward().then((_) {
      _feedbackController.reverse();
    });
    _handleInteraction();
  }

  void _handleSave() {
    HapticFeedback.lightImpact();
    setState(() {
      _isSaved = !_isSaved;
    });
    _feedbackController.forward().then((_) {
      _feedbackController.reverse();
    });
    _handleInteraction();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (widget.demoType) {
      case 'tap_zones':
        return _buildTapZonesDemo(context, theme);
      case 'actions':
        return _buildActionsDemo(context, theme);
      case 'swipe':
        return _buildSwipeDemo(context, theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTapZonesDemo(BuildContext context, ThemeData theme) {
    return Container(
      width: 80.w,
      height: 25.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Left tap zone
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 40.w,
            child: GestureDetector(
              onTap: _handleInteraction,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _hasInteracted ? 1.0 : _pulseAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _hasInteracted
                            ? Colors.green.withValues(alpha: 0.3)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName:
                                  _hasInteracted ? 'check_circle' : 'touch_app',
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              _hasInteracted ? 'Great!' : 'Tap Here',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Right tap zone
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 40.w,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'navigate_next',
                      color: Colors.white.withValues(alpha: 0.6),
                      size: 24,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Next Story',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsDemo(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AnimatedBuilder(
            animation: _feedbackAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isLiked ? _feedbackAnimation.value : 1.0,
                child: GestureDetector(
                  onTap: _handleLike,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _hasInteracted ? 1.0 : _pulseAnimation.value,
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: _isLiked
                                ? Colors.red.withValues(alpha: 0.3)
                                : Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomIconWidget(
                            iconName: _isLiked ? 'favorite' : 'favorite_border',
                            color: _isLiked ? Colors.red : Colors.white,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _feedbackAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isSaved ? _feedbackAnimation.value : 1.0,
                child: GestureDetector(
                  onTap: _handleSave,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: _isSaved
                          ? Colors.blue.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: _isSaved ? 'bookmark' : 'bookmark_border',
                      color: _isSaved ? Colors.blue : Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              );
            },
          ),
          GestureDetector(
            onTap: _handleInteraction,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: 'share',
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeDemo(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity!.abs() > 100) {
          _handleInteraction();
        }
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _hasInteracted ? 1.0 : _pulseAnimation.value,
            child: Container(
              width: 80.w,
              height: 15.h,
              decoration: BoxDecoration(
                color: _hasInteracted
                    ? Colors.green.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'swipe_left',
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 4.w),
                        CustomIconWidget(
                          iconName: 'swipe_right',
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _hasInteracted
                          ? 'Perfect! You got it!'
                          : 'Swipe left or right to try',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
