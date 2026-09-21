library circular_bottom_navigation;

import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';
// Note: Ensure your local path to TabItem matches your project structure
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

  /// If true, allows a selected tab icon to execute its callback even if it's
  /// already selected.
  final bool allowSelectedIconCallback;

  CircularBottomNavigation(
    this.tabItems, {
    this.selectedPos = 0,
    this.barHeight = 60,
    barBackgroundColor,
    this.barBackgroundGradient,
    this.circleSize = 58,
    this.circleStrokeWidth = 4,
    this.iconsSize = 32,
    this.selectedIconColor = Colors.white,
    this.normalIconColor = Colors.grey,
    this.animationDuration = const Duration(milliseconds: 300),
    this.selectedCallback,
    this.controller,
    this.allowSelectedIconCallback = false,
    backgroundBoxShadow,
  })  : backgroundBoxShadow = backgroundBoxShadow ??
            [BoxShadow(color: Colors.grey, blurRadius: 2.0)],
        barBackgroundColor =
            (barBackgroundGradient == null && barBackgroundColor == null)
                ? Colors.white
                : barBackgroundColor,
        assert(barBackgroundColor == null || barBackgroundGradient == null,
            "Both barBackgroundColor and barBackgroundGradient can't be not null."),
        assert(tabItems.isNotEmpty, "tabItems is required");

  @override
  State<StatefulWidget> createState() => _CircularBottomNavigationState();
}

