import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

class SpeedometerPainter extends CustomPainter {
  SpeedometerPainter({
    required this.value,
    required this.maxValue,
    this.trackColor,
    this.gradientColors,
    this.showTicks = true,
    this.showLabels = true,
    this.labelFormatter,
    this.unit = 'KM/H',
    this.caption = 'MAX SPEED',
    this.decimals = 0,
  });

  final double value;

  final double maxValue;

  final Color? trackColor;

  final List<Color>? gradientColors;

  final bool showTicks;
  final bool showLabels;
  final String Function(double value)? labelFormatter;

  final String unit;

  final String caption;

  final int decimals;

  static const double startAngle = 150;

  static const double sweepAngle = 240;

  static const double endAngle = startAngle + sweepAngle;

  static const double _rTickOuter = 0.98;
  static const double _rTickMajorInner = 0.90;
  static const double _rTickMinorInner = 0.935;
  static const double _rNumerals = 0.815;
  static const double _rArc = 0.66;
  static const double _rArcStroke = 0.062;
  static const double _rFanOuter = 0.885;
  static const double _rNeedle = 0.60;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    if (radius <= 0) return;

    final progress = maxValue <= 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);

    _paintBezel(canvas, center, radius);

    _paintPowerBand(canvas, center, radius);

    if (showTicks) _paintTicks(canvas, center, radius);

    if (showLabels) _paintNumerals(canvas, center, radius);

    _paintTrackAndValue(canvas, center, radius, progress);

    _paintNeedle(canvas, center, radius, progress);
    _paintHub(canvas, center, radius);

    _paintReadout(canvas, center, radius);
    _paintCaption(canvas, center, radius);
  }

  void _paintBezel(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius * 0.995,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.012
        ..color = AppColor.stroke.withValues(alpha: 0.85),
    );

    canvas.drawCircle(
      center,
      radius * 0.955,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.020
        ..color = AppColor.surfaceHighest,
    );
  }

  void _paintPowerBand(Canvas canvas, Offset center, double radius) {
    final bandStart = startAngle + sweepAngle * 0.72;
    final bandSweep = sweepAngle * 0.28;

    final bandRect = Rect.fromCircle(
      center: center,
      radius: radius * _rFanOuter * 0.93,
    );

    canvas.drawArc(
      bandRect,
      _rad(bandStart),
      _rad(bandSweep),
      true,
      Paint()..color = AppColor.primary.withValues(alpha: 0.07),
    );
  }

  void _paintTicks(Canvas canvas, Offset center, double radius) {
    const majorCount = 9;
    const minorsPerMajor = 4;
    final step = sweepAngle / ((majorCount - 1) * minorsPerMajor);

    final majorPaint = Paint()..strokeCap = StrokeCap.round;
    final minorPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = radius * 0.010
      ..color = AppColor.textPrimary.withValues(alpha: 0.22);

    for (var i = 0; i < majorCount; i++) {
      final angle = startAngle + (sweepAngle / (majorCount - 1)) * i;
      final rad = _rad(angle);
      final isFirst = i == 0;
      final isLast = i == majorCount - 1;
      final isRedline = i >= majorCount - 3;

      majorPaint
        ..strokeWidth = radius * (isLast ? 0.028 : 0.024)
        ..color = isLast
            ? AppColor.primary
            : (isRedline ? AppColor.primary : AppColor.textPrimary).withValues(
                alpha: isFirst ? 0.70 : 0.62,
              );

      _drawRadialLine(
        canvas,
        center,
        rad,
        radius * _rTickMajorInner,
        radius * _rTickOuter,
        majorPaint,
      );

      if (i < majorCount - 1) {
        for (var m = 1; m < minorsPerMajor; m++) {
          final subAngle = angle + step * m;
          _drawRadialLine(
            canvas,
            center,
            _rad(subAngle),
            radius * _rTickMinorInner,
            radius * _rTickOuter,
            minorPaint,
          );
        }
      }
    }
  }

  void _drawRadialLine(
    Canvas canvas,
    Offset center,
    double rad,
    double rInner,
    double rOuter,
    Paint paint,
  ) {
    final cos = math.cos(rad);
    final sin = math.sin(rad);
    canvas.drawLine(
      Offset(center.dx + rInner * cos, center.dy + rInner * sin),
      Offset(center.dx + rOuter * cos, center.dy + rOuter * sin),
      paint,
    );
  }

  void _paintNumerals(Canvas canvas, Offset center, double radius) {
    const majorCount = 9;
    final formatter = labelFormatter ?? (v) => v.round().toString();
    final fontSize = radius * 0.108;

    for (var i = 0; i < majorCount; i++) {
      final v = maxValue * (i / (majorCount - 1));
      final angle = startAngle + (sweepAngle / (majorCount - 1)) * i;
      final rad = _rad(angle);
      final pos = Offset(
        center.dx + radius * _rNumerals * math.cos(rad),
        center.dy + radius * _rNumerals * math.sin(rad),
      );

      final isLast = i == majorCount - 1;
      final tp = TextPainter(
        text: TextSpan(
          text: formatter(v),
          style: TextStyle(
            color: isLast
                ? AppColor.primary
                : AppColor.textPrimary.withValues(alpha: 0.55),
            fontSize: fontSize,
            fontWeight: isLast ? FontWeight.w800 : FontWeight.w600,
            height: 1.0,
            letterSpacing: -0.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  void _paintTrackAndValue(
    Canvas canvas,
    Offset center,
    double radius,
    double progress,
  ) {
    final arcRadius = radius * _rArc;
    final arcRect = Rect.fromCircle(center: center, radius: arcRadius);
    final strokeWidth = radius * _rArcStroke;

    canvas.drawArc(
      arcRect,
      _rad(startAngle),
      _rad(sweepAngle),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..color = (trackColor ?? AppColor.textPrimary).withValues(alpha: 0.08),
    );

    final valueSweep = sweepAngle * progress;
    if (valueSweep <= 0.5) return;

    canvas.drawArc(
      arcRect,
      _rad(startAngle),
      _rad(valueSweep),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth * 1.55
        ..color = AppColor.primary.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawArc(
      arcRect,
      _rad(startAngle),
      _rad(valueSweep),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..color = AppColor.primary,
    );

    final tip = pointOnArc(center, arcRadius, startAngle + valueSweep);
    canvas.drawCircle(
      tip,
      strokeWidth * 0.34,
      Paint()..color = AppColor.surface,
    );
    canvas.drawCircle(
      tip,
      strokeWidth * 0.18,
      Paint()..color = AppColor.primary,
    );
  }

  void _paintNeedle(
    Canvas canvas,
    Offset center,
    double radius,
    double progress,
  ) {
    final angle = startAngle + sweepAngle * progress;

    final tailAngle = angle + 180;
    canvas.drawLine(
      center,
      pointOnArc(center, radius * 0.13, tailAngle),
      Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = radius * 0.030
        ..color = AppColor.strokeStrong,
    );

    final needleLength = radius * _rNeedle;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(_rad(angle));

    final path = Path()
      ..moveTo(-radius * 0.05, -radius * 0.026)
      ..lineTo(needleLength * 0.55, -radius * 0.015)
      ..lineTo(needleLength, 0)
      ..lineTo(needleLength * 0.55, radius * 0.015)
      ..lineTo(-radius * 0.05, radius * 0.026)
      ..close();

    canvas.drawPath(path, Paint()..color = AppColor.primary);
    canvas.restore();
  }

  void _paintHub(Canvas canvas, Offset center, double radius) {
    final hubR = radius * 0.115;

    canvas.drawCircle(
      center,
      hubR * 1.35,
      Paint()..color = AppColor.surfaceHighest,
    );

    canvas.drawCircle(center, hubR, Paint()..color = AppColor.surface);
    canvas.drawCircle(
      center,
      hubR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.006
        ..color = AppColor.primary.withValues(alpha: 0.35),
    );

    canvas.drawCircle(center, hubR * 0.34, Paint()..color = AppColor.primary);
  }

  void _paintReadout(Canvas canvas, Offset center, double radius) {
    final valueText = value.toStringAsFixed(decimals);

    final valueTp = TextPainter(
      text: TextSpan(
        text: valueText,
        style: TextStyle(
          color: AppColor.textPrimary,
          fontSize: radius * 0.30,
          fontWeight: FontWeight.w800,
          height: 1.0,
          letterSpacing: -radius * 0.012,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final unitTp = TextPainter(
      text: TextSpan(
        text: unit,
        style: TextStyle(
          color: AppColor.primary,
          fontSize: radius * 0.072,
          fontWeight: FontWeight.w800,
          height: 1.0,
          letterSpacing: radius * 0.020,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final gap = radius * 0.030;
    final blockHeight = valueTp.height + gap + unitTp.height;
    final blockWidth = math.max(valueTp.width, unitTp.width);

    final hubBottom = center.dy + radius * 0.155;
    final blockTop = math.min(
      hubBottom + radius * 0.045,
      center.dy + radius * 0.68 - blockHeight,
    );

    _readoutBand = Rect.fromLTWH(
      center.dx - blockWidth / 2,
      blockTop,
      blockWidth,
      blockHeight,
    );
    _valueTextRect = Rect.fromLTWH(
      center.dx - valueTp.width / 2,
      blockTop,
      valueTp.width,
      valueTp.height,
    );

    valueTp.paint(canvas, Offset(center.dx - valueTp.width / 2, blockTop));
    unitTp.paint(
      canvas,
      Offset(center.dx - unitTp.width / 2, blockTop + valueTp.height + gap),
    );
  }

  Rect get readoutBand => _readoutBand;
  Rect _readoutBand = Rect.zero;

  Rect get valueTextRect => _valueTextRect;
  Rect _valueTextRect = Rect.zero;

  void _paintCaption(Canvas canvas, Offset center, double radius) {
    if (caption.isEmpty) return;

    final tp = TextPainter(
      text: TextSpan(
        text: caption,
        style: TextStyle(
          color: AppColor.textMuted,
          fontSize: radius * 0.070,
          fontWeight: FontWeight.w700,
          height: 1.0,
          letterSpacing: radius * 0.018,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final fallback = center.dy + radius * 0.735;
    final top = _readoutBand == Rect.zero
        ? fallback
        : math.min(_readoutBand.bottom + radius * 0.030, fallback);
    tp.paint(canvas, Offset(center.dx - tp.width / 2, top));
  }

  Offset pointOnArc(Offset center, double radius, double angleDeg) {
    final rad = _rad(angleDeg);
    return Offset(
      center.dx + radius * math.cos(rad),
      center.dy + radius * math.sin(rad),
    );
  }

  double _rad(double deg) => deg * math.pi / 180;

  @override
  bool shouldRepaint(covariant SpeedometerPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.showTicks != showTicks ||
        oldDelegate.showLabels != showLabels ||
        oldDelegate.unit != unit ||
        oldDelegate.caption != caption ||
        oldDelegate.decimals != decimals;
  }
}
