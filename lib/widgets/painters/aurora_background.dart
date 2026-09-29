import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

class AuroraBackground extends StatelessWidget {
  const AuroraBackground({
    super.key,
    this.child,
    this.gridOpacity = 0.0,
    this.showGrid = false,
    this.animate = false,
    this.accent,
    this.background,
  });

  final Widget? child;
  final double gridOpacity;
  final bool showGrid;
  final bool animate;

  final Color? accent;

  final Color? background;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: background ?? AppColor.canvas, child: child);
  }
}

class AuroraPainter extends CustomPainter {
  AuroraPainter({
    this.progress = 0,
    this.gridOpacity = 0,
    this.showGrid = false,
    this.accent,
  });

  final double progress;
  final double gridOpacity;
  final bool showGrid;
  final Color? accent;

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant AuroraPainter oldDelegate) => false;
}
