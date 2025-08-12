import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchBarWidget extends StatefulWidget {
  final String? initialQuery;
  final Function(String) onSearchChanged;
  final VoidCallback? onClear;

  const SearchBarWidget({
    super.key,
    this.initialQuery,
    required this.onSearchChanged,
    this.onClear,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _isSearchActive = widget.initialQuery?.isNotEmpty ?? false;

    _focusNode.addListener(() {
      setState(() {
        _isSearchActive = _focusNode.hasFocus || _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSearchActive
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: _isSearchActive
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: (value) {
          widget.onSearchChanged(value);
          setState(() {
            _isSearchActive = value.isNotEmpty || _focusNode.hasFocus;
          });
        },
        onSubmitted: (value) {
          HapticFeedback.lightImpact();
          _focusNode.unfocus();
        },
        decoration: InputDecoration(
          hintText: 'Search saved stories...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: CustomIconWidget(
              iconName: 'search',
              size: 20,
              color: _isSearchActive
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _controller.clear();
                    widget.onSearchChanged('');
                    widget.onClear?.call();
                    setState(() {
                      _isSearchActive = _focusNode.hasFocus;
                    });
                  },
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 2.h,
          ),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        textInputAction: TextInputAction.search,
        keyboardType: TextInputType.text,
      ),
    );
  }
}
