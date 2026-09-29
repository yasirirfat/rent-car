import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

/// Paints the panel behind a car card in the light theme.
///
/// This is a *custom painter* rendition of the reference card: a white,
/// generously rounded surface, a soft two-layer shadow for lift, a hairline
/// border, and an optional solid accent bar down the left edge that ties the
/// card to the accent colour of its row.
///
/// Deliberately absent: gradients, glows, hatching, corner ticks, chamfers.
/// The card's job is to hold the photograph and the price without competing
/// with either, so every mark here is either structure or a hairline.
class CarCardPainter extends CustomPainter {
  CarCardPainter({
    this.accent,
    this.glow = false,
    this.showAccentArc = true,
    this.showShadow = true,
  });

  final Color? accent;

  /// Retained for source compatibility. On the light theme a coloured glow
  /// reads as a smudge, so this now only deepens the shadow slightly.
  final bool glow;

  /// Draws the short solid accent bar on the left edge.
  final bool showAccentArc;

  /// Allows the shadow to be suppressed (e.g. inside an already-elevated sheet).
  final bool showShadow;

  @override
  void paint(Canvas canvas, Size size) {
    final accent = this.accent ?? AppColor.primary;
    final rect = Offset.zero & size;
    const radius = AppColor.radiusCard;

    final borderRect = rect.deflate(0.5);
    final rrect = RRect.fromRectAndRadius(
      borderRect,
      const Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    // --- 1. Elevation: tight contact shadow + wide ambient shadow ----------
    // Painted as two blurred copies of the same rounded rect, offset downward.
    // On a light background this is what separates the card from the page.
    if (showShadow) {
      final lift = glow ? 1.35 : 1.0;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          borderRect.translate(0, 6 * lift),
          const Radius.circular(radius),
        ),
        Paint()
          ..color = const Color(0xFF101828).withValues(alpha: 0.055 * lift)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 * lift),
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          borderRect.translate(0, 2),
          const Radius.circular(radius),
        ),
        Paint()
          ..color = const Color(0xFF101828).withValues(alpha: 0.045)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // --- 2. Solid white fill. No gradient. ---------------------------------
    canvas.drawPath(path, Paint()..color = AppColor.surface);

    // --- 3. Hairline border. ----------------------------------------------
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColor.stroke,
    );

    // --- 4. Accent spine: a short solid bar on the left edge --------------
    // Square-edged against the card's left side so it reads as a printed tab
    // rather than a floating pill.
    if (showAccentArc) {
      final barHeight = size.height * 0.42;
      final barTop = (size.height - barHeight) / 2;

      canvas.save();
      canvas.clipPath(path);
      canvas.drawRect(
        Rect.fromLTWH(0, barTop, 3.5, barHeight),
        Paint()..color = accent,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CarCardPainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.glow != glow ||
      oldDelegate.showAccentArc != showAccentArc ||
      oldDelegate.showShadow != showShadow;
}

/// Paints a stylised side-profile of a supercar. Used as an offline fallback
/// when a photograph fails to load, and as a faint watermark behind images.
///
/// The shape is deliberately generic so it reads as "sports car" for any asset.
class CarSilhouettePainter extends CustomPainter {
  CarSilhouettePainter({
    this.color = AppColor.textPrimary,
    this.opacity = 0.10,
    this.strokeOnly = false,
    this.accent,
  });

  final Color color;
  final double opacity;
  final bool strokeOnly;
  final Color? accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final base = Paint()
      ..style = strokeOnly ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = 1.6
      ..color = color.withValues(alpha: opacity);

    final path = Path();
    // Start at the front bumper (left), low.
    path.moveTo(w * 0.02, h * 0.78);
    // Nose rising
    path.lineTo(w * 0.10, h * 0.66);
    path.quadraticBezierTo(w * 0.16, h * 0.62, w * 0.22, h * 0.60);
    // Windshield rake up to roof
    path.lineTo(w * 0.34, h * 0.36);
    path.quadraticBezierTo(w * 0.40, h * 0.28, w * 0.50, h * 0.27);
    // Roof to rear glass
    path.quadraticBezierTo(w * 0.62, h * 0.27, w * 0.70, h * 0.38);
    // Rear deck and tail
    path.quadraticBezierTo(w * 0.80, h * 0.44, w * 0.90, h * 0.50);
    path.quadraticBezierTo(w * 0.98, h * 0.54, w * 0.98, h * 0.70);
    path.lineTo(w * 0.98, h * 0.78);
    // Wheels arches along the bottom
    path.lineTo(w * 0.78, h * 0.78);
    path.arcToPoint(
      Offset(w * 0.62, h * 0.78),
      radius: Radius.circular(h * 0.16),
      clockwise: false,
    );
    path.lineTo(w * 0.34, h * 0.78);
    path.arcToPoint(
      Offset(w * 0.18, h * 0.78),
      radius: Radius.circular(h * 0.16),
      clockwise: false,
    );
    path.close();

    // Solid fill only - a gradient would violate the no-gradient rule, so the
    // silhouette is drawn with one flat colour and relies on its outline for
    // definition.
    canvas.drawPath(path, base);

    // Wheels
    final wheelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = (accent ?? color).withValues(alpha: opacity * 2.4);
    canvas.drawCircle(Offset(w * 0.26, h * 0.79), h * 0.10, wheelPaint);
    canvas.drawCircle(Offset(w * 0.72, h * 0.79), h * 0.10, wheelPaint);

    // Ground reflection line
    canvas.drawLine(
      Offset(w * 0.02, h * 0.90),
      Offset(w * 0.98, h * 0.90),
      Paint()
        ..strokeWidth = 1
        ..color = (accent ?? color).withValues(alpha: opacity * 1.2),
    );
  }

  @override
  bool shouldRepaint(covariant CarSilhouettePainter oldDelegate) =>
      oldDelegate.opacity != opacity ||
      oldDelegate.color != color ||
      oldDelegate.strokeOnly != strokeOnly ||
      oldDelegate.accent != accent;
}

/// Paints a hairline separator with a small centred notch. Used between list
/// sections.
///
/// On the light theme the accent is carried by the notch only - the line itself
/// stays neutral so dividers never read as decoration.
class GlowDividerPainter extends CustomPainter {
  GlowDividerPainter({this.accent, this.opacity = 0.35});

  final Color? accent;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final accent = this.accent ?? AppColor.primary;

    canvas.drawRect(
      Rect.fromLTWH(0, size.height / 2 - 0.5, size.width, 1),
      Paint()..color = AppColor.stroke,
    );

    if (size.width > 24) {
      canvas.drawCircle(
        Offset(center.dx, center.dy),
        1.6,
        Paint()..color = accent.withValues(alpha: 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GlowDividerPainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.opacity != opacity;
}
