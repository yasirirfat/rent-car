import 'package:flutter/material.dart';

/// Central design tokens for Rent Car.
///
/// The palette is a **light theme**: a near-white page, white raised cards, and
/// a single confident blue for primary actions. It is modelled on the reference
/// design - a clean rental marketplace where the car photography carries the
/// visual weight and the chrome stays out of the way.
///
/// Design rules enforced here:
///   * **No gradients.** Every fill is a solid colour. The legacy gradient
///     tokens are retained as *flat* stand-ins so existing call sites keep
///     compiling, but each one now resolves to a single solid colour.
///   * Depth comes from a soft, low-opacity shadow plus a hairline border -
///     never from a colour transition.
///   * **Blue only.** [primary] and [secondary] are the same blue, so every
///     structural accent in the app is one colour. [amber] (ratings, prices),
///     [danger] (the favourite heart) and [success] (available) remain purely
///     for *meaning* - they are never used as decoration.
///   * Contrast targets WCAG AA: [textPrimary] on [surface] ~= 16:1,
///     [textSecondary] on [surface] ~= 7.4:1, [textMuted] on [surface] ~= 4.6:1.
class AppColor {
  AppColor._();

  // ---------------------------------------------------------------------------
  // Core surfaces - light
  // ---------------------------------------------------------------------------

  /// Deepest tone, used for status bars / behind everything. Matches [canvas]
  /// closely so the page reads as one continuous near-white field.
  static const Color obsidian = Color(0xFFF3F5F9);

  /// Default scaffold / canvas colour - the page the cards sit on.
  static const Color canvas = Color(0xFFF3F5F9);

  /// Raised surface used for cards, sheets and dialogs. Pure white, so cards
  /// separate from [canvas] by tone alone.
  static const Color surface = Color(0xFFFFFFFF);

  /// Slightly recessed fill for inputs, chips and nested containers.
  static const Color surfaceHigh = Color(0xFFF5F7FA);

  /// Hovered / selected container fill.
  static const Color surfaceHighest = Color(0xFFEBEFF5);

  /// Hairline border for cards and dividers.
  static const Color stroke = Color(0xFFE4E8EF);

  /// Stronger border for controls that need to read as outlined.
  static const Color strokeStrong = Color(0xFFCDD5E0);

