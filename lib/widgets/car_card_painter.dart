import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

class CarCardPainter extends CustomPainter {
  CarCardPainter({
    this.accent,
    this.glow = false,
    this.showAccentArc = true,
    this.showShadow = true,
  });

  final Color? accent;

  final bool glow;

  final bool showAccentArc;

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

    canvas.drawPath(path, Paint()..color = AppColor.surface);

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColor.stroke,
    );

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

    path.moveTo(w * 0.02, h * 0.78);

    path.lineTo(w * 0.10, h * 0.66);
    path.quadraticBezierTo(w * 0.16, h * 0.62, w * 0.22, h * 0.60);

    path.lineTo(w * 0.34, h * 0.36);
    path.quadraticBezierTo(w * 0.40, h * 0.28, w * 0.50, h * 0.27);

    path.quadraticBezierTo(w * 0.62, h * 0.27, w * 0.70, h * 0.38);

    path.quadraticBezierTo(w * 0.80, h * 0.44, w * 0.90, h * 0.50);
    path.quadraticBezierTo(w * 0.98, h * 0.54, w * 0.98, h * 0.70);
    path.lineTo(w * 0.98, h * 0.78);

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

    canvas.drawPath(path, base);

    final wheelPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = (accent ?? color).withValues(alpha: opacity * 2.4);
    canvas.drawCircle(Offset(w * 0.26, h * 0.79), h * 0.10, wheelPaint);
    canvas.drawCircle(Offset(w * 0.72, h * 0.79), h * 0.10, wheelPaint);

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
