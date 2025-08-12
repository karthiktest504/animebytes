import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PersonalizationSectionWidget extends StatefulWidget {
  final List<String> selectedAnime;
  final List<String> selectedGenres;
  final List<String> selectedCharacters;
  final Function(List<String>) onAnimeChanged;
  final Function(List<String>) onGenresChanged;
  final Function(List<String>) onCharactersChanged;

  const PersonalizationSectionWidget({
    super.key,
    required this.selectedAnime,
    required this.selectedGenres,
    required this.selectedCharacters,
    required this.onAnimeChanged,
    required this.onGenresChanged,
    required this.onCharactersChanged,
  });

  @override
  State<PersonalizationSectionWidget> createState() =>
      _PersonalizationSectionWidgetState();
}

class _PersonalizationSectionWidgetState
    extends State<PersonalizationSectionWidget> {
  final List<String> availableAnime = [
    'Attack on Titan',
    'Demon Slayer',
    'One Piece',
    'Naruto',
    'Dragon Ball Z',
    'My Hero Academia',
    'Death Note',
    'Fullmetal Alchemist',
    'One Punch Man',
    'Tokyo Ghoul',
    'Hunter x Hunter',
    'Bleach',
    'Jujutsu Kaisen',
    'Chainsaw Man'
  ];

  final List<String> availableGenres = [
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Horror',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Slice of Life',
    'Sports',
    'Supernatural'
  ];

  final List<String> availableCharacters = [
    'Goku',
    'Naruto Uzumaki',
    'Monkey D. Luffy',
    'Eren Yeager',
    'Tanjiro Kamado',
    'Izuku Midoriya',
    'Light Yagami',
    'Edward Elric',
    'Saitama',
    'Ken Kaneki',
    'Gon Freecss',
    'Ichigo Kurosaki',
    'Yuji Itadori',
    'Denji'
  ];

  final TextEditingController _characterSearchController =
      TextEditingController();
  List<String> filteredCharacters = [];

  @override
  void initState() {
    super.initState();
    filteredCharacters = availableCharacters;
    _characterSearchController.addListener(_filterCharacters);
  }

  @override
  void dispose() {
    _characterSearchController.dispose();
    super.dispose();
  }

  void _filterCharacters() {
    setState(() {
      filteredCharacters = availableCharacters
          .where((character) => character
              .toLowerCase()
              .contains(_characterSearchController.text.toLowerCase()))
          .toList();
    });
  }

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
                iconName: 'tune',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Personalization',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildAnimeSelector(context, theme, colorScheme),
          SizedBox(height: 3.h),
          _buildGenreSelector(context, theme, colorScheme),
          SizedBox(height: 3.h),
          _buildCharacterSelector(context, theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildAnimeSelector(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favorite Anime Series',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.5.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: availableAnime.map((anime) {
            final isSelected = widget.selectedAnime.contains(anime);
            return FilterChip(
              label: Text(anime),
              selected: isSelected,
              onSelected: (selected) {
                HapticFeedback.selectionClick();
                List<String> updatedList = List.from(widget.selectedAnime);
                if (selected) {
                  updatedList.add(anime);
                } else {
                  updatedList.remove(anime);
                }
                widget.onAnimeChanged(updatedList);
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
                    : colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenreSelector(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Genres',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.5.h),
        SizedBox(
          height: 6.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: availableGenres.length,
            separatorBuilder: (context, index) => SizedBox(width: 2.w),
            itemBuilder: (context, index) {
              final genre = availableGenres[index];
              final isSelected = widget.selectedGenres.contains(genre);
              return FilterChip(
                label: Text(genre),
                selected: isSelected,
                onSelected: (selected) {
                  HapticFeedback.selectionClick();
                  List<String> updatedList = List.from(widget.selectedGenres);
                  if (selected) {
                    updatedList.add(genre);
                  } else {
                    updatedList.remove(genre);
                  }
                  widget.onGenresChanged(updatedList);
                },
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primary.withValues(alpha: 0.1),
                checkmarkColor: colorScheme.primary,
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterSelector(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favorite Characters',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.5.h),
        TextField(
          controller: _characterSearchController,
          decoration: InputDecoration(
            hintText: 'Search characters...',
            prefixIcon: CustomIconWidget(
              iconName: 'search',
              color: colorScheme.onSurfaceVariant,
              size: 5.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          constraints: BoxConstraints(maxHeight: 20.h),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filteredCharacters.length,
            itemBuilder: (context, index) {
              final character = filteredCharacters[index];
              final isSelected = widget.selectedCharacters.contains(character);
              return CheckboxListTile(
                title: Text(
                  character,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                value: isSelected,
                onChanged: (selected) {
                  HapticFeedback.selectionClick();
                  List<String> updatedList =
                      List.from(widget.selectedCharacters);
                  if (selected == true) {
                    updatedList.add(character);
                  } else {
                    updatedList.remove(character);
                  }
                  widget.onCharactersChanged(updatedList);
                },
                activeColor: colorScheme.primary,
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ),
      ],
    );
  }
}
