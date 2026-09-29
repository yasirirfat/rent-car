import 'package:flutter/material.dart';

/// Fades and lifts its child into place once, shortly after first build.
///
/// Used for list items so the home screen assembles itself rather than
/// snapping in. The motion is deliberately small - 14px of travel over 260ms -
/// because the brief asks for animations that only ever *support* the interface.
///
/// The stagger is capped so a long list never feels sluggish: item 0 starts
/// immediately and item 6 onward starts at the same time as item 6.
class EntranceFade extends StatefulWidget {
  const EntranceFade({
    super.key,
    required this.child,
    this.order = 0,
    this.offset = 14,
    this.duration = const Duration(milliseconds: 260),
  });

  final Widget child;

  /// Position in the list. Drives the stagger delay.
  final int order;

  /// Vertical travel distance in logical pixels.
  final double offset;

  final Duration duration;

  /// Maximum number of staggers before the delay stops growing.
  static const int maxStagger = 6;

  @override
  State<EntranceFade> createState() => _EntranceFadeState();
}

class _EntranceFadeState extends State<EntranceFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  /// Set once the entrance has finished, so the wrapper can hand the child
  /// straight back and stop compositing.
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    final steps = widget.order.clamp(0, EntranceFade.maxStagger);
    final delay = Duration(milliseconds: 45 * steps);

    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        // Drop the Opacity/Transform layers for good.
        setState(() => _done = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Once settled, return the bare child.
    //
    // `Opacity` forces a saveLayer on every frame it is present, and a long
    // list keeps one per card alive forever - an animation that has already
    // finished should cost nothing at scroll time.
    if (_done) return widget.child;

    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        return Opacity(
          opacity: _curve.value,
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - _curve.value)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
