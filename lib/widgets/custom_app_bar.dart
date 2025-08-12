import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

enum AppBarVariant {
  standard,
  transparent,
  minimal,
  story,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final AppBarVariant variant;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final double? titleSpacing;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.variant = AppBarVariant.standard,
    this.centerTitle = false,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.titleSpacing,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case AppBarVariant.transparent:
        return _buildTransparentAppBar(context, theme, colorScheme);
      case AppBarVariant.minimal:
        return _buildMinimalAppBar(context, theme, colorScheme);
      case AppBarVariant.story:
        return _buildStoryAppBar(context, theme, colorScheme);
      case AppBarVariant.standard:
      default:
        return _buildStandardAppBar(context, theme, colorScheme);
    }
  }

  Widget _buildStandardAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              color: Colors.black.withOpacity(0.55),
              child: AppBar(
                title: title != null ? Text(title!) : null,
                actions: _buildActions(context, theme, colorScheme),
                leading: _buildLeading(context, theme, colorScheme),
                automaticallyImplyLeading: automaticallyImplyLeading,
                centerTitle: centerTitle,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: foregroundColor ?? colorScheme.onSurface,
                bottom: bottom,
                titleSpacing: titleSpacing,
                systemOverlayStyle: _getSystemOverlayStyle(theme.brightness),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransparentAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      title: title != null ? Text(title!) : null,
      actions: _buildActions(context, theme, colorScheme),
      leading: _buildLeading(context, theme, colorScheme),
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      bottom: bottom,
      titleSpacing: titleSpacing,
      systemOverlayStyle: _getSystemOverlayStyle(theme.brightness),
    );
  }

  Widget _buildMinimalAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withAlpha(20),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (_shouldShowLeading(context))
                _buildLeading(context, theme, colorScheme) ??
                    const SizedBox.shrink(),
              if (title != null) ...[
                if (_shouldShowLeading(context)) const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: foregroundColor ?? colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (actions != null) ...[
                const SizedBox(width: 16),
                ..._buildActions(context, theme, colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(153),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              if (_shouldShowLeading(context))
                _buildStoryLeading(context, theme, colorScheme),
              if (title != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (actions != null) ...[
                const SizedBox(width: 16),
                ..._buildStoryActions(context, theme, colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActions(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    if (actions == null) return [];

    return actions!.map((action) {
      if (action is IconButton) {
        return IconButton(
          onPressed: action.onPressed,
          icon: action.icon,
          color: foregroundColor ?? colorScheme.onSurface,
          iconSize: 24,
        );
      }
      return action;
    }).toList();
  }

  List<Widget> _buildStoryActions(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    if (actions == null) return [];

    return actions!.map((action) {
      if (action is IconButton) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(77),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            onPressed: action.onPressed,
            icon: action.icon,
            color: Colors.white,
            iconSize: 20,
          ),
        );
      }
      return action;
    }).toList();
  }

  Widget? _buildLeading(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    if (leading != null) return leading;

    if (showBackButton ||
        (automaticallyImplyLeading && Navigator.canPop(context))) {
      return IconButton(
        onPressed: onBackPressed ??
            () {
              HapticFeedback.lightImpact();
              Navigator.maybePop(context);
            },
        icon: const Icon(Icons.arrow_back_ios),
        color: foregroundColor ?? colorScheme.onSurface,
        iconSize: 24,
      );
    }

    return null;
  }

  Widget _buildStoryLeading(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    if (leading != null) return leading!;

    if (showBackButton ||
        (automaticallyImplyLeading && Navigator.canPop(context))) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(77),
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          onPressed: onBackPressed ??
              () {
                HapticFeedback.lightImpact();
                Navigator.maybePop(context);
              },
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          iconSize: 20,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  bool _shouldShowLeading(BuildContext context) {
    return leading != null ||
        showBackButton ||
        (automaticallyImplyLeading && Navigator.canPop(context));
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(Brightness brightness) {
    if (variant == AppBarVariant.story) {
      return SystemUiOverlayStyle.light;
    }

    return brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
  }

  @override
  Size get preferredSize {
    double height = 56.0; // Standard app bar height
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }
}
