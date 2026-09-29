import 'package:flutter/material.dart';
import 'package:rent_car/widgets/painters/speedometer.dart';

class Speedometer extends StatefulWidget {
  const Speedometer({
    super.key,
    required this.value,
    required this.maxValue,
    this.size = 200,
    this.label = 'MAX SPEED',
    this.unit = 'KM/H',
    this.decimals = 0,
    this.gradientColors,
    this.animateOnMount = true,
  });

  final double value;
  final double maxValue;
  final double size;

  final String label;

  final String unit;

  final int decimals;

  final List<Color>? gradientColors;

  final bool animateOnMount;

  @override
  State<Speedometer> createState() => _SpeedometerState();
}

class _SpeedometerState extends State<Speedometer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  double _from = 0;

  @override
  void initState() {
    super.initState();
    if (widget.animateOnMount) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      );
      _animation = Tween<double>(begin: 0, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller = AnimationController(vsync: this, duration: Duration.zero);
      _animation = AlwaysStoppedAnimation(widget.value);
    }
  }

  @override
  void didUpdateWidget(covariant Speedometer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _from = oldWidget.value;
      _animation = Tween<double>(begin: _from, end: widget.value).animate(
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
            painter: SpeedometerPainter(
              value: _animation.value,
              maxValue: widget.maxValue,
              unit: widget.unit,
              caption: widget.label,
              decimals: widget.decimals,
            ),
          );
        },
      ),
    );
  }
}
