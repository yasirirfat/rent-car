import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

class SearchBars extends StatefulWidget {
  const SearchBars({
    super.key,
    this.onChanged,
    this.controller,
    this.hintText = 'Search the fleet...',
    this.onSubmitted,
    this.autofocus = false,
    this.showFilterButton = false,
    this.onFilterTap,
  });

  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool showFilterButton;
  final VoidCallback? onFilterTap;

  @override
  State<SearchBars> createState() => _SearchBarsState();
}

class _SearchBarsState extends State<SearchBars> {
  late final TextEditingController _internalController;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    _hasText = _internalController.text.isNotEmpty;
    _internalController.addListener(_syncTextState);
    _focusNode.addListener(_syncFocusState);
  }

  void _syncTextState() {
    final has = _internalController.text.isNotEmpty;
    if (has != _hasText && mounted) {
      setState(() => _hasText = has);
    }
  }

  void _syncFocusState() {
    if (mounted) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _internalController.removeListener(_syncTextState);
    _focusNode.removeListener(_syncFocusState);
    _focusNode.dispose();

    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _clear() {
    _internalController.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _focused ? AppColor.surfaceVeilMax : AppColor.surfaceVeil,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: _focused
              ? AppColor.primary.withValues(alpha: 0.7)
              : AppColor.stroke,
          width: _focused ? 1.5 : 1.1,
        ),
        boxShadow: _focused
            ? AppColor.glow(AppColor.primary, opacity: 0.22, blur: 22)
            : null,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: _focused ? AppColor.secondary : AppColor.textMuted,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _internalController,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              style: const TextStyle(
                color: AppColor.textPrimary,
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: AppColor.secondary,
              cursorHeight: 18,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: const TextStyle(
                  color: AppColor.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_hasText)
            GestureDetector(
              onTap: _clear,
              child: Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  color: AppColor.textMuted.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 13,
                  color: AppColor.textPrimary,
                ),
              ),
            ),
          if (widget.showFilterButton) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: widget.onFilterTap,
              child: Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
