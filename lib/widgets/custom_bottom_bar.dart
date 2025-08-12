import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum BottomBarVariant {
  standard,
  floating,
  minimal,
}

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final BottomBarVariant variant;
  final bool showLabels;
  final double? elevation;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = BottomBarVariant.standard,
    this.showLabels = true,
    this.elevation,
    this.backgroundColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case BottomBarVariant.floating:
        return _buildFloatingBottomBar(context, theme, colorScheme);
      case BottomBarVariant.minimal:
        return _buildMinimalBottomBar(context, theme, colorScheme);
      case BottomBarVariant.standard:
      default:
        return _buildStandardBottomBar(context, theme, colorScheme);
    }
  }

  Widget _buildStandardBottomBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color:
            backgroundColor ?? theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(20),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildBottomBarItems(context, theme, colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      child: SafeArea(
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: backgroundColor ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withAlpha(31),
                offset: const Offset(0, 4),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildBottomBarItems(context, theme, colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalBottomBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withAlpha(20),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildBottomBarItems(context, theme, colorScheme),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildBottomBarItems(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    final items = [
      _BottomBarItemData(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Feed',
        route: '/daily-feed-screen',
      ),
      _BottomBarItemData(
        icon: Icons.bookmark_outline,
        activeIcon: Icons.bookmark,
        label: 'Saved',
        route: '/saved-stories-screen',
      ),
      _BottomBarItemData(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        route: '/profile-settings-screen',
      ),
    ];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = currentIndex == index;

      return _buildBottomBarItem(
        context,
        theme,
        colorScheme,
        item,
        isSelected,
        index,
      );
    }).toList();
  }

  Widget _buildBottomBarItem(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    _BottomBarItemData item,
    bool isSelected,
    int index,
  ) {
    final primaryColor = colorScheme.primary;
    final onSurfaceColor = colorScheme.onSurface;
    final neutralColor = colorScheme.onSurfaceVariant;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap(index);
            if (item.route != null) {
              Navigator.pushNamed(context, item.route!);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withAlpha(26)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    size: 24,
                    color: isSelected ? primaryColor : neutralColor,
                  ),
                ),
                if (showLabels) ...[
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: isSelected ? primaryColor : neutralColor,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBarItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? route;

  const _BottomBarItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.route,
  });
}
