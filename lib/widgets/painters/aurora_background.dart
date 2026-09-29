import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

/// The base layer of every screen: a **flat, solid** light page.
///
/// This replaced a dark gradient with a drifting additive glow and a faint
/// perspective grid. The brief for the light theme calls for no gradients and
/// no decorative effects, so the backdrop is now a single colour that lets the
/// white cards do all the work.
///
/// The class keeps its original name and options so call sites are unchanged;
/// [gridOpacity], [animate] and [accent] are accepted but no longer produce any
/// visible output. If a screen genuinely needs a tinted backdrop it should pass
/// an explicit [background] colour rather than reintroducing a wash.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({
    super.key,
    this.child,
    this.gridOpacity = 0.0,
    this.showGrid = false,
    this.animate = false,
    this.accent,
    this.background,
  });

  final Widget? child;
  final double gridOpacity;
  final bool showGrid;
  final bool animate;

  /// Retained for source compatibility - no longer used.
  final Color? accent;

  /// Overrides the page colour. Defaults to [AppColor.canvas].
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background ?? AppColor.canvas,
      child: child,
    );
  }
}

/// Retained so any direct `CustomPaint(painter: AuroraPainter(...))` call site
/// still compiles. It now paints nothing: on the light theme the page is a
/// flat colour and this painter has no work to do.
class AuroraPainter extends CustomPainter {
  AuroraPainter({
    this.progress = 0,
    this.gridOpacity = 0,
    this.showGrid = false,
    this.accent,
  });

  final double progress;
  final double gridOpacity;
  final bool showGrid;
  final Color? accent;

  @override
  void paint(Canvas canvas, Size size) {
    // Intentionally empty - see class docs.
  }

  @override
  bool shouldRepaint(covariant AuroraPainter oldDelegate) => false;
}
