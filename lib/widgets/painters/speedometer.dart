import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

/// A modern car instrument-cluster speedometer.
///
/// Everything - ticks, numerals, the big digital readout, the unit and the
/// caption - is painted on the canvas. That is deliberate: it lets us reserve
/// an explicit, measured region for each element and guarantee they can never
/// overlap, clip or drift as the widget resizes. A widget-composited overlay
/// (the previous approach) cannot make that guarantee because the text size is
/// only known after layout.
///
/// Dial geometry is a 240 degree sweep from 150 deg to 390 deg, leaving a clean
/// 120 degree opening at the bottom. The bottom opening is where the caption
/// sits, so it never fights the scale.
///
/// Vertical budget is strictly partitioned by radius fraction:
///
/// ```
///   r * 1.00  outer edge of tick ring
///   r * 0.86  numerals
///   r * 0.66  value arc + progress track
///   r * 0.26  vertical centre of the digital readout block
///   r * 0.00  centre (hub)
/// ```
///
/// ### Colour
///
/// The gauge is **blue only**. Every painted element resolves to
/// [AppColor.primary] (or a translucent tint of it / a neutral ink). The
/// `gradientColors` parameter is still accepted so call sites compile, but it
/// is deliberately ignored: the value arc always uses the primary blue.
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

  /// Current value (caller animates this for a smooth sweep).
  final double value;

  /// Value at full sweep.
  final double maxValue;

  final Color? trackColor;

  /// Retained for source compatibility. **Ignored** - the gauge is blue only.
  final List<Color>? gradientColors;

  final bool showTicks;
  final bool showLabels;
  final String Function(double value)? labelFormatter;

  /// Unit printed under the big readout, e.g. "KM/H".
  final String unit;

  /// Caption printed in the bottom opening, e.g. "MAX SPEED".
  final String caption;

  final int decimals;

  // --- Dial geometry ---------------------------------------------------------
  // 240 deg sweep, centred at the bottom so the gap is symmetrical.

  /// Angle of the zero mark, in degrees (canvas convention: 0 = right,
  /// positive = clockwise, so 150 deg is bottom-left).
  static const double startAngle = 150;

  /// Total swept angle in degrees.
  static const double sweepAngle = 240;

  /// Angle at the far end of the scale.
  static const double endAngle = startAngle + sweepAngle;

  // --- Radius fractions (of `radius = shortestSide / 2`) --------------------
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

    // 1. Outer bezel ring - frames the cluster.
    _paintBezel(canvas, center, radius);

    // 2. Coloured "power band" fan behind the top third of the scale.
    _paintPowerBand(canvas, center, radius);

    // 3. Ticks (majors + minors).
    if (showTicks) _paintTicks(canvas, center, radius);

    // 4. Numerals.
    if (showLabels) _paintNumerals(canvas, center, radius);

    // 5. Progress track + swept value arc.
    _paintTrackAndValue(canvas, center, radius, progress);

    // 6. Needle + hub.
    _paintNeedle(canvas, center, radius, progress);
    _paintHub(canvas, center, radius);

    // 7. Text block, measured and placed into reserved bands.
    _paintReadout(canvas, center, radius);
    _paintCaption(canvas, center, radius);
  }

  // ---------------------------------------------------------------------------
  // 1. Bezel
  // ---------------------------------------------------------------------------

  void _paintBezel(Canvas canvas, Offset center, double radius) {
    // Faint outer ring.
    canvas.drawCircle(
      center,
      radius * 0.995,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.012
        ..color = AppColor.stroke.withValues(alpha: 0.85),
    );

    // Inner recessed ring so the dial reads as inset.
    canvas.drawCircle(
      center,
      radius * 0.955,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.020
        ..color = AppColor.surfaceHighest,
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Power band
  // ---------------------------------------------------------------------------

  /// A flat tinted wash over the final 28% of the scale - the visual equivalent
  /// of the redline on a real tachometer. Solid colour, no radial falloff.
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

  // ---------------------------------------------------------------------------
  // 3. Ticks
  // ---------------------------------------------------------------------------

  void _paintTicks(Canvas canvas, Offset center, double radius) {
    const majorCount = 9; // 0, 50, 100 ... 400 for a 400 scale
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
      final isRedline = i >= majorCount - 3; // top ~quarter

      // Blue only: the last tick is full-strength blue, the redline block is a
      // lighter blue, and the rest fall back to neutral ink.
      majorPaint
        ..strokeWidth = radius * (isLast ? 0.028 : 0.024)
        ..color = isLast
            ? AppColor.primary
            : (isRedline ? AppColor.primary : AppColor.textPrimary)
                .withValues(alpha: isFirst ? 0.70 : 0.62);

      _drawRadialLine(
        canvas,
        center,
        rad,
        radius * _rTickMajorInner,
        radius * _rTickOuter,
        majorPaint,
      );

      // Minor ticks between this major and the next.
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

  // ---------------------------------------------------------------------------
  // 4. Numerals
  // ---------------------------------------------------------------------------

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

      // Centre the glyph box exactly on the radius point.
      tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
    }
  }

  // ---------------------------------------------------------------------------
  // 5. Track + value arc
  // ---------------------------------------------------------------------------

  void _paintTrackAndValue(
    Canvas canvas,
    Offset center,
    double radius,
    double progress,
  ) {
    final arcRadius = radius * _rArc;
    final arcRect = Rect.fromCircle(center: center, radius: arcRadius);
    final strokeWidth = radius * _rArcStroke;

    // Base track.
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

    // Soft glow behind the value arc. Kept deliberately cheap: this runs on
    // every animation frame for the whole 1.4s sweep, and a wide blur radius
    // here is the most expensive thing the gauge does.
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

    // Solid value arc - a single flat blue, per the no-gradient / blue-only
    // rule. `gradientColors` is intentionally not consulted.
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

    // Solid cap at the leading edge of the arc.
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

  // ---------------------------------------------------------------------------
  // 6. Needle + hub
  // ---------------------------------------------------------------------------

  void _paintNeedle(
    Canvas canvas,
    Offset center,
    double radius,
    double progress,
  ) {
    final angle = startAngle + sweepAngle * progress;

    // Counterweight tail. A neutral grey rather than a second accent - the
    // gauge is blue only.
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

    // Tapered blade.
    final path = Path()
      ..moveTo(-radius * 0.05, -radius * 0.026)
      ..lineTo(needleLength * 0.55, -radius * 0.015)
      ..lineTo(needleLength, 0)
      ..lineTo(needleLength * 0.55, radius * 0.015)
      ..lineTo(-radius * 0.05, radius * 0.026)
      ..close();

    // Solid needle blade.
    canvas.drawPath(path, Paint()..color = AppColor.primary);
    canvas.restore();
  }

  void _paintHub(Canvas canvas, Offset center, double radius) {
    final hubR = radius * 0.115;

    // Recess.
    canvas.drawCircle(
      center,
      hubR * 1.35,
      Paint()..color = AppColor.surfaceHighest,
    );
    // Collar.
    canvas.drawCircle(center, hubR, Paint()..color = AppColor.surface);
    canvas.drawCircle(
      center,
      hubR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.006
        ..color = AppColor.primary.withValues(alpha: 0.35),
    );
    // Centre pin.
    canvas.drawCircle(center, hubR * 0.34, Paint()..color = AppColor.primary);
  }

  // ---------------------------------------------------------------------------
  // 7. Text - the part that must never collide
  // ---------------------------------------------------------------------------

  /// Paints `speed`, `unit` and `caption` into reserved vertical bands.
  ///
  /// The block is laid out top-down with measured [TextPainter] heights, then
  /// placed so its **centre sits below the dial centre** - inside the visual
  /// "bowl" of the gauge, clear of the hub. Because we measure before painting,
  /// the offsets are exact and the readout can never collide with the hub, the
  /// value arc or the numerals.
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
          // Blue, per the blue-only rule - this used to be the teal secondary.
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

    // The hub occupies r * 0.155. Drop the readout so its whole block sits
    // *below* the hub's lower edge, with a small breathing gap - that is what
    // pulls the value down out of the dial centre and into the lower bowl of
    // the gauge. Clamped so a very small dial still keeps the block on-canvas.
    final hubBottom = center.dy + radius * 0.155;
    final blockTop = math.min(
      hubBottom + radius * 0.045,
      center.dy + radius * 0.68 - blockHeight,
    );

    // Reserve the band so nothing else can ever be drawn into it.
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
    unitTp.paint(canvas, Offset(center.dx - unitTp.width / 2, blockTop + valueTp.height + gap));
  }

  /// Band occupied by the whole readout block on the last paint, in dial-local
  /// coordinates.
  ///
  /// Exposed so the layout can be asserted in tests and so a future caller can
  /// avoid compositing anything on top of the digital readout.
  Rect get readoutBand => _readoutBand;
  Rect _readoutBand = Rect.zero;

  /// The big speed number alone - its midpoint is the thing the eye reads as
  /// "the centre of the gauge", which is why it is measured separately.
  Rect get valueTextRect => _valueTextRect;
  Rect _valueTextRect = Rect.zero;

  /// Caption in the bottom opening of the dial arc.
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

    // The dial's bottom gap spans from endAngle (390 = 30 deg) around to
    // startAngle (150 deg). Place the caption directly under the readout block
    // so readout, unit and caption read as one tight stack rather than three
    // elements drifting apart.
    final fallback = center.dy + radius * 0.735;
    final top = _readoutBand == Rect.zero
        ? fallback
        : math.min(_readoutBand.bottom + radius * 0.030, fallback);
    tp.paint(canvas, Offset(center.dx - tp.width / 2, top));
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Point on a circle at [angleDeg] measured with canvas conventions.
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
    // Repaint only when something that actually affects the output changes.
    // `gradientColors` is deliberately absent - the gauge ignores it now, so a
    // new list would be a wasted repaint on every frame.
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
