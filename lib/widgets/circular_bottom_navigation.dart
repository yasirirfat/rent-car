import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/model/tab_items.dart';

typedef CircularBottomNavSelectedCallback = Function(int? selectedPos);

class CircularBottomNavigation extends StatefulWidget {
  final List<TabItem> tabItems;
  final int selectedPos;
  final double barHeight;
  final Color? barBackgroundColor;
  final Gradient? barBackgroundGradient;
  final double circleSize;
  final double circleStrokeWidth;
  final double iconsSize;
  final Color selectedIconColor;
  final Color normalIconColor;
  final Duration animationDuration;
  final List<BoxShadow>? backgroundBoxShadow;
  final CircularBottomNavSelectedCallback? selectedCallback;
  final CircularBottomNavigationController? controller;

  final bool allowSelectedIconCallback;

  CircularBottomNavigation(
    this.tabItems, {
    super.key,
    this.selectedPos = 0,
    this.barHeight = 60,
    barBackgroundColor,
    this.barBackgroundGradient,
    this.circleSize = 58,
    this.circleStrokeWidth = 4,
    this.iconsSize = 32,
    this.selectedIconColor = Colors.white,
    this.normalIconColor = Colors.grey,
    this.animationDuration = const Duration(milliseconds: 340),
    this.selectedCallback,
    this.controller,
    this.allowSelectedIconCallback = false,
    backgroundBoxShadow,
  }) : backgroundBoxShadow =
           backgroundBoxShadow ??
           [const BoxShadow(color: Color(0x33000000), blurRadius: 18)],
       barBackgroundColor =
           (barBackgroundGradient == null && barBackgroundColor == null)
           ? AppColor.surface
           : barBackgroundColor,
       assert(
         barBackgroundColor == null || barBackgroundGradient == null,
         "Both barBackgroundColor and barBackgroundGradient can't be not null.",
       ),
       assert(tabItems.isNotEmpty, "tabItems is required");

  @override
  State<CircularBottomNavigation> createState() =>
      _CircularBottomNavigationState();
}

