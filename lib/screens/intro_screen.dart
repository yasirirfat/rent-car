import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/main.dart';
import 'package:rent_car/widgets/painters/aurora_background.dart';
import 'package:rent_car/widgets/painters/hero_banner_painter.dart';

/// Animated splash / intro screen.
///
/// Layers a painted aurora backdrop, an expanding dashed halo, the brand logo
/// and a staggered entrance for the title and description.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _spin;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _spin.dispose();
    _pulse.dispose();
    super.dispose();
  }

  /// Helper to stagger a child animation inside the entrance timeline.
  Animation<double> _stage(double start, double end, Curve curve) {
    return CurvedAnimation(
      parent: _entrance,
      curve: Interval(start, end, curve: curve),
    );
  }

  void _enterApp() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (ctx, err, stack) => const MainWrapper(),
        transitionsBuilder: (ctx, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColor.obsidian,
      body: AuroraBackground(
        showGrid: true,
        gridOpacity: 0.045,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // --- Rotating halo + logo ---
                SizedBox(
                  width: 230,
                  height: 230,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Counter-rotating dashed rings.
                      AnimatedBuilder(
                        animation: _spin,
                        builder: (context, _) {
                          return Transform.rotate(
                            angle: _spin.value * 2 * math.pi,
                            child: CustomPaint(
                              size: const Size(230, 230),
                              painter: DashedRingPainter(
                                color: AppColor.primary,
                                opacity: 0.5,
                                dashCount: 64,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      ),
                      AnimatedBuilder(
                        animation: _spin,
                        builder: (context, _) {
                          return Transform.rotate(
                            angle: -_spin.value * 2 * math.pi * 0.6,
                            child: CustomPaint(
                              size: const Size(176, 176),
                              painter: DashedRingPainter(
                                color: AppColor.secondary,
                                opacity: 0.35,
                                dashCount: 40,
                                dashFraction: 0.3,
                                strokeWidth: 1.4,
                              ),
                            ),
                          );
                        },
                      ),
                      // Brand logo, scaled in.
                      ScaleTransition(
                        scale: _stage(0.0, 0.5, Curves.easeOutBack),
                        child: FadeTransition(
                          opacity: _stage(0.0, 0.4, Curves.easeOut),
                          child: SizedBox(
                            width: 118,
                            height: 118,
                            child: Image.asset(
                              'assets/images/flogo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, err, stack) => const Icon(
                                Icons.directions_car_filled_rounded,
                                color: AppColor.amber,
                                size: 70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 44),

                // --- Title ---
                FadeTransition(
                  opacity: _stage(0.25, 0.65, Curves.easeOut),
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.28),
                      end: Offset.zero,
                    ).animate(_stage(0.25, 0.75, Curves.easeOutCubic)),
                    child: const Column(
                      children: [
                        Text(
                          'RENT A',
                          style: TextStyle(
                            color: AppColor.textPrimary,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.5,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'FERRARI',
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            height: 1.05,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'LUXURY CAR RENTAL',
                          style: TextStyle(
                            color: AppColor.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.05),

                // --- Description ---
                FadeTransition(
                  opacity: _stage(0.45, 0.85, Curves.easeOut),
                  child: const Text(
                    'Find and experience the emotion of our luxury cars, '
                    'delivered to your door at a price that makes sense.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 13.5,
                      height: 1.65,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // --- CTA ---
                FadeTransition(
                  opacity: _stage(0.6, 1.0, Curves.easeOut),
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(_stage(0.6, 1.0, Curves.easeOutCubic)),
                    child: _EnterButton(
                      pulse: _pulse,
                      onTap: _enterApp,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                FadeTransition(
                  opacity: _stage(0.75, 1.0, Curves.easeOut),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 13,
                        color: AppColor.textMuted,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '20 cars  •  4.8 avg rating  •  Free cancellation',
                        style: TextStyle(
                          color: AppColor.textMuted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wide CTA with a soft pulsing ring behind it.
class _EnterButton extends StatelessWidget {
  const _EnterButton({required this.pulse, required this.onTap});

  final Animation<double> pulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          final t = pulse.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Expanding halo.
              Container(
                width: 300,
                height: 62 + t * 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withValues(alpha: 0.28 - t * 0.14),
                      blurRadius: 30 + t * 18,
                      spreadRadius: 1 + t * 3,
                    ),
                  ],
                ),
              ),
              Container(
                width: 290,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColor.brandGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Explore the Fleet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(width: 9),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