class _CircularBottomNavigationState extends State<CircularBottomNavigation>
    with TickerProviderStateMixin {
  final Curve _animationsCurve = Cubic(0.27, 1.21, .77, 1.09);

  late AnimationController itemsController;
  late Animation<double> selectedPosAnimation;
  late Animation<double> itemsAnimation;

  late List<double> _itemsSelectedState;

  int? selectedPos;
  int? previousSelectedPos;

  CircularBottomNavigationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller;
      previousSelectedPos = selectedPos = _controller!.value;
    } else {
      previousSelectedPos = selectedPos = widget.selectedPos;
      _controller = CircularBottomNavigationController(selectedPos);
    }

    _controller!.addListener(_newSelectedPosNotify);

    _itemsSelectedState = List.generate(widget.tabItems.length, (index) {
      return selectedPos == index ? 1.0 : 0.0;
    });

    itemsController =
        AnimationController(vsync: this, duration: widget.animationDuration);
    itemsController.addListener(() {
      setState(() {
        _itemsSelectedState.asMap().forEach((i, value) {
          if (i == previousSelectedPos) {
            _itemsSelectedState[previousSelectedPos!] =
                1.0 - itemsAnimation.value;
          } else if (i == selectedPos) {
            _itemsSelectedState[selectedPos!] = itemsAnimation.value;
          } else {
            _itemsSelectedState[i] = 0.0;
          }
        });
      });
    });

    selectedPosAnimation = makeSelectedPosAnimation(
        selectedPos!.toDouble(), selectedPos!.toDouble());

    itemsAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: itemsController, curve: _animationsCurve));
  }

  Animation<double> makeSelectedPosAnimation(double begin, double end) {
    return Tween(begin: begin, end: end).animate(
        CurvedAnimation(parent: itemsController, curve: _animationsCurve));
  }

  void onSelectedPosAnimate() {
    setState(() {});
  }

  void _newSelectedPosNotify() {
    _setSelectedPos(widget.controller!.value);
  }

  @override
  Widget build(BuildContext context) {
    double maxShadowHeight = (widget.backgroundBoxShadow ?? []).isNotEmpty
        ? widget.backgroundBoxShadow!.map((e) => e.blurRadius).reduce(max)
        : 0.0;
    double fullWidth = MediaQuery.of(context).size.width;
    double fullHeight = widget.barHeight +
        (widget.circleSize / 2) +
        widget.circleStrokeWidth +
        maxShadowHeight;
    double sectionsWidth = fullWidth / widget.tabItems.length;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    // Create the boxes Rect
    List<Rect> boxes = [];
    widget.tabItems.asMap().forEach((i, tabItem) {
      double left =
          isRTL ? fullWidth - (i + 1) * sectionsWidth : i * sectionsWidth;
      double top = fullHeight - widget.barHeight;
      double right = left + sectionsWidth;
      double bottom = fullHeight;
      boxes.add(Rect.fromLTRB(left, top, right, bottom));
    });

    List<Widget> children = [];

    // This is the full view transparent background (provides structure for the stack)
    children.add(Container(
      width: fullWidth,
      height: fullHeight,
      color: AppColor.darkGrey,
    ));

    // This is the bar background (positioned at the bottom)
    children.add(
      Positioned(
        left: 0,
        bottom: 0,
        child: Container(
          width: fullWidth,
          height: widget.barHeight,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: widget.barBackgroundColor,
            gradient: widget.barBackgroundGradient,
            boxShadow: widget.backgroundBoxShadow,
          ),
        ),
      ),
    );

    // Calculate the horizontal coordinate for the sliding circle handle
    double selectedItemCenterX =
        (selectedPosAnimation.value * sectionsWidth) + (sectionsWidth / 2);
    double circleLeft = isRTL
        ? (fullWidth - selectedItemCenterX) - (widget.circleSize / 2)
        : selectedItemCenterX - (widget.circleSize / 2);

    // This is the sliding circle handle
    children.add(
      Positioned(
        left: circleLeft,
        top: maxShadowHeight,
        child: SizedBox(
          width: widget.circleSize,
          height: widget.circleSize,
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(widget.circleSize / 2),
                          topRight: Radius.circular(widget.circleSize / 2),
                        ),
                        color:
                            widget.tabItems[selectedPos!].circleStrokeColor ??
                                widget.barBackgroundColor,
                        boxShadow: widget.backgroundBoxShadow,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(widget.circleSize / 2),
                          bottomRight: Radius.circular(widget.circleSize / 2),
                        ),
                        color:
                            widget.tabItems[selectedPos!].circleStrokeColor ??
                                widget.barBackgroundColor,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.all(widget.circleStrokeWidth),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.tabItems[selectedPos!].circleColor),
              ),
            ],
          ),
        ),
      ),
    );

    // Here are the Icons and texts of items
    boxes.asMap().forEach((int pos, Rect r) {
      double iconSize = widget.iconsSize;

      // Vertical position of the icons changes dynamically during the animation
      double iconY = (pos == selectedPos)
          ? maxShadowHeight + widget.circleStrokeWidth + ((widget.circleSize - widget.circleStrokeWidth * 2 - iconSize) / 2)
          : r.top + ((widget.barHeight - iconSize) / 2);

      // Handle animated interpolation for icons transitioning state
      if (pos == previousSelectedPos) {
        double startY = maxShadowHeight + widget.circleStrokeWidth + ((widget.circleSize - widget.circleStrokeWidth * 2 - iconSize) / 2);
        double endY = r.top + ((widget.barHeight - iconSize) / 2);
        iconY = startY + (endY - startY) * itemsAnimation.value;
      } else if (pos == selectedPos) {
        double startY = r.top + ((widget.barHeight - iconSize) / 2);
        double endY = maxShadowHeight + widget.circleStrokeWidth + ((widget.circleSize - widget.circleStrokeWidth * 2 - iconSize) / 2);
        iconY = startY + (endY - startY) * itemsAnimation.value;
      }

      double iconX = r.left + ((r.width - iconSize) / 2);

      // Icon widget wrapped in Positioned
      Color iconColor = pos == selectedPos
          ? widget.selectedIconColor
          : widget.normalIconColor;
      double scaleFactor = pos == selectedPos ? 1.2 : 1.0;
      
      children.add(
        Positioned(
          left: iconX,
          top: iconY,
          child: Transform.scale(
            scale: scaleFactor,
            child: Icon(
              widget.tabItems[pos].icon,
              size: iconSize,
              color: iconColor,
            ),
          ),
        ),
      );

      // Text widget wrapped in Positioned
      double textHeight = fullHeight - widget.circleSize;
      double opacity = _itemsSelectedState[pos];
      if (opacity < 0.0) {
        opacity = 0.0;
      } else if (opacity > 1.0) {
        opacity = 1.0;
      }

      children.add(
        Positioned(
          left: r.left,
          bottom: 0,
          child: Container(
            width: r.width,
            height: textHeight,
            child: Center(
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
        ),
      );

      // Gesture Detectors wrapped in Positioned.fromRect
      if (pos != selectedPos) {
        children.add(
          Positioned.fromRect(
            rect: r,
            child: GestureDetector(
              onTap: () {
                _controller!.value = pos;
              },
            ),
          ),
        );
      } else if (widget.allowSelectedIconCallback == true) {
        Rect selectedRect = Rect.fromLTWH(r.left, 0, r.width, fullHeight);
        children.add(
          Positioned.fromRect(
            rect: selectedRect,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(40.0)),
              child: GestureDetector(onTap: _selectedCallback),
            ),
          ),
        );
      }
    });

    return Stack(
      children: children,
    );
  }

  void _setSelectedPos(int? pos) {
    previousSelectedPos = selectedPos;
    selectedPos = pos;

    itemsController.forward(from: 0.0);

    selectedPosAnimation = makeSelectedPosAnimation(
        previousSelectedPos!.toDouble(), selectedPos!.toDouble());
    selectedPosAnimation.addListener(onSelectedPosAnimate);

    _selectedCallback();
  }

  void _selectedCallback() {
    if (widget.selectedCallback != null) {
      widget.selectedCallback!(selectedPos);
    }
  }

  @override
  void dispose() {
    itemsController.dispose();
    _controller!.removeListener(_newSelectedPosNotify);
    super.dispose();
  }
}

class CircularBottomNavigationController extends ValueNotifier<int?> {
  CircularBottomNavigationController(int? value) : super(value);
}