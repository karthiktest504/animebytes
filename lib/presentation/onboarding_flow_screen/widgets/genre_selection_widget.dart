import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class GenreSelectionWidget extends StatefulWidget {
  final Function(List<String>) onGenresSelected;
  final List<String> initialSelectedGenres;

  const GenreSelectionWidget({
    super.key,
    required this.onGenresSelected,
    this.initialSelectedGenres = const [],
  });

  @override
  State<GenreSelectionWidget> createState() => _GenreSelectionWidgetState();
}

class _GenreSelectionWidgetState extends State<GenreSelectionWidget> {
  late List<String> selectedGenres;

  final List<Map<String, dynamic>> genres = [
    {'name': 'Action', 'icon': 'sports_martial_arts'},
    {'name': 'Romance', 'icon': 'favorite'},
    {'name': 'Comedy', 'icon': 'sentiment_very_satisfied'},
    {'name': 'Drama', 'icon': 'theater_comedy'},
    {'name': 'Fantasy', 'icon': 'auto_awesome'},
    {'name': 'Sci-Fi', 'icon': 'rocket_launch'},
    {'name': 'Horror', 'icon': 'psychology'},
    {'name': 'Slice of Life', 'icon': 'home'},
    {'name': 'Adventure', 'icon': 'explore'},
    {'name': 'Mystery', 'icon': 'search'},
    {'name': 'Supernatural', 'icon': 'blur_on'},
    {'name': 'Sports', 'icon': 'sports_soccer'},
  ];

  @override
  void initState() {
    super.initState();
    selectedGenres = List.from(widget.initialSelectedGenres);
  }

  void _toggleGenre(String genre) {
    setState(() {
      if (selectedGenres.contains(genre)) {
        selectedGenres.remove(genre);
      } else {
        selectedGenres.add(genre);
      }
    });
    widget.onGenresSelected(selectedGenres);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your favorite genres',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Select at least 3 genres to personalize your feed',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: 3.h),
        Wrap(
          spacing: 3.w,
          runSpacing: 2.h,
          children: genres.map((genre) {
            final isSelected = selectedGenres.contains(genre['name']);
            return GestureDetector(
              onTap: () => _toggleGenre(genre['name']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: genre['icon'],
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      genre['name'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    if (isSelected) ...[
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: 'check_circle',
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 2.h),
        Text(
          '${selectedGenres.length} genres selected',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
