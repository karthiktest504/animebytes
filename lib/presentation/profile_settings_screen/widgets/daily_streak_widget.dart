import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DailyStreakWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final List<Map<String, dynamic>> badges;
  final int nextBadgeProgress;
  final int nextBadgeTarget;

  const DailyStreakWidget({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
    required this.badges,
    required this.nextBadgeProgress,
    required this.nextBadgeTarget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'local_fire_department',
                color: Colors.orange,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Daily Streak',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildStreakStats(context, theme, colorScheme),
          SizedBox(height: 3.h),
          _buildProgressSection(context, theme, colorScheme),
          SizedBox(height: 3.h),
          _buildBadgesSection(context, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildStreakStats(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.withValues(alpha: 0.1),
                  Colors.deepOrange.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'local_fire_department',
                  color: Colors.orange,
                  size: 8.w,
                ),
                SizedBox(height: 1.h),
                Text(
                  currentStreak.toString(),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Current Streak',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.withValues(alpha: 0.1),
                  Colors.yellow.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'emoji_events',
                  color: Colors.amber,
                  size: 8.w,
                ),
                SizedBox(height: 1.h),
                Text(
                  longestStreak.toString(),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.amber,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Best Streak',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final progress = nextBadgeProgress / nextBadgeTarget;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Badge Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '$nextBadgeProgress / $nextBadgeTarget',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          SizedBox(height: 1.h),
          Text(
            '${nextBadgeTarget - nextBadgeProgress} days until next anime badge!',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anime Badges',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 12.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final badge = badges[index];
              final isUnlocked = badge['unlocked'] as bool;

              return Container(
                width: 20.w,
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnlocked
                        ? colorScheme.primary.withValues(alpha: 0.3)
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      badge['emoji'] as String,
                      style: TextStyle(fontSize: 8.w),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      badge['name'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isUnlocked
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        fontWeight:
                            isUnlocked ? FontWeight.w500 : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!isUnlocked) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        '${badge['requirement']} days',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
