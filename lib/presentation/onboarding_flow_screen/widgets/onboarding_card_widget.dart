import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;
  final Widget? interactiveElement;
  final bool showGestureHints;

  const OnboardingCardWidget({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
    this.interactiveElement,
    this.showGestureHints = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor,
            backgroundColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 70.w,
                        height: 35.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CustomImageWidget(
                            imageUrl: imagePath,
                            width: 70.w,
                            height: 35.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (showGestureHints) _buildGestureHints(context),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (interactiveElement != null) ...[
                      SizedBox(height: 4.h),
                      interactiveElement!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGestureHints(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Tap zones hint
          Positioned(
            left: 10,
            top: 50,
            child: _buildTapHint(
                context, 'Tap left\nto go back', Alignment.centerLeft),
          ),
          Positioned(
            right: 10,
            top: 50,
            child: _buildTapHint(
                context, 'Tap right\nto continue', Alignment.centerRight),
          ),
          // Swipe hint
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _buildSwipeHint(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTapHint(BuildContext context, String text, Alignment alignment) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontSize: 10.sp,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSwipeHint(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconWidget(
          iconName: 'swipe_left',
          color: Colors.white.withValues(alpha: 0.8),
          size: 20,
        ),
        SizedBox(width: 2.w),
        Text(
          'Swipe to navigate',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10.sp,
              ),
        ),
        SizedBox(width: 2.w),
        CustomIconWidget(
          iconName: 'swipe_right',
          color: Colors.white.withValues(alpha: 0.8),
          size: 20,
        ),
      ],
    );
  }
}
