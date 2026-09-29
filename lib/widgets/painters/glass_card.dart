import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

/// Paints a raised panel for the light theme: a solid white surface, a soft
/// two-layer shadow, and a hairline border that can carry an accent.
///
/// Deliberately plain. Earlier revisions layered a translucent frosted fill, an
/// accent bloom in the corner and a top sheen; on the light theme all three
/// read as smudges rather than depth. Elevation here comes from exactly two
/// signals - the shadow and the border - which is what a clean light UI uses.
///
/// The old constructor arguments ([glowColor], [glowOpacity], [fillTop],
/// [fillBottom], [innerHighlight]) are retained so call sites keep compiling.
/// They no longer paint anything; use [surface] for a flat override.
class GlassCardPainter extends CustomPainter {
  GlassCardPainter({
    this.radius = 20,
    this.borderGradient,
    this.borderWidth = 1,
    this.glowColor,
    this.glowOpacity = 0.0,
    this.fillTop,
    this.fillBottom,
    this.surface,
    this.innerHighlight = false,
    this.shadow = true,
    this.borderColor,
  });

  final double radius;
  final Gradient? borderGradient;
  final double borderWidth;

  /// Retained for source compatibility - no longer paints a bloom.
  final Color? glowColor;
  final double glowOpacity;

  /// Retained for source compatibility - the fill is flat now.
  final Color? fillTop;
  final Color? fillBottom;

  /// Flat base colour of the panel. Defaults to [AppColor.surface].
  final Color? surface;

  /// Retained for source compatibility - no longer paints a sheen.
  final bool innerHighlight;
  final bool shadow;

  /// Explicit hairline colour. Falls back to [AppColor.stroke].
  final Color? borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // 1. Elevation: a wide ambient shadow plus a tight contact shadow.
    if (shadow) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.deflate(0.5).translate(0, 6),
          Radius.circular(radius),
        ),
        Paint()
          ..color = const Color(0xFF101828).withValues(alpha: 0.055)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.deflate(0.5).translate(0, 2),
          Radius.circular(radius),
        ),
        Paint()
          ..color = const Color(0xFF101828).withValues(alpha: 0.045)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // 2. Surface fill - one flat colour, no gradient.
    canvas.drawRRect(
      rrect,
      Paint()..color = surface ?? fillTop ?? AppColor.surface,
    );

    // 3. Hairline border.
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    if (borderColor != null) {
      borderPaint.color = borderColor!;
    } else if (borderGradient != null) {
      borderPaint.shader = borderGradient!.createShader(rect);
    } else {
      borderPaint.color = AppColor.stroke;
    }
    canvas.drawRRect(rrect.deflate(borderWidth / 2), borderPaint);
  }

  @override
  bool shouldRepaint(covariant GlassCardPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.borderGradient != borderGradient ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.surface != surface ||
        oldDelegate.shadow != shadow ||
        oldDelegate.borderWidth != borderWidth;
  }
}

/// Convenience widget wrapping [GlassCardPainter].
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.accent,
    this.glowStrength = 0.0,
    this.borderWidth = 1,
    this.showBorder = true,
    this.margin,
    this.surface,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// When provided, the card's border picks up a faint tint of the accent.
  final Color? accent;

  /// Retained for source compatibility - no longer paints a bloom.
  final double glowStrength;
  final double borderWidth;
  final bool showBorder;
  final EdgeInsetsGeometry? margin;

  /// Overrides the flat panel colour.
  final Color? surface;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: CustomPaint(
        painter: GlassCardPainter(
          radius: radius,
          borderWidth: borderWidth,
          surface: surface,
          shadow: shadow,
          borderColor: showBorder
              ? (accent != null
                    ? accent!.withValues(alpha: 0.28)
                    : AppColor.stroke)
              : null,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// A soft circular accent badge placed behind centred content.
///
/// Previously an additive radial halo; on the light theme it is a flat tinted
/// disc with a ring, which stays legible without adding a glow.
class AccentHalo extends StatelessWidget {
  const AccentHalo({
    super.key,
    this.color = AppColor.primary,
    this.size = 260,
    this.opacity = 0.28,
    this.child,
  });

  final Color color;
  final double size;
  final double opacity;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _HaloPainter(color: color, opacity: opacity),
          ),
          ?child,
        ],
      ),
    );
  }
}

class _HaloPainter extends CustomPainter {
  _HaloPainter({required this.color, required this.opacity});

  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    // Flat tinted disc - no radial falloff.
    canvas.drawCircle(
      center,
      radius * 0.72,
      Paint()..color = color.withValues(alpha: opacity * 0.35),
    );

    // Concentric rings for structure.
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: opacity * 0.45);
    for (var i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * 0.72 * (i / 3), ring);
    }
  }

  @override
  bool shouldRepaint(covariant _HaloPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.opacity != opacity;
}

/// Convenience: draw an arc sweep between [start] and [end] degrees.
void drawArcSweep(
  Canvas canvas,
  Rect rect,
  double startDeg,
  double endDeg,
  Paint paint,
) {
  canvas.drawArc(
    rect,
    startDeg * math.pi / 180,
    (endDeg - startDeg) * math.pi / 180,
    false,
    paint,
  );
}
