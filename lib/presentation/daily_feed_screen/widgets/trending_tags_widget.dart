import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/anime_story.dart';

class TrendingTagsWidget extends StatelessWidget {
  final List<AnimeTag> tags;
  final String? selectedTag;
  final Function(String?) onTagSelected;

  const TrendingTagsWidget({
    super.key,
    required this.tags,
    this.selectedTag,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 0, bottom: 1.2.h),
      height: 5.2.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 2.5.w),
        children: [
          _buildTagChip(
            name: null,
            displayName: 'My Digest',
            iconEmoji: '',
            isSelected: selectedTag == null,
            onTap: () => onTagSelected(null),
            gradient: selectedTag == null
                ? LinearGradient(colors: [Color(0xFFFFC371), Color(0xFFFF5F6D)])
                : null,
            textColor: selectedTag == null ? Colors.black : Colors.white,
          ),
          ...tags.map((tag) => Padding(
                padding: EdgeInsets.only(left: 1.2.w),
                child: _buildTagChip(
                  name: tag.name,
                  displayName: tag.displayName,
                  iconEmoji: tag.iconEmoji,
                  isSelected: selectedTag == tag.name,
                  onTap: () => onTagSelected(tag.name),
                  gradient: selectedTag == tag.name
                      ? LinearGradient(colors: [Color(0xFFFFC371), Color(0xFFFF5F6D)])
                      : null,
                  textColor: selectedTag == tag.name ? Colors.black : Colors.white,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTagChip({
    required String? name,
    required String displayName,
    required String iconEmoji,
    required bool isSelected,
    required VoidCallback onTap,
    LinearGradient? gradient,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.5.w, vertical: 1.1.h),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null
              ? (isSelected ? Colors.white.withOpacity(0.13) : Colors.white.withOpacity(0.06))
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xFFFFC371) : Colors.white24,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Color(0xFFFFC371).withOpacity(0.18), blurRadius: 8, offset: Offset(0, 2))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconEmoji.isNotEmpty)
              Text(
                iconEmoji,
                style: TextStyle(fontSize: 12.sp),
              ),
            if (iconEmoji.isNotEmpty) SizedBox(width: 0.7.w),
            Text(
              displayName,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w700,
                color: textColor ?? (isSelected ? Colors.black : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
