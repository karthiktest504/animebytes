import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class NotificationSettingsWidget extends StatelessWidget {
  final bool pushAlertsEnabled;
  final bool trendingAlertsEnabled;
  final bool dailyDigestEnabled;
  final String digestTime;
  final Function(bool) onPushAlertsChanged;
  final Function(bool) onTrendingAlertsChanged;
  final Function(bool) onDailyDigestChanged;
  final Function(String) onDigestTimeChanged;

  const NotificationSettingsWidget({
    super.key,
    required this.pushAlertsEnabled,
    required this.trendingAlertsEnabled,
    required this.dailyDigestEnabled,
    required this.digestTime,
    required this.onPushAlertsChanged,
    required this.onTrendingAlertsChanged,
    required this.onDailyDigestChanged,
    required this.onDigestTimeChanged,
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
                iconName: 'notifications',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Notifications',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildNotificationTile(
            context,
            theme,
            colorScheme,
            'New Stories',
            'Get notified when new anime stories are available',
            'new_releases',
            pushAlertsEnabled,
            onPushAlertsChanged,
          ),
          SizedBox(height: 2.h),
          _buildNotificationTile(
            context,
            theme,
            colorScheme,
            'Trending Anime',
            'Alerts for trending anime and hot topics',
            'trending_up',
            trendingAlertsEnabled,
            onTrendingAlertsChanged,
          ),
          SizedBox(height: 2.h),
          _buildNotificationTile(
            context,
            theme,
            colorScheme,
            'Daily Digest',
            'Daily summary of anime news and updates',
            'schedule',
            dailyDigestEnabled,
            onDailyDigestChanged,
          ),
          if (dailyDigestEnabled) ...[
            SizedBox(height: 2.h),
            _buildDigestTimePicker(context, theme, colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String subtitle,
    String iconName,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: colorScheme.primary,
            size: 5.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (newValue) {
            HapticFeedback.lightImpact();
            onChanged(newValue);
          },
          activeColor: colorScheme.primary,
          activeTrackColor: colorScheme.primary.withValues(alpha: 0.3),
          inactiveThumbColor: colorScheme.onSurfaceVariant,
          inactiveTrackColor:
              colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildDigestTimePicker(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final List<String> timeOptions = [
      '8:00 AM',
      '9:00 AM',
      '10:00 AM',
      '12:00 PM',
      '2:00 PM',
      '4:00 PM',
      '6:00 PM',
      '8:00 PM'
    ];

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
          Text(
            'Delivery Time',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.5.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: timeOptions.map((time) {
              final isSelected = digestTime == time;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onDigestTimeChanged(time);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? colorScheme.primary : colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    time,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isSelected ? Colors.white : colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
