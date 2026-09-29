import 'package:flutter/material.dart';

class AppColor {
  AppColor._();

  static const Color obsidian = Color(0xFFF3F5F9);

  static const Color canvas = Color(0xFFF3F5F9);

  static const Color surface = Color(0xFFFFFFFF);

  static const Color surfaceHigh = Color(0xFFF5F7FA);

  static const Color surfaceHighest = Color(0xFFEBEFF5);

  static const Color stroke = Color(0xFFE4E8EF);

  static const Color strokeStrong = Color(0xFFCDD5E0);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF5A6472);
  static const Color textMuted = Color(0xFF8A93A2);

  static const Color scrim = Color(0xFF0B1220);

  static const Color primary = Color(0xFF2F6BE4);

  static const Color primaryDeep = Color(0xFF1D4FBF);

  static const Color secondary = primary;

  static const Color secondaryDeep = primaryDeep;

  static const Color chrome = Color(0xFF8A93A2);

  static const Color amber = Color(0xFFF0A82E);

  static const Color success = Color(0xFF19A974);

  static const Color danger = Color(0xFFE5484D);

  static const Color info = primary;

  static const Color violetDeep = primaryDeep;

  static const Color tealDeep = secondaryDeep;

  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, primary],
  );

  static const LinearGradient brandGradientReverse = LinearGradient(
    colors: [primary, primary],
  );

  static const LinearGradient chromeGradient = LinearGradient(
    colors: [Color(0xFFB9C1CC), Color(0xFFB9C1CC)],
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [amber, amber],
  );

  static const LinearGradient appBackground = LinearGradient(
    colors: [canvas, canvas],
  );

  static const LinearGradient glassFill = LinearGradient(
    colors: [surface, surface],
  );

  static const LinearGradient navBarGradient = LinearGradient(
    colors: [surface, surface],
  );

  static const LinearGradient introGradient = LinearGradient(
    colors: [canvas, canvas],
  );

  static const LinearGradient surfaceSheen = LinearGradient(
    colors: [Color(0x00000000), Color(0x00000000)],
  );

  static const Color yellow = amber;

  static const Color white = surface;

  static const Color black = textPrimary;

  static const Color darkGrey = surfaceHigh;

  static const Color containerColor = surfaceHigh;

  static const double radiusChip = 10;

  static const double radiusControl = 14;

  static const double radiusCard = 18;

  static const double radiusPanel = 24;

  static Color accentFor(int index) => primary;

  static LinearGradient tintedGradient(int index) {
    final base = accentFor(index);
    return LinearGradient(colors: [base, base]);
  }

  static List<BoxShadow> glow(
    Color color, {
    double opacity = 0.28,
    double blur = 18,
    double spread = 0,
  }) {
    final tint = Color.lerp(const Color(0xFF0B1220), color, 0.22)!;
    return [
      BoxShadow(
        color: tint.withValues(alpha: opacity * 0.55),
        blurRadius: blur,
        spreadRadius: spread,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static List<BoxShadow> get cardShadow => const [
    BoxShadow(color: Color(0x0F101828), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x14101828), blurRadius: 16, offset: Offset(0, 6)),
  ];

  static List<BoxShadow> get subtleShadow => const [
    BoxShadow(color: Color(0x0F101828), blurRadius: 8, offset: Offset(0, 3)),
  ];

  static Color get surfaceVeil => surface;

  static Color get surfaceVeilStrong => surfaceHigh;

  static Color get surfaceVeilMax => surfaceHigh;

  static Color accentVeil(Color accent, {double alpha = 0.10}) =>
      accent.withValues(alpha: alpha);

  static Color accentVeilBorder(Color accent, {double alpha = 0.32}) =>
      accent.withValues(alpha: alpha);

  static List<BoxShadow> neumorphicRaised({Color? base, double depth = 1.0}) {
    return [
      const BoxShadow(
        color: Color(0x14101828),
        blurRadius: 14,
        offset: Offset(0, 6),
      ),
      if (depth > 1.2)
        const BoxShadow(
          color: Color(0x0D101828),
          blurRadius: 26,
          offset: Offset(0, 12),
        ),
    ];
  }

  static List<BoxShadow> neumorphicInset({Color? base, double depth = 1.0}) =>
      const [];

  static BoxDecoration panel({
    Color? color,
    double radius = 18,
    Color? borderColor,
    bool shadow = true,
    double borderWidth = 1,
  }) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? stroke, width: borderWidth),
      boxShadow: shadow ? cardShadow : null,
    );
  }
}
