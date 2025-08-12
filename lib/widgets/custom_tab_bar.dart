import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TabBarVariant {
  standard,
  chips,
  minimal,
  scrollable,
}

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final int currentIndex;
  final Function(int) onTap;
  final TabBarVariant variant;
  final bool isScrollable;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final EdgeInsetsGeometry? padding;
  final double? indicatorWeight;

  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    this.variant = TabBarVariant.standard,
    this.isScrollable = false,
    this.backgroundColor,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.padding,
    this.indicatorWeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case TabBarVariant.chips:
        return _buildChipsTabBar(context, theme, colorScheme);
      case TabBarVariant.minimal:
        return _buildMinimalTabBar(context, theme, colorScheme);
      case TabBarVariant.scrollable:
        return _buildScrollableTabBar(context, theme, colorScheme);
      case TabBarVariant.standard:
      default:
        return _buildStandardTabBar(context, theme, colorScheme);
    }
  }

  Widget _buildStandardTabBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      color: backgroundColor ?? colorScheme.surface,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        isScrollable: isScrollable,
        indicatorColor: indicatorColor ?? colorScheme.primary,
        labelColor: labelColor ?? colorScheme.primary,
        unselectedLabelColor:
            unselectedLabelColor ?? colorScheme.onSurfaceVariant,
        indicatorWeight: indicatorWeight ?? 2.0,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        onTap: (index) {
          HapticFeedback.selectionClick();
          onTap(index);
        },
      ),
    );
  }

  Widget _buildChipsTabBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      color: backgroundColor ?? Colors.transparent,
      padding: padding ?? const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = currentIndex == index;

            return Padding(
              padding: EdgeInsets.only(right: index < tabs.length - 1 ? 8 : 0),
              child: FilterChip(
                label: Text(tab),
                selected: isSelected,
                onSelected: (selected) {
                  HapticFeedback.selectionClick();
                  if (selected) onTap(index);
                },
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primary.withAlpha(26),
                checkmarkColor: colorScheme.primary,
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withAlpha(51),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMinimalTabBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      color: backgroundColor ?? Colors.transparent,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = currentIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onTap(index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? (indicatorColor ?? colorScheme.primary)
                          : Colors.transparent,
                      width: indicatorWeight ?? 2.0,
                    ),
                  ),
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isSelected
                        ? (labelColor ?? colorScheme.primary)
                        : (unselectedLabelColor ??
                            colorScheme.onSurfaceVariant),
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScrollableTabBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      color: backgroundColor ?? colorScheme.surface,
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = currentIndex == index;

            return Padding(
              padding: EdgeInsets.only(right: index < tabs.length - 1 ? 24 : 0),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary.withAlpha(26)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: colorScheme.primary.withAlpha(77))
                        : null,
                  ),
                  child: Text(
                    tab,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isSelected
                          ? (labelColor ?? colorScheme.primary)
                          : (unselectedLabelColor ??
                              colorScheme.onSurfaceVariant),
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    switch (variant) {
      case TabBarVariant.chips:
        return const Size.fromHeight(64);
      case TabBarVariant.minimal:
        return const Size.fromHeight(48);
      case TabBarVariant.scrollable:
        return const Size.fromHeight(56);
      case TabBarVariant.standard:
      default:
        return const Size.fromHeight(48);
    }
  }
}

// Helper widget for creating tab controllers
class CustomTabController extends StatefulWidget {
  final List<String> tabs;
  final List<Widget> children;
  final TabBarVariant variant;
  final int initialIndex;
  final Function(int)? onTabChanged;

  const CustomTabController({
    super.key,
    required this.tabs,
    required this.children,
    this.variant = TabBarVariant.standard,
    this.initialIndex = 0,
    this.onTabChanged,
  });

  @override
  State<CustomTabController> createState() => _CustomTabControllerState();
}

class _CustomTabControllerState extends State<CustomTabController>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
      widget.onTabChanged?.call(_currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTabBar(
          tabs: widget.tabs,
          currentIndex: _currentIndex,
          variant: widget.variant,
          onTap: (index) {
            _tabController.animateTo(index);
          },
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.children,
          ),
        ),
      ],
    );
  }
}
