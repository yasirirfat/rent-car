import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

/// Background artwork for the home screen hero banner.
///
/// On the light theme this is simply a **solid tinted panel** with a soft
/// shadow and a hairline border. The previous layered violet gradient, radial
/// glow, diagonal streaks and perspective grid have all been removed - the
/// brief rules out gradients and decorative effects, and the car photograph in
/// the banner carries the visual interest on its own.
class HeroBannerPainter extends CustomPainter {
  HeroBannerPainter({
    this.accent = AppColor.primary,
    this.fill,
    this.background,
    this.radius = AppColor.radiusPanel,
  });

  final Color accent;

  /// Flat panel colour. Defaults to a light tint of [accent].
  final Color? fill;

  /// The colour behind the panel, used for the drop shadow.
  final Color? background;

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.5),
      Radius.circular(radius),
    );

    // 1. Soft elevation shadow.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(0.5).translate(0, 6),
        Radius.circular(radius),
      ),
      Paint()
        ..color = const Color(0xFF101828).withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // 2. Flat tinted panel - no gradient.
    canvas.drawRRect(
      rrect,
      Paint()..color = fill ?? Color.alphaBlend(accent.withValues(alpha: 0.07), AppColor.surface),
    );

    // 3. Hairline border.
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

/// A rotating dashed ring used as decoration behind hero content.
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
      canvas.drawArc(
        rect,
        step * i,
        step * dashFraction,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant DashedRingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}
