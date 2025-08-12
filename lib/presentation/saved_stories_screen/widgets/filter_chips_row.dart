import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum SavedStoriesFilter {
  all,
  dateSaved,
  animeSeries,
  readingStatus,
  unread,
  read,
}

class FilterChipsRow extends StatelessWidget {
  final SavedStoriesFilter selectedFilter;
  final Function(SavedStoriesFilter) onFilterChanged;

  const FilterChipsRow({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        children: [
          _buildFilterChip(
            context,
            theme,
            colorScheme,
            'All Stories',
            SavedStoriesFilter.all,
            'select_all',
          ),
          SizedBox(width: 2.w),
          _buildFilterChip(
            context,
            theme,
            colorScheme,
            'Recently Saved',
            SavedStoriesFilter.dateSaved,
            'schedule',
          ),
          SizedBox(width: 2.w),
          _buildFilterChip(
            context,
            theme,
            colorScheme,
            'By Series',
            SavedStoriesFilter.animeSeries,
            'category',
          ),
          SizedBox(width: 2.w),
          _buildFilterChip(
            context,
            theme,
            colorScheme,
            'Unread',
            SavedStoriesFilter.unread,
            'radio_button_unchecked',
          ),
          SizedBox(width: 2.w),
          _buildFilterChip(
            context,
            theme,
            colorScheme,
            'Read',
            SavedStoriesFilter.read,
            'check_circle_outline',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    SavedStoriesFilter filter,
    String iconName,
  ) {
    final bool isSelected = selectedFilter == filter;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: iconName,
            size: 16,
            color:
                isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 1.w),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          HapticFeedback.selectionClick();
          onFilterChanged(filter);
        }
      },
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primary.withValues(alpha: 0.1),
      checkmarkColor: colorScheme.primary,
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
      ),
      side: BorderSide(
        color: isSelected
            ? colorScheme.primary
            : colorScheme.outline.withValues(alpha: 0.2),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
