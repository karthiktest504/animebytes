import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AppPreferencesWidget extends StatelessWidget {
  final bool darkModeEnabled;
  final bool autoPlayEnabled;
  final double readingSpeed;
  final Function(bool) onDarkModeChanged;
  final Function(bool) onAutoPlayChanged;
  final Function(double) onReadingSpeedChanged;

  const AppPreferencesWidget({
    super.key,
    required this.darkModeEnabled,
    required this.autoPlayEnabled,
    required this.readingSpeed,
    required this.onDarkModeChanged,
    required this.onAutoPlayChanged,
    required this.onReadingSpeedChanged,
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
                iconName: 'settings',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'App Preferences',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildPreferenceTile(
            context,
            theme,
            colorScheme,
            'Dark Mode',
            'Switch between light and dark themes',
            'dark_mode',
            darkModeEnabled,
            onDarkModeChanged,
          ),
          SizedBox(height: 2.h),
          _buildPreferenceTile(
            context,
            theme,
            colorScheme,
            'Auto-Play Stories',
            'Automatically progress through story cards',
            'play_circle',
            autoPlayEnabled,
            onAutoPlayChanged,
          ),
          SizedBox(height: 3.h),
          _buildReadingSpeedSlider(context, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildPreferenceTile(
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

  Widget _buildReadingSpeedSlider(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
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
            children: [
              CustomIconWidget(
                iconName: 'speed',
                color: colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Reading Speed',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getSpeedLabel(readingSpeed),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.primary.withValues(alpha: 0.3),
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: readingSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 3,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                onReadingSpeedChanged(value);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Slow',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Normal',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Fast',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSpeedLabel(double speed) {
    if (speed <= 0.75) return 'Slow';
    if (speed <= 1.25) return 'Normal';
    if (speed <= 1.75) return 'Fast';
    return 'Very Fast';
  }
}
