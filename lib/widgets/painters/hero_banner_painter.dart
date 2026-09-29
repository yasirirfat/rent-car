import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

class HeroBannerPainter extends CustomPainter {
  HeroBannerPainter({
    this.accent = AppColor.primary,
    this.fill,
    this.background,
    this.radius = AppColor.radiusPanel,
  });

  final Color accent;

  final Color? fill;

  final Color? background;

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.5),
      Radius.circular(radius),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(0.5).translate(0, 6),
        Radius.circular(radius),
      ),
      Paint()
        ..color = const Color(0xFF101828).withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..color =
            fill ??
            Color.alphaBlend(accent.withValues(alpha: 0.07), AppColor.surface),
    );

    canvas.drawRRect(
      rrect.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColor.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant HeroBannerPainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.fill != fill ||
      oldDelegate.background != background ||
      oldDelegate.radius != radius;
}

class DashedRingPainter extends CustomPainter {
  DashedRingPainter({
    this.color = AppColor.secondary,
    this.dashCount = 48,
    this.dashFraction = 0.45,
    this.strokeWidth = 2,
    this.opacity = 0.4,
  });

  final Color color;
  final int dashCount;
  final double dashFraction;
  final double strokeWidth;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - strokeWidth;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final step = (math.pi * 2) / dashCount;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = color.withValues(alpha: opacity);

    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, step * i, step * dashFraction, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DashedRingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