class _CircularBottomNavigationState extends State<CircularBottomNavigation>
    with TickerProviderStateMixin {
  static const Curve _animationCurve = Cubic(0.27, 1.21, 0.77, 1.09);

  late AnimationController itemsController;
  late Animation<double> selectedPosAnimation;
  late Animation<double> itemsAnimation;

  late List<double> _itemsSelectedState;

  int? selectedPos;
  int? previousSelectedPos;

  late CircularBottomNavigationController _controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      previousSelectedPos = selectedPos = _controller.value;
    } else {
      previousSelectedPos = selectedPos = widget.selectedPos;
      _controller = CircularBottomNavigationController(selectedPos);
    }

    _controller.addListener(_newSelectedPosNotify);

    _itemsSelectedState = List.generate(
      widget.tabItems.length,
      (index) => selectedPos == index ? 1.0 : 0.0,
    );

    itemsController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    itemsController.addListener(_onItemsAnimationTick);

    selectedPosAnimation = _buildPosAnimation(
      selectedPos!.toDouble(),
      selectedPos!.toDouble(),
    );

    itemsAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: itemsController, curve: _animationCurve));
  }

  void _onItemsAnimationTick() {
    setState(() {
      for (var i = 0; i < _itemsSelectedState.length; i++) {
        if (i == previousSelectedPos) {
          _itemsSelectedState[i] = 1.0 - itemsAnimation.value;
        } else if (i == selectedPos) {
          _itemsSelectedState[i] = itemsAnimation.value;
        } else {
          _itemsSelectedState[i] = 0.0;
        }
      }
    });
  }

  Animation<double> _buildPosAnimation(double begin, double end) {
    return Tween(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: itemsController, curve: _animationCurve));
  }

  void _newSelectedPosNotify() {
    if (widget.controller != null) {
      _setSelectedPos(widget.controller!.value);
    }
  }

  @override
  void dispose() {
    itemsController.dispose();
    _controller.removeListener(_newSelectedPosNotify);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _setSelectedPos(int? pos) {
    if (pos == selectedPos) return;
    previousSelectedPos = selectedPos;
    selectedPos = pos;

    itemsController.forward(from: 0.0);

    selectedPosAnimation = _buildPosAnimation(
      previousSelectedPos!.toDouble(),
      selectedPos!.toDouble(),
    );

    if (widget.selectedCallback != null) {
      widget.selectedCallback!(selectedPos);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxShadowHeight = (widget.backgroundBoxShadow ?? []).isNotEmpty
        ? widget.backgroundBoxShadow!.map((e) => e.blurRadius).reduce(max)
        : 0.0;
    final fullWidth = MediaQuery.of(context).size.width;
    final fullHeight =
        widget.barHeight +
        (widget.circleSize / 2) +
        widget.circleStrokeWidth +
        maxShadowHeight;
    final sectionsWidth = fullWidth / widget.tabItems.length;
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    final boxes = <Rect>[];
    for (var i = 0; i < widget.tabItems.length; i++) {
      final left = isRTL
          ? fullWidth - (i + 1) * sectionsWidth
          : i * sectionsWidth;
      boxes.add(
        Rect.fromLTRB(
          left,
          fullHeight - widget.barHeight,
          left + sectionsWidth,
          fullHeight,
        ),
      );
    }

    final children = <Widget>[];

    children.add(
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        height: fullHeight + safeBottom,
        child: CustomPaint(
          painter: _NavBarPainter(
            barHeight: widget.barHeight,
            safeBottom: safeBottom,
            gradient: widget.barBackgroundGradient,
            color: widget.barBackgroundColor ?? AppColor.surface,
            circleCenterX:
                (selectedPosAnimation.value * sectionsWidth) +
                (sectionsWidth / 2),
            circleSize: widget.circleSize,
            maxShadowHeight: maxShadowHeight,
            isRTL: isRTL,
            fullWidth: fullWidth,
            accent: widget.tabItems[selectedPos!].circleColor,
          ),
        ),
      ),
    );

    for (var pos = 0; pos < boxes.length; pos++) {
      final r = boxes[pos];
      final iconSize = widget.iconsSize;

      final selectedIconY =
          maxShadowHeight +
          widget.circleStrokeWidth +
          ((widget.circleSize - widget.circleStrokeWidth * 2 - iconSize) / 2);
      final restingIconY = r.top + ((widget.barHeight - iconSize) / 2);

      double iconY;
      if (pos == previousSelectedPos) {
        iconY =
            selectedIconY +
            (restingIconY - selectedIconY) * itemsAnimation.value;
      } else if (pos == selectedPos) {
        iconY =
            restingIconY +
            (selectedIconY - restingIconY) * itemsAnimation.value;
      } else {
        iconY = restingIconY;
      }

      final iconX = r.left + ((r.width - iconSize) / 2);
      final isSelected = pos == selectedPos;

      children.add(
        Positioned(
          left: iconX,
          top: iconY,
          child: IgnorePointer(
            child: Transform.scale(
              scale: isSelected ? 1.05 : 1.0,
              child: Icon(
                widget.tabItems[pos].icon,
                size: iconSize,
                color: isSelected
                    ? widget.selectedIconColor
                    : widget.normalIconColor,
              ),
            ),
          ),
        ),
      );

      final opacity = _itemsSelectedState[pos].clamp(0.0, 1.0);
      if (opacity > 0.01) {
        children.add(
          Positioned(
            left: r.left,
            bottom: safeBottom + 4,
            width: r.width,
            child: IgnorePointer(
              child: Opacity(
                opacity: opacity,
                child: Text(
                  widget.tabItems[pos].title,
                  textAlign: TextAlign.center,
                  style: widget.tabItems[pos].labelStyle,
                ),
              ),
            ),
          ),
        );
      }

      if (!isSelected) {
        children.add(
          Positioned.fromRect(
            rect: r,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _controller.value = pos,
            ),
          ),
        );
      } else if (widget.allowSelectedIconCallback) {
        children.add(
          Positioned.fromRect(
            rect: Rect.fromLTWH(r.left, 0, r.width, fullHeight),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.selectedCallback?.call(selectedPos),
            ),
          ),
        );
      }
    }

    return SizedBox(
      height: fullHeight + safeBottom,
      child: Stack(children: children),
    );
  }
}

class _NavBarPainter extends CustomPainter {
  _NavBarPainter({
    required this.barHeight,
    required this.safeBottom,
    required this.color,
    required this.gradient,
    required this.circleCenterX,
    required this.circleSize,
    required this.maxShadowHeight,
    required this.isRTL,
    required this.fullWidth,
    required this.accent,
  });

  final double barHeight;
  final double safeBottom;
  final Color color;
  final Gradient? gradient;
  final double circleCenterX;
  final double circleSize;
  final double maxShadowHeight;
  final bool isRTL;
  final double fullWidth;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final barTop = maxShadowHeight + (circleSize / 2);

    final barRect = Rect.fromLTWH(
      0,
      barTop,
      size.width,
      barHeight + safeBottom,
    );
    canvas.drawRect(
      barRect,
      Paint()..color = gradient?.colors.first ?? AppColor.surface,
    );

    canvas.drawLine(
      Offset(0, barTop),
      Offset(size.width, barTop),
      Paint()
        ..strokeWidth = 1
        ..color = AppColor.stroke,
    );

    final center = Offset(circleCenterX, barTop);
    final radius = circleSize / 2;

    canvas.drawCircle(center, radius, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant _NavBarPainter oldDelegate) =>
      oldDelegate.circleCenterX != circleCenterX ||
      oldDelegate.accent != accent ||
      oldDelegate.circleSize != circleSize;
}

class CircularBottomNavigationController extends ValueNotifier<int?> {
  CircularBottomNavigationController(super.value);
}