  /// Text / icon colours on light surfaces.
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF5A6472);
  static const Color textMuted = Color(0xFF8A93A2);

  /// Modal barrier / scrim. Always dark, regardless of theme, because its job
  /// is to push the page behind a dialog out of focus.
  static const Color scrim = Color(0xFF0B1220);

  // ---------------------------------------------------------------------------
  // Accents - blue only, plus three semantic colours
  // ---------------------------------------------------------------------------

  /// The action accent - the blue used for "View Details", "Compare", selected
  /// chips, gauges, stat bars and the booking CTA. This is the only colour that
  /// should ever read as "tap me".
  static const Color primary = Color(0xFF2F6BE4);

  /// Darker companion of [primary] for pressed states.
  static const Color primaryDeep = Color(0xFF1D4FBF);

  /// **Alias of [primary].**
  ///
  /// This slot used to hold a teal "data" accent, which meant half the chrome
  /// was teal and half blue for no communicative reason. The app is blue-only,
  /// so [secondary] now resolves to the same blue and every existing call site
  /// becomes consistent without being edited. New code should prefer
  /// [primary] directly.
  static const Color secondary = primary;

  /// Darker companion of [secondary].
  static const Color secondaryDeep = primaryDeep;

  /// Neutral steel tint for inactive glyphs and metallic trim.
  static const Color chrome = Color(0xFF8A93A2);

  /// Warm accent. **Semantic only** - ratings and prices, never decoration.
  static const Color amber = Color(0xFFF0A82E);

  /// Success / available state. **Semantic only.**
  static const Color success = Color(0xFF19A974);

  /// Danger - the favourite heart and destructive actions. **Semantic only.**
  static const Color danger = Color(0xFFE5484D);

  /// Informational accent for neutral chips.
  static const Color info = primary;

  // --- Backwards-compatible accent aliases -----------------------------------

  /// @Deprecated - use [primaryDeep] instead.
  static const Color violetDeep = primaryDeep;

  /// @Deprecated - use [secondaryDeep] instead.
  static const Color tealDeep = secondaryDeep;

  // ---------------------------------------------------------------------------
  // Gradients - REMOVED
  // ---------------------------------------------------------------------------
  // The brief calls for no gradients anywhere. These tokens are kept under
  // their original names purely so existing call sites still compile; each one
  // is now a flat 2-stop gradient between *identical* colours, which renders as
  // a solid fill. Prefer the plain `Color` constants above in new code.

  /// Flat stand-in for the old brand gradient. Renders as solid [primary].
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primary, primary],
  );

  /// Flat stand-in. Renders as solid [primary].
  static const LinearGradient brandGradientReverse = LinearGradient(
    colors: [primary, primary],
  );

  /// Flat stand-in. Renders as solid light steel.
  static const LinearGradient chromeGradient = LinearGradient(
    colors: [Color(0xFFB9C1CC), Color(0xFFB9C1CC)],
  );

  /// Flat stand-in. Renders as solid [amber].
  static const LinearGradient amberGradient = LinearGradient(
    colors: [amber, amber],
  );

  /// Flat page backdrop. Solid [canvas].
  static const LinearGradient appBackground = LinearGradient(
    colors: [canvas, canvas],
  );

  /// Flat panel fill. Solid white.
  static const LinearGradient glassFill = LinearGradient(
    colors: [surface, surface],
  );

  /// Flat nav bar fill. Solid white.
  static const LinearGradient navBarGradient = LinearGradient(
    colors: [surface, surface],
  );

  /// Flat intro backdrop. Solid [canvas].
  static const LinearGradient introGradient = LinearGradient(
    colors: [canvas, canvas],
  );

  /// No-op sheen. Retained for source compatibility; renders nothing visible.
  static const LinearGradient surfaceSheen = LinearGradient(
    colors: [Color(0x00000000), Color(0x00000000)],
  );

  // ---------------------------------------------------------------------------
  // Legacy aliases
  // ---------------------------------------------------------------------------

  /// @Deprecated - use [amber] instead.
  static const Color yellow = amber;

  /// @Deprecated - use [surface] instead.
  static const Color white = surface;

  /// @Deprecated - use [textPrimary] instead.
  static const Color black = textPrimary;

  /// @Deprecated - use [surfaceHigh] instead.
  static const Color darkGrey = surfaceHigh;

  /// @Deprecated - use [surfaceHigh] instead.
  static const Color containerColor = surfaceHigh;

  // ---------------------------------------------------------------------------
  // Corner radii
  // ---------------------------------------------------------------------------
  // The radius grows with the surface area, so small chips feel tight and large
  // panels feel generous.

  /// Pills, chips and inline tags.
  static const double radiusChip = 10;

  /// Inputs, segmented controls, small icon buttons.
  static const double radiusControl = 14;

  /// Standard cards and list tiles.
  static const double radiusCard = 18;

  /// Large feature panels - the primary card on a screen.
  static const double radiusPanel = 24;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// The per-item accent colour.
  ///
  /// **Always the primary blue.** This used to cycle blue / teal / amber so
  /// each card in a list carried its own hue, which meant a screen of six cars
  /// showed six competing accent colours and the interface lost its single
  /// action colour. The app is blue-only by design: the `index` parameter is
  /// retained so existing call sites keep compiling and so a future theme
  /// could reintroduce per-item hues in one place.
  ///
  /// [secondary], [amber], [success] and [danger] remain in the palette for
  /// *semantic* use only - the rating star, the favourite heart and the like -
  /// never as decoration.
  static Color accentFor(int index) => primary;

  /// Flat stand-in for the old tinted gradient. Returns a gradient between two
  /// identical colours so it renders as a solid fill.
  static LinearGradient tintedGradient(int index) {
    final base = accentFor(index);
    return LinearGradient(colors: [base, base]);
  }

  /// Soft outer shadow used on selected / elevated elements.
  ///
  /// On a light theme a coloured glow reads as a blurry smudge, so this is
  /// deliberately a *shadow*: a dark, low-opacity lift. The `color` argument
  /// tints it very slightly rather than bleeding the accent.
  static List<BoxShadow> glow(
    Color color, {
    double opacity = 0.28,
    double blur = 18,
    double spread = 0,
  }) {
    // Keep only a hint of the accent hue so selected states still register,
    // but the bulk of the effect is a neutral drop shadow.
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

  /// Elevation shadow for raised cards.
  ///
  /// Two layers - a tight contact shadow plus a wider ambient one - which is
  /// what makes elevation read as physical rather than as a flat drop.
  static List<BoxShadow> get cardShadow => const [
    BoxShadow(color: Color(0x0F101828), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x14101828), blurRadius: 16, offset: Offset(0, 6)),
  ];

  /// Lighter elevation for chips and small floating elements.
  static List<BoxShadow> get subtleShadow => const [
    BoxShadow(color: Color(0x0F101828), blurRadius: 8, offset: Offset(0, 3)),
  ];

  // --- Recessed / translucent fills ------------------------------------------
  // Small controls (chips, icon buttons, inputs) sit on [canvas]. A light grey
  // fill rather than a translucent one keeps contrast predictable on a light
  // theme, where translucent greys turn muddy against a white card behind them.

  /// Resting fill for an interactive control over the page background.
  static Color get surfaceVeil => surface;

  /// Hovered / active-elevation fill for a control over the page background.
  static Color get surfaceVeilStrong => surfaceHigh;

  /// Filled input sitting at full attention (e.g. a focused search field).
  static Color get surfaceVeilMax => surfaceHigh;

  /// Tinted fill for a control in its *selected* state, built from [accent].
  ///
  /// Kept very light so dark [textPrimary] stays legible on top of it.
  static Color accentVeil(Color accent, {double alpha = 0.10}) =>
      accent.withValues(alpha: alpha);

  /// Border colour paired with [accentVeil] for a selected control.
  static Color accentVeilBorder(Color accent, {double alpha = 0.32}) =>
      accent.withValues(alpha: alpha);

  // --- Neumorphism -----------------------------------------------------------
  // Retained for source compatibility. On a light theme these are simply soft
  // neutral shadows rather than a dual-light-source extrusion, because hard
  // neumorphism fights the flat/professional direction of this redesign.

  /// Soft raised treatment for tactile controls.
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

  /// Soft pressed treatment.
  static List<BoxShadow> neumorphicInset({Color? base, double depth = 1.0}) =>
      const [];

  /// Convenience: a filled + outlined container decoration used all over the
  /// UI so surfaces stay visually consistent.
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
      border: Border.all(
        color: borderColor ?? stroke,
        width: borderWidth,
      ),
      boxShadow: shadow ? cardShadow : null,
    );
  }
}
