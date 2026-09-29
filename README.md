# Rent Car

A Ferrari rental app built with Flutter. Browse a 20-car fleet, filter and sort
it, save favourites, compare cars side by side, and complete a real booking
flow with date selection and confirmation codes.

The entire visual layer is drawn with `CustomPainter` — no third-party UI
packages, no image-based decoration.

## Screens

| Screen | What it does |
| --- | --- |
| `intro_screen.dart` | Animated splash: counter-rotating dashed rings, staged entrance, pulsing CTA |
| `home_screen.dart` | Hero spotlight, quick stats, live search, category chips, sort sheet, list/grid toggle, floating compare bar |
| `car_details_screen.dart` | Gallery, instrument-cluster speedometer, spec bars, spec grid, **date chip in the header**, sticky booking bar, booking sheet, success dialog |
| `compare_screen.dart` | Sticky header, colour-coded car columns, three metric charts, winner-per-cell spec matrix, computed verdict |
| `saved_screen.dart` | Favourites with swipe-to-remove, plus a recently-viewed rail |
| `bookings_screen.dart` | Active/History segments over real bookings, date-overlap filter, cancel |
| `profile_screen.dart` | Live stats, garage-level progress ring, and five working account screens |
| `settings_screen.dart` | Grouped panels, persistent toggles, radius slider, usage ring, real system actions |
| `account_screens.dart` | Personal info form, payment methods, rental history, driving licence, help & support |

## Architecture

```
lib/
  main.dart                  RentCarApp (theme + AppStateScope) + MainWrapper (tab container)
  core/
    app_color.dart           Design tokens: light surfaces, solid accents, radii,
                             elevation + panel decoration factory. NO gradients.
    app_state.dart           AppState (ChangeNotifier): favourites, compare, bookings, recents,
                             settings preferences, UserProfile, PaymentMethod
  model/
    car_model.dart           CarModel + CarCategory, plus parsed spec getters
    tab_items.dart           Nav bar item model
  car_data/
    car_data.dart            The 20-car fleet
    navigation_bar_data.dart Five nav tabs
    custom_date_picker_dialoge.dart   Themed range picker wrapper
  widgets/
    car_card.dart            List + grid car cards, with the labelled CompareActionButton
    car_card_painter.dart    White panel frame, car silhouette, hairline divider
    chips.dart               Category filter chips (solid blue when selected)
    entrance_fade.dart       One-shot fade + lift used to stagger list items
    circular_bottom_navigation.dart   Nav bar with raised glowing handle
    header.dart              Greeting header with alert badge
    search_bar.dart          Glass search input
    painters/                The CustomPainter library (see below)
  screens/                   One file per screen
```

### No state management package

`AppState` is a plain `ChangeNotifier` exposed through an `InheritedNotifier`
(`AppStateScope`). Screens read it with `AppState.of(context)`. Cross-tab
navigation goes through `MainWrapper.goToTab()` with named index constants —
never hardcode tab numbers.

### The painter library (`lib/widgets/painters/`)

| Painter | Used for |
| --- | --- |
| `AuroraBackground` | Flat solid page colour. Base layer of every screen |
| `GlassCardPainter` / `GlassCard` | Opaque white panel, hairline border, two-layer shadow |
| `SpeedometerPainter` / `Speedometer` | 240° instrument cluster. **All text is canvas-painted** into reserved bands so it can never overlap |
| `ProgressRing` / `StatBar` | Animated solid-colour rings and fill bars |
| `HeroBannerPainter` | Flat tinted home hero panel |
| `DashedRingPainter` | Rotating dashed circles on the splash |
| `ComparisonChartPainter` / `ComparisonChart` | Grouped bar chart with grow-in and winner highlight |

## Design tokens

Defined in `lib/core/app_color.dart`.

The app is **light theme only**. Three rules hold the whole thing together:

1. **No gradients.** Every fill is a solid colour. The legacy gradient tokens
   (`brandGradient`, `appBackground`, …) still exist so old call sites compile,
   but each one resolves to a *flat* colour with both stops identical. A test
   asserts this so a gradient cannot creep back in.
2. **Elevation is shadow + border**, never a colour transition.
3. **Blue only.** `secondary` is an alias of `primary`, so every structural
   accent in the app is one blue. Only three colours are not blue, and each one
   carries meaning rather than decoration: `amber` for ratings and prices,
   `danger` for the favourite heart and destructive actions, `success` for
   availability. A test asserts they stay distinct from the accent.

| Token | Hex | Role |
| --- | --- | --- |
| `canvas` | `#F3F5F9` | The page every card sits on |
| `surface` | `#FFFFFF` | Raised cards, sheets, dialogs |
| `surfaceHigh` | `#F5F7FA` | Recessed fills: inputs, chips, nested boxes |
| `stroke` / `strokeStrong` | `#E4E8EF` / `#CDD5E0` | Hairline / outlined borders |
| `textPrimary` / `textSecondary` / `textMuted` | `#111827` / `#5A6472` / `#8A93A2` | Text ramp (16:1 / 7.4:1 / 4.6:1 on white) |
| `primary` | `#2F6BE4` | Blue — **the** accent (Compare, Book Now, gauges, bars) |
| `secondary` | `= primary` | Alias of `primary`. The app is blue only |
| `amber` | `#F0A82E` | Ratings and prices — **semantic only** |
| `danger` | `#E5484D` | Favourites, destructive actions — semantic only |
| `success` | `#19A974` | Active bookings, "BEST" cells — semantic only |
| `scrim` | `#0B1220` | Modal barrier. Always dark, whatever the theme |

### Radii

`radiusChip 10` · `radiusControl 14` · `radiusCard 18` · `radiusPanel 24`.
The radius grows with surface area, so small chips stay tight and large panels
stay generous. Use the tokens, not literals.

### Car images

Every car photograph renders inside a **fixed `SizedBox`** —
`CarCard.imageBoxWidth × CarCard.imageBoxHeight` (240 × 104) — with
`BoxFit.contain`. That is what guarantees all cars look the same size no matter
what the source PNG's own dimensions are, with no stretching or cropping. A test
measures the box across six different cars and asserts they are pixel-identical.

See `lib/widgets/entrance_fade.dart` for the staggered list entrance, used to
ease cards in without the screen feeling busy.

## Running

```bash
flutter pub get
flutter run
```

### Testing

```bash
HTTP_PROXY= HTTPS_PROXY= http_proxy= https_proxy= flutter test
```

The proxy prefix is required: if a proxy is configured for `localhost`, the
Flutter test harness cannot open its WebSocket to `flutter_tester` and every
test fails with `Unable to connect to flutter_tester process`. The same applies
to `flutter build`.

## Note on assets

Every image path is verified against `assets/images/`. Cards fall back to
`CarSilhouettePainter` if an asset is missing, so the UI degrades gracefully
rather than throwing.
