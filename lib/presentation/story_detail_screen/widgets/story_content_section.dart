import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class StoryContentSection extends StatelessWidget {
  final String content;
  final List<String> tags;

  const StoryContentSection({
    super.key,
    required this.content,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),
            SelectableText(
              content,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                fontSize: 16.sp,
              ),
              onTap: () {
                HapticFeedback.selectionClick();
              },
            ),
            SizedBox(height: 3.h),
            if (tags.isNotEmpty) ...[
              Text(
                'Tags',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: tags
                    .map((tag) =>
                        _buildTagChip(context, tag, theme, colorScheme))
                    .toList(),
              ),
              SizedBox(height: 3.h),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(BuildContext context, String tag, ThemeData theme,
      ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        tag,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
