import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

/// A circular progress ring with a gradient stroke, soft track and an
/// optional icon or label in the middle. Animates from 0 to [value].
class ProgressRing extends StatefulWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 64,
    this.strokeWidth = 5,
    this.gradientColors,
    this.trackColor,
    this.child,
    this.duration = const Duration(milliseconds: 1100),
    this.startAngle = -90,
  });

  /// 0..1 normalised progress.
  final double value;
  final double size;
  final double strokeWidth;
  final List<Color>? gradientColors;
  final Color? trackColor;
  final Widget? child;
  final Duration duration;
  final double startAngle;

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: _animation.value, end: widget.value)
          .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _RingPainter(
              value: _animation.value,
              strokeWidth: widget.strokeWidth,
              gradientColors: widget.gradientColors,
              trackColor: widget.trackColor,
              startAngle: widget.startAngle,
            ),
            child: Center(child: widget.child),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.strokeWidth,
    this.gradientColors,
    this.trackColor,
    this.startAngle = -90,
  });

  final double value;
  final double strokeWidth;
  final List<Color>? gradientColors;
  final Color? trackColor;
  final double startAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startRad = startAngle * math.pi / 180;
    final progress = value.clamp(0.0, 1.0);

    // Track
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = (trackColor ?? AppColor.textPrimary).withValues(alpha: 0.07),
    );

    if (progress <= 0) return;

    final sweep = math.pi * 2 * progress;

    // Glow
    canvas.drawArc(
      rect,
      startRad,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth * 1.8
        ..color = (gradientColors?.first ?? AppColor.primary)
            .withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.drawArc(
      rect,
      startRad,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..color = gradientColors?.first ?? AppColor.primary,
    );

    // End cap dot
    final endRad = startRad + sweep;
    final dot = Offset(
      center.dx + radius * math.cos(endRad),
      center.dy + radius * math.sin(endRad),
    );
    canvas.drawCircle(
      dot,
      strokeWidth * 0.5,
      Paint()..color = AppColor.textPrimary,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.startAngle != startAngle;
}

/// A horizontal stat bar: label, animated fill and value text. The fill uses
/// a gradient with a bright rounded head.
class StatBar extends StatefulWidget {
  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    this.displayValue,
    this.icon,
    this.accent,
    this.height = 8,
  });

  final String label;
  final double value;
  final double max;
  final String? displayValue;
  final IconData? icon;
  final Color? accent;
  final double height;

  @override
  State<StatBar> createState() => _StatBarState();
}

class _StatBarState extends State<StatBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent ?? AppColor.primary;
    final ratio = widget.max <= 0 ? 0.0 : (widget.value / widget.max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 15, color: accent),
              const SizedBox(width: 7),
            ],
            // The label yields before the value does - the numeric readout is
            // the more important of the two and must stay fully legible.
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColor.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Spacer(),
            Text(
              widget.displayValue ??
                  '${(ratio * 100).toStringAsFixed(0)}%',
              maxLines: 1,
              style: TextStyle(
                color: accent,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ],
        ),
        SizedBox(height: widget.height * 1.1),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, _) {
            return CustomPaint(
              size: Size(double.infinity, widget.height),
              painter: _StatBarPainter(
                progress: ratio * _animation.value,
                accent: accent,
                height: widget.height,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatBarPainter extends CustomPainter {
  _StatBarPainter({
    required this.progress,
    required this.accent,
    required this.height,
  });

  final double progress;
  final Color accent;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(height / 2);
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, height),
      radius,
    );

    canvas.drawRRect(
      track,
      Paint()..color = AppColor.textPrimary.withValues(alpha: 0.07),
    );

    if (progress <= 0) return;

    final fillWidth = size.width * progress;
    final fill = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, fillWidth, height),
      radius,
    );

    // Glow under the fill.
    canvas.drawRRect(
      fill,
      Paint()
        ..color = accent.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawRRect(fill, Paint()..color = accent);

    // Bright head.
    canvas.drawCircle(
      Offset(fillWidth - height / 2, height / 2),
      height * 0.42,
      Paint()..color = AppColor.textPrimary,
    );
  }

  @override
  bool shouldRepaint(covariant _StatBarPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.accent != accent;
}
