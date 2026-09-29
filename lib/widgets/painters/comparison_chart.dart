import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

class ComparisonChartPainter extends CustomPainter {
  ComparisonChartPainter({
    required this.entries,
    required this.animation,
    this.showGrid = true,
    this.gridLines = 4,
  });

  final List<ComparisonEntry> entries;

  final double animation;

  final bool showGrid;
  final int gridLines;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    const labelHeight = 34.0;
    final chartHeight = math.max(size.height - labelHeight, 1.0);
    final bandWidth = size.width / entries.length;
    final barWidth = math.min(bandWidth * 0.42, 46.0);

    _paintGrid(canvas, size, chartHeight);

    final bestValue = entries.map((e) => e.value).reduce(math.max);

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final centerX = bandWidth * i + bandWidth / 2;
      final eased = Curves.easeOutCubic.transform(animation.clamp(0.0, 1.0));
      final barHeight = chartHeight * entry.value.clamp(0.0, 1.0) * eased;
      final isBest = entry.value == bestValue && bestValue > 0;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          centerX - barWidth / 2,
          chartHeight - barHeight,
          barWidth,
          barHeight,
        ),
        topLeft: const Radius.circular(7),
        topRight: const Radius.circular(7),
      );

      canvas.drawRRect(
        rect,
        Paint()
          ..color = entry.color.withValues(alpha: isBest ? 0.42 : 0.18)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, isBest ? 14 : 7),
      );

      canvas.drawRRect(rect, Paint()..color = entry.color);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            centerX - barWidth / 2,
            chartHeight - barHeight,
            barWidth,
            3,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = isBest ? AppColor.textPrimary : entry.color,
      );

      _text(
        canvas,
        entry.valueLabel,
        Offset(centerX, chartHeight - barHeight - 17),
        TextStyle(
          color: isBest ? AppColor.amber : AppColor.textSecondary,
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
      );

      _text(
        canvas,
        entry.label,
        Offset(centerX, chartHeight + 12),
        TextStyle(
          color: isBest ? AppColor.textPrimary : AppColor.textMuted,
          fontSize: 11,
          fontWeight: isBest ? FontWeight.w800 : FontWeight.w600,
        ),
      );
    }
  }

  void _paintGrid(Canvas canvas, Size size, double chartHeight) {
    if (!showGrid) return;
    final paint = Paint()
      ..strokeWidth = 1
      ..color = AppColor.stroke.withValues(alpha: 0.55);

    for (var i = 0; i <= gridLines; i++) {
      final y = chartHeight * (i / gridLines);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _text(Canvas canvas, String value, Offset center, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant ComparisonChartPainter oldDelegate) =>
      oldDelegate.animation != animation ||
      oldDelegate.entries.length != entries.length;
}

class ComparisonEntry {
  const ComparisonEntry({
    required this.label,
    required this.value,
    required this.valueLabel,
    required this.color,
  });

  final String label;

  final double value;

  final String valueLabel;

  final Color color;
}

class ComparisonChart extends StatefulWidget {
  const ComparisonChart({super.key, required this.entries, this.height = 190});

  final List<ComparisonEntry> entries;
  final double height;

  @override
  State<ComparisonChart> createState() => _ComparisonChartState();
}

class _ComparisonChartState extends State<ComparisonChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant ComparisonChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries.length != widget.entries.length) {
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
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: ComparisonChartPainter(
            entries: widget.entries,
            animation: _controller.value,
          ),
        ),
      ),
    );
  }
}

class GaugeDot extends StatelessWidget {
  const GaugeDot({
    super.key,
    required this.value,
    this.size = 34,
    this.color = AppColor.secondary,
  });

  final double value;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GaugeDotPainter(value: value.clamp(0.0, 1.0), color: color),
      ),
    );
  }
}

class _GaugeDotPainter extends CustomPainter {
  _GaugeDotPainter({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = AppColor.textPrimary.withValues(alpha: 0.08),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.75,
      math.pi * 1.5 * value,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = color,
    );

    canvas.drawCircle(
      center,
      radius * 0.34,
      Paint()..color = color.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant _GaugeDotPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}
