import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_test/flutter_test.dart';
import 'package:rent_car/car_data/car_data.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/core/app_state.dart';
import 'package:rent_car/main.dart';
import 'package:rent_car/model/car_model.dart';
import 'package:rent_car/screens/car_details_screen.dart';
import 'package:rent_car/screens/bookings_screen.dart';
import 'package:rent_car/screens/compare_screen.dart';
import 'package:rent_car/screens/home_screen.dart';
import 'package:rent_car/screens/intro_screen.dart';
import 'package:rent_car/screens/profile_screen.dart';
import 'package:rent_car/screens/settings_screen.dart';
import 'package:rent_car/widgets/car_card.dart';
import 'package:rent_car/widgets/circular_bottom_navigation.dart';
import 'package:rent_car/widgets/entrance_fade.dart';
import 'package:rent_car/widgets/header.dart';
import 'package:rent_car/widgets/painters/progress_ring.dart';
import 'package:rent_car/widgets/painters/speedometer.dart';
import 'package:rent_car/widgets/painters/speedometer_widget.dart';

void main() {
  group('App boots', () {
    testWidgets('shows the intro screen first', (tester) async {
      await tester.pumpWidget(const RentCarApp());
      await tester.pump();

      expect(find.byType(IntroScreen), findsOneWidget);
      expect(find.text('Explore the Fleet'), findsOneWidget);
    });
  });

  group('Light theme card image consistency', () {
    /// Renders a card inside the state scope it reads from.
    Widget harness(CarModel car) => AppStateScope(
      notifier: AppState(),
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: AppColor.canvas,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: CarCard(car: car, onTap: () {}),
          ),
        ),
      ),
    );

    testWidgets('every car image uses an identical container size', (
      tester,
    ) async {
      // The brief requires all car images to share the same visual size
      // regardless of the source PNG's own dimensions or aspect ratio. The
      // guarantee is a fixed SizedBox, so we assert its measured size is the
      // same for a sample of very differently shaped assets.
      final sizes = <Size>[];

      for (final car in carList.take(6)) {
        await tester.pumpWidget(harness(car));
        await tester.pump(const Duration(milliseconds: 200));

        final box = find.byWidgetPredicate(
          (w) =>
              w is SizedBox &&
              w.width == CarCard.imageBoxWidth &&
              w.height == CarCard.imageBoxHeight,
        );
        expect(
          box,
          findsOneWidget,
          reason: '${car.model} must have exactly one fixed image box',
        );
        sizes.add(tester.getSize(box));
      }

      // All six measured boxes must be pixel-identical.
      for (final size in sizes) {
        expect(size, sizes.first);
      }
      expect(sizes.first.width, CarCard.imageBoxWidth);
      expect(sizes.first.height, CarCard.imageBoxHeight);
    });

    testWidgets('car images are contained, never stretched', (tester) async {
      await tester.pumpWidget(harness(carList.first));
      await tester.pump(const Duration(milliseconds: 200));

      final image = tester.widget<Image>(find.byType(Image).first);
      expect(
        image.fit,
        BoxFit.contain,
        reason: 'BoxFit.contain preserves aspect ratio; cover would crop',
      );
    });

    testWidgets('the card paints no gradient', (tester) async {
      await tester.pumpWidget(harness(carList.first));
      await tester.pump(const Duration(milliseconds: 200));

      // Walk every decoration in the card subtree and assert none of them
      // carries a gradient - the brief forbids them outright.
      for (final element in find
          .descendant(of: find.byType(CarCard), matching: find.byType(Container))
          .evaluate()) {
        final container = element.widget as Container;
        final decoration = container.decoration;
        if (decoration is BoxDecoration) {
          expect(
            decoration.gradient,
            isNull,
            reason: 'Car card containers must not use gradients',
          );
        }
      }
    });
  });

  group('Redesigned car card', () {
    /// Renders one card inside the state scope it reads from.
    Widget harness({required CarModel car, AppState? state}) => AppStateScope(
      notifier: state ?? AppState(),
      child: MaterialApp(
        home: Scaffold(
          backgroundColor: AppColor.canvas,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: CarCard(car: car, onTap: () {}),
          ),
        ),
      ),
    );

    testWidgets('renders without a speed pill and shows a Compare button', (
      tester,
    ) async {
      await tester.pumpWidget(harness(car: carList.first));
      await tester.pump(const Duration(milliseconds: 300));

      // The old card had a floating maxSpeed pill that collided with the price.
      expect(
        find.text(carList.first.maxSpeed),
        findsNothing,
        reason: 'The speed pill must not reappear on the card',
      );

      // Compare is now a labelled primary action.
      expect(find.text('Compare'), findsOneWidget);
      expect(find.byIcon(Icons.compare_arrows_rounded), findsOneWidget);

      // Price still renders.
      expect(
        find.textContaining('\$${carList.first.price.toStringAsFixed(0)}'),
        findsOneWidget,
      );
    });

    testWidgets('Compare button reflects and toggles the selection state', (
      tester,
    ) async {
      final state = AppState();
      await tester.pumpWidget(harness(car: carList.first, state: state));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Compare'), findsOneWidget);
      expect(state.isComparing(carList.first), isFalse);

      await tester.tap(find.text('Compare'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(state.isComparing(carList.first), isTrue);
      expect(find.text('Added'), findsOneWidget);
    });

    testWidgets('card lays out on a narrow screen without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(harness(car: carList.first));
      await tester.pump(const Duration(milliseconds: 300));

      // Any RenderFlex overflow - vertical or horizontal - surfaces here.
      expect(tester.takeException(), isNull);

      // Below 360px the Compare button drops its label but keeps its icon,
      // so the primary action is still present and still tappable.
      expect(find.byIcon(Icons.compare_arrows_rounded), findsOneWidget);
    });

    testWidgets('card lays out at a large text scale without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        AppStateScope(
          notifier: AppState(),
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
              child: Scaffold(
                backgroundColor: AppColor.canvas,
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CarCard(car: carList.first, onTap: () {}),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
    });
  });

  group('Light theme tokens', () {
    test('no token exposes a multi-colour gradient', () {
      // The brief forbids gradients outright. The legacy gradient tokens still
      // exist so old call sites compile, but every one of them must resolve to
      // a single flat colour (i.e. both stops identical).
      final gradients = <String, LinearGradient>{
        'brandGradient': AppColor.brandGradient,
        'brandGradientReverse': AppColor.brandGradientReverse,
        'chromeGradient': AppColor.chromeGradient,
        'amberGradient': AppColor.amberGradient,
        'appBackground': AppColor.appBackground,
        'glassFill': AppColor.glassFill,
        'navBarGradient': AppColor.navBarGradient,
        'introGradient': AppColor.introGradient,
        'surfaceSheen': AppColor.surfaceSheen,
      };

      gradients.forEach((name, gradient) {
        final distinct = gradient.colors.toSet();
        expect(
          distinct.length,
          1,
          reason: '$name must be a flat fill, found ${gradient.colors}',
        );
      });
    });

    test('the palette is light, not dark', () {
      // Surfaces must be light and text must be dark, which is the inverse of
      // the previous theme and the whole point of this redesign.
      double lum(Color c) => c.computeLuminance();

      expect(lum(AppColor.canvas), greaterThan(0.85));
      expect(lum(AppColor.surface), greaterThan(0.9));
      expect(lum(AppColor.textPrimary), lessThan(0.05));
      expect(lum(AppColor.textSecondary), lessThan(0.20));

      // And the contrast between body text and a card must clear WCAG AA.
      final ratio =
          (lum(AppColor.surface) + 0.05) / (lum(AppColor.textPrimary) + 0.05);
      expect(ratio, greaterThan(4.5));
    });

    test('the scrim is always dark, whatever the theme', () {
      expect(AppColor.scrim.computeLuminance(), lessThan(0.05));
    });

    test('the structural palette is blue only', () {
      // Both accent slots must resolve to the same blue, so a screen never
      // shows two competing accent colours. This is the invariant that the
      // `secondary` alias exists to hold.
      expect(AppColor.secondary, AppColor.primary);
      expect(AppColor.secondaryDeep, AppColor.primaryDeep);
      expect(AppColor.info, AppColor.primary);

      // accentFor used to cycle blue / teal / amber. It must not any more.
      final accents = <Color>{
        for (var i = 0; i < 8; i++) AppColor.accentFor(i),
      };
      expect(
        accents,
        {AppColor.primary},
        reason: 'every per-item accent must be the primary blue',
      );

      // And the gradient stand-in derived from it must stay flat and blue.
      for (var i = 0; i < 4; i++) {
        final g = AppColor.tintedGradient(i);
        expect(g.colors.every((c) => c == AppColor.primary), isTrue);
      }
    });

    test('semantic colours stay distinct from the accent blue', () {
      // Amber, success and danger are for meaning, not decoration - they must
      // remain visibly different from the blue so a rating star or a favourite
      // heart still reads at a glance.
      for (final c in [AppColor.amber, AppColor.success, AppColor.danger]) {
        expect(
          c,
          isNot(AppColor.primary),
          reason: 'a semantic colour collapsed into the accent blue',
        );
      }
    });
  });

  group('Redesigned compare screen', () {
    testWidgets('lists price, engine, speed, mileage and fuel rows', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = AppState()
        ..toggleCompare(carList[0])
        ..toggleCompare(carList[1]);

      await tester.pumpWidget(
        AppStateScope(
          notifier: state,
          child: const MaterialApp(home: CompareScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      // The spec matrix sits below the charts, so scroll it into view first.
      await tester.scrollUntilVisible(
        find.text('Mileage'),
        320,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump(const Duration(milliseconds: 200));

      // The brief calls these out by name, so assert each is present.
      expect(find.text('Price / day'), findsOneWidget);
      expect(find.text('Engine'), findsOneWidget);
      expect(find.text('Top speed'), findsOneWidget);
      expect(find.text('Mileage'), findsOneWidget);
      expect(find.text('Fuel type'), findsOneWidget);

      // Both cars' mileage values are visible in the matrix.
      expect(find.text(carList[0].mileage), findsOneWidget);
      expect(find.text(carList[1].mileage), findsOneWidget);
    });

    testWidgets('shows the empty state below two cars', (tester) async {
      final state = AppState()..toggleCompare(carList[0]);

      await tester.pumpWidget(
        AppStateScope(
          notifier: state,
          child: const MaterialApp(home: CompareScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Pick at least two cars'), findsOneWidget);
    });
  });

  group('Redesigned speedometer', () {
    testWidgets('renders all text through the painter, not as widgets', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Speedometer(
                value: 340,
                maxValue: 400,
                size: 240,
                label: 'TOP SPEED',
                unit: 'KM/H',
              ),
            ),
          ),
        ),
      );
      // Let the sweep animation run partway.
      await tester.pump(const Duration(milliseconds: 600));

      // The value, unit and caption are painted onto the canvas, so there must
      // be no Text widgets for them - that is what guarantees no overlap.
      expect(find.text('TOP SPEED'), findsNothing);
      expect(find.text('KM/H'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow at a small size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Speedometer(value: 210, maxValue: 400, size: 140),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
    });
  });

  group('Settings screen is functional', () {
    Widget harness({AppState? state}) => AppStateScope(
      notifier: state ?? AppState(),
      child: const MaterialApp(home: SettingScreen()),
    );

    testWidgets('toggling push notifications writes back to AppState', (
      tester,
    ) async {
      final state = AppState();
      await tester.pumpWidget(harness(state: state));
      await tester.pump(const Duration(milliseconds: 300));

      expect(state.pushNotifications, isTrue);

      // The row shows the live value from AppState.
      final toggle = find.byType(Switch).first;
      await tester.tap(toggle);
      await tester.pump(const Duration(milliseconds: 300));

      expect(state.pushNotifications, isFalse);
    });

    testWidgets('settings survive a rebuild because they live in AppState', (
      tester,
    ) async {
      final state = AppState();
      state.setLanguage('Urdu');

      await tester.pumpWidget(harness(state: state));
      await tester.pump(const Duration(milliseconds: 300));

      // Rebuild from scratch with the same state object.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(harness(state: state));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Urdu'), findsWidgets);
    });

    testWidgets('every system row has a real tap handler', (tester) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(harness());
      await tester.pump(const Duration(milliseconds: 300));

      // "Server status" used to be an empty callback; scroll it into view and
      // check it now opens a real dialog.
      await tester.scrollUntilVisible(
        find.text('Server status'),
        260,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text('Server status'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('All services operational'), findsOneWidget);
    });
  });

  group('Profile screen is functional', () {
    Widget harness({AppState? state}) => AppStateScope(
      notifier: state ?? AppState(),
      child: const MaterialApp(home: ProfileScreen()),
    );

    testWidgets('renders real subtitles instead of coming-soon stubs', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final state = AppState();
      await tester.pumpWidget(harness(state: state));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Yasir'), findsOneWidget);
      expect(find.text('Payment methods'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Help & support'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump(const Duration(milliseconds: 200));

      // The payment subtitle is generated from real state, not a placeholder.
      expect(find.textContaining('····'), findsWidgets);
    });

    testWidgets('tapping Personal information opens an editable form', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(harness());
      await tester.pump(const Duration(milliseconds: 400));

      await tester.scrollUntilVisible(
        find.text('Personal information'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text('Personal information'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // The real form replaced the old "coming soon" snackbar. Field labels are
      // rendered uppercased by AccountField.
      expect(find.text('FULL NAME'), findsOneWidget);
      expect(find.text('EMAIL ADDRESS'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
    });
  });

  group('Details screen date range', () {
    Widget detailsHarness() => AppStateScope(
      notifier: AppState(),
      child: MaterialApp(home: CarDetailsScreen(car: carList.first)),
    );

    testWidgets('header is icon-only - no "Add dates" text', (tester) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(detailsHarness());
      await tester.pump(const Duration(milliseconds: 400));

      // The labelled chip was replaced by a bare calendar icon button.
      expect(find.text('Add dates'), findsNothing);
      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    });

    testWidgets('calendar sits beside the favourite button at the right edge', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(detailsHarness());
      await tester.pump(const Duration(milliseconds: 400));

      final calendar = tester.getCenter(
        find.byIcon(Icons.calendar_month_rounded),
      );
      final favourite = tester.getCenter(
        find.byIcon(Icons.favorite_border_rounded),
      );
      final back = tester.getCenter(find.byIcon(Icons.arrow_back_rounded));

      // Calendar and favourite are adjacent, and both sit to the right of the
      // back arrow - the calendar is no longer a wide chip in the middle.
      expect(calendar.dy, closeTo(favourite.dy, 1.0));
      expect(calendar.dx, lessThan(favourite.dx));
      expect(
        favourite.dx - calendar.dx,
        lessThan(60),
        reason: 'the two icon buttons should be next to each other',
      );
      expect(calendar.dx, greaterThan(back.dx + 100));
    });

    testWidgets('tapping the calendar icon opens the range picker', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(detailsHarness());
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.byIcon(Icons.calendar_month_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // The custom shell's title proves the picker opened.
      expect(find.text('RENTAL PERIOD'), findsOneWidget);
    });

    testWidgets('performance dashboard uses the blue accent only', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(detailsHarness());
      await tester.pump(const Duration(milliseconds: 400));

      // Every ring and bar in the performance block must carry the primary
      // blue - no teal, amber, green or red accents.
      final rings = tester
          .widgetList<ProgressRing>(find.byType(ProgressRing))
          .toList();
      expect(rings, isNotEmpty);
      for (final ring in rings) {
        expect(
          ring.gradientColors,
          isNotNull,
          reason: 'every ring should declare its accent',
        );
        expect(
          ring.gradientColors!.every((c) => c == AppColor.primary),
          isTrue,
          reason: 'a non-blue accent leaked into the rings',
        );
      }

      final bars = tester
          .widgetList<StatBar>(find.byType(StatBar))
          .toList();
      expect(bars, isNotEmpty);
      for (final bar in bars) {
        expect(
          bar.accent,
          AppColor.primary,
          reason: 'a non-blue accent leaked into the stat bars',
        );
      }
    });
  });

  group('Header avatar and bookings surfaces', () {
    testWidgets('header avatar always renders the profile initials', (
      tester,
    ) async {
      await tester.pumpWidget(
        AppStateScope(
          notifier: AppState(),
          child: MaterialApp(
            home: Scaffold(
              backgroundColor: AppColor.canvas,
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Header(),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // The monogram is the avatar's underlay, so it is present regardless of
      // whether the photo asset decoded - a missing avatar can never leave a
      // blank circle.
      expect(find.text('YA'), findsOneWidget);
      expect(find.byType(ClipOval), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('bookings filter chip is opaque and does not overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        AppStateScope(
          notifier: AppState(),
          child: const MaterialApp(home: BookingsScreen()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Active & Upcoming'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('MainWrapper navigation', () {
    /// Wraps MainWrapper in the state scope it depends on, plus a MaterialApp.
    Widget harness() => AppStateScope(
      notifier: AppState(),
      child: const MaterialApp(home: MainWrapper()),
    );

    testWidgets('renders the home tab and one navigation bar', (tester) async {
      await tester.pumpWidget(harness());
      // The aurora backdrop animates forever, so settle by pumping a fixed
      // number of frames rather than using pumpAndSettle.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(CircularBottomNavigation), findsOneWidget);

      // Only the selected tab's label is rendered (others fade in on select).
      expect(find.text('Home'), findsWidgets);
      // The nav bar exposes one icon per destination.
      expect(find.byIcon(Icons.home_rounded), findsWidgets);
      expect(find.byIcon(Icons.calendar_month_rounded), findsWidgets);
      expect(find.byIcon(Icons.settings_rounded), findsWidgets);
    });

    testWidgets('switches tabs when the nav bar is tapped', (tester) async {
      await tester.pumpWidget(harness());
      await tester.pump(const Duration(milliseconds: 400));

      final navFinder = find.byType(CircularBottomNavigation);
      final navRect = tester.getRect(navFinder);

      // Tap the last section of the bar (Settings).
      await tester.tapAt(
        Offset(navRect.right - navRect.width / 10, navRect.bottom - 18),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Settings tab content should now be visible.
      expect(find.text('CONTROL PANEL'), findsOneWidget);
    });
  });

  group('Car data integrity', () {
    test('every car parses its numeric specs', () {
      expect(carList, isNotEmpty);
      for (final car in carList) {
        expect(
          car.topSpeedKmh,
          greaterThan(0),
          reason: '${car.model} should have a parsable maxSpeed',
        );
        expect(
          car.seatCount,
          greaterThan(0),
          reason: '${car.model} should have a parsable seat count',
        );
      }
    });

    test('car ids are unique', () {
      final ids = carList.map((c) => c.id).toSet();
      expect(ids.length, carList.length);
    });

    test('image paths point inside the assets folder', () {
      for (final car in carList) {
        expect(car.image, startsWith('assets/images/'));
        for (final extra in car.gallery) {
          expect(extra, startsWith('assets/images/'));
        }
      }
    });
  });

  group('AppState', () {
    test('toggling a favourite adds then removes it', () {
      final state = AppState();
      final car = carList.first;

      expect(state.isFavourite(car), isFalse);
      state.toggleFavourite(car);
      expect(state.isFavourite(car), isTrue);
      expect(state.favouriteCount, 1);

      state.toggleFavourite(car);
      expect(state.isFavourite(car), isFalse);
      expect(state.favouriteCount, 0);
    });

    test('adding a booking records days, total and status', () {
      final state = AppState();
      final car = carList.first;
      final start = DateTime.now().add(const Duration(days: 2));
      final end = start.add(const Duration(days: 2)); // inclusive -> 3 days

      final booking = state.addBooking(car: car, start: start, end: end);

      expect(booking.days, 3);
      expect(booking.total, car.price * 3);
      expect(booking.status, BookingStatus.upcoming);
      expect(booking.confirmationCode, startsWith('RC-'));
      expect(state.totalRides, 1);
      expect(state.totalSpend, car.price * 3);
    });

    test('recently viewed is capped and most recent comes first', () {
      final state = AppState();
      for (final car in carList.take(8)) {
        state.markViewed(car);
      }

      final recent = state.recentlyViewedFrom(carList);
      expect(recent.length, 6);
      expect(recent.first, carList[7]);
    });

    test('cancelling removes the booking', () {
      final state = AppState();
      final booking = state.addBooking(
        car: carList.first,
        start: DateTime.now(),
        end: DateTime.now(),
      );
      expect(state.totalRides, 1);

      state.cancelBooking(booking);
      expect(state.totalRides, 0);
    });

    test('comparison caps at maxCompare and reports rejection', () {
      final state = AppState();

      // Add exactly the maximum number of cars.
      for (var i = 0; i < AppState.maxCompare; i++) {
        expect(state.toggleCompare(carList[i]), isTrue);
      }
      expect(state.compareCount, AppState.maxCompare);
      expect(state.canCompareMore, isFalse);

      // One more should be refused rather than silently dropped.
      expect(state.toggleCompare(carList[AppState.maxCompare]), isFalse);
      expect(state.compareCount, AppState.maxCompare);

      // Removing one reopens a slot.
      expect(state.toggleCompare(carList.first), isTrue);
      expect(state.compareCount, AppState.maxCompare - 1);
      expect(state.canCompareMore, isTrue);
    });

    test('clearCompare empties the set', () {
      final state = AppState();
      state.toggleCompare(carList[0]);
      state.toggleCompare(carList[1]);
      expect(state.compareCount, 2);

      state.clearCompare();
      expect(state.compareCount, 0);
      expect(state.compareCarsFrom(carList), isEmpty);
    });

    test('compareCarsFrom preserves selection order', () {
      final state = AppState();
      state.toggleCompare(carList[3]);
      state.toggleCompare(carList[1]);

      final selected = state.compareCarsFrom(carList);
      expect(selected.length, 2);
      expect(selected.first, carList[3]);
      expect(selected.last, carList[1]);
    });
  });

  group('AppState settings', () {
    test('preferences start at their documented defaults', () {
      final state = AppState();
      expect(state.pushNotifications, isTrue);
      expect(state.promoEmails, isFalse);
      expect(state.biometricLogin, isFalse);
      expect(state.locationAccess, isTrue);
      expect(state.language, 'English');
      expect(state.searchRadius, 35);
    });

    test('setters change the value and notify listeners', () {
      final state = AppState();
      var notifications = 0;
      state.addListener(() => notifications++);

      state.setPushNotifications(false);
      state.setLanguage('Urdu');
      state.setSearchRadius(80);

      expect(state.pushNotifications, isFalse);
      expect(state.language, 'Urdu');
      expect(state.searchRadius, 80);
      expect(notifications, 3);
    });

    test('setting the same value is a no-op', () {
      final state = AppState();
      var notifications = 0;
      state.addListener(() => notifications++);

      state.setPushNotifications(true); // already true
      state.setLanguage('English'); // already English

      expect(notifications, 0);
    });

    test('resetPreferences restores every default', () {
      final state = AppState();
      state.setPushNotifications(false);
      state.setPromoEmails(true);
      state.setBiometricLogin(true);
      state.setLocationAccess(false);
      state.setLanguage('Arabic');
      state.setSearchRadius(150);

      state.resetPreferences();

      expect(state.pushNotifications, isTrue);
      expect(state.promoEmails, isFalse);
      expect(state.biometricLogin, isFalse);
      expect(state.locationAccess, isTrue);
      expect(state.language, 'English');
      expect(state.searchRadius, 35);
    });

    test('clearRecentlyViewed empties the recently viewed list', () {
      final state = AppState();
      state.markViewed(carList[0]);
      state.markViewed(carList[1]);
      expect(state.recentlyViewedIds, isNotEmpty);

      state.clearRecentlyViewed();
      expect(state.recentlyViewedIds, isEmpty);
    });
  });

  group('AppState profile', () {
    test('updateProfile writes back the edited fields', () {
      final state = AppState();

      state.updateProfile(
        name: '  Nadia Khan  ',
        email: 'nadia@example.com',
        city: 'Lahore',
      );

      // Whitespace is trimmed, and untouched fields keep their values.
      expect(state.profile.name, 'Nadia Khan');
      expect(state.profile.email, 'nadia@example.com');
      expect(state.profile.city, 'Lahore');
      expect(state.profile.phone, isNotEmpty);
    });

    test('updateProfile ignores blank input', () {
      final state = AppState();
      final original = state.profile.name;

      state.updateProfile(name: '   ');

      expect(state.profile.name, original);
    });

    test('UserProfile initials handle one and two word names', () {
      expect(UserProfile(name: 'Yasir Ahmed').initials, 'YA');
      expect(UserProfile(name: 'Yasir').initials, 'Y');
    });

    test('payment methods can be added, defaulted and removed', () {
      final state = AppState();
      final starting = state.paymentMethods.length;
      expect(state.defaultPaymentMethod, isNotNull);

      state.addPaymentMethod(
        PaymentMethod(
          id: 'pm_test',
          brand: 'Visa',
          last4: '1111',
          expiry: '01/30',
          isDefault: true,
        ),
      );
      expect(state.paymentMethods.length, starting + 1);
      expect(state.defaultPaymentMethod!.id, 'pm_test');

      // Exactly one default may exist at a time.
      expect(
        state.paymentMethods.where((m) => m.isDefault).length,
        1,
      );

      state.removePaymentMethod('pm_test');
      expect(state.paymentMethods.length, starting);
      expect(state.defaultPaymentMethod, isNotNull);
    });

    test('signOut clears favourites, bookings and comparison', () {
      final state = AppState();
      state.toggleFavourite(carList[0]);
      state.toggleCompare(carList[1]);
      state.addBooking(
        car: carList[0],
        start: DateTime(2026, 10, 1),
        end: DateTime(2026, 10, 3),
      );

      state.signOut();

      expect(state.favouriteCount, 0);
      expect(state.compareCount, 0);
      expect(state.bookings, isEmpty);
    });
  });

  group('CarModel mileage', () {
    test('mileageKm parses comma and space separated values', () {
      expect(
        CarModel(
          company: 'Ferrari',
          model: 'Test',
          image: 'assets/images/testarossa.png',
          rating: 4.5,
          price: 100,
          maxSpeed: '300Km/h',
          engine: 'V8',
          ability: '2 Seats',
          airbag: '4',
          fuelType: 'Petrol',
          drivetrain: 'RWD',
          mileage: '12,400 km',
        ).mileageKm,
        12400,
      );
      expect(
        CarModel(
          company: 'Ferrari',
          model: 'Test',
          image: 'assets/images/testarossa.png',
          rating: 4.5,
          price: 100,
          maxSpeed: '300Km/h',
          engine: 'V8',
          ability: '2 Seats',
          airbag: '4',
          fuelType: 'Petrol',
          drivetrain: 'RWD',
          mileage: '940km',
        ).mileageKm,
        940,
      );
    });

    test('every car in the fleet has a parseable mileage', () {
      for (final car in carList) {
        expect(
          car.mileageKm,
          greaterThan(0),
          reason: '${car.model} has no parseable mileage',
        );
      }
    });
  });

  group('CarModel scoring', () {
    test('faster cars score higher on performance', () {
      final slow = CarModel(
        company: 'Test',
        model: 'Slow',
        image: 'assets/images/testarossa.png',
        rating: 4,
        price: 100,
        maxSpeed: '200Km/h',
        engine: 'V6',
        ability: '2 Seats',
        airbag: '2',
        fuelType: 'Petrol',
        drivetrain: 'RWD',
      );
      final fast = CarModel(
        company: 'Test',
        model: 'Fast',
        image: 'assets/images/testarossa.png',
        rating: 4,
        price: 100,
        maxSpeed: '350Km/h',
        engine: 'V12',
        ability: '2 Seats',
        airbag: '2',
        fuelType: 'Petrol',
        drivetrain: 'RWD',
      );

      expect(fast.performanceScore, greaterThan(slow.performanceScore));
      expect(slow.performanceScore, inInclusiveRange(0.0, 1.0));
    });
  });

  group('Speedometer readout placement and colour', () {
    /// The painter draws the readout itself, so the checks below interrogate
    /// the geometry it publishes rather than looking for text widgets.
    SpeedometerPainter painterAt(double value) => SpeedometerPainter(
      value: value,
      maxValue: 400,
      unit: 'KM/H',
      caption: 'TOP SPEED',
      decimals: 0,
    );

    test('readout sits below the dial centre and clear of the hub', () {
      const size = 234.0;
      final painter = painterAt(340);
      final recorder = ui.PictureRecorder();
      painter.paint(Canvas(recorder), const Size(size, size));
      recorder.endRecording();

      final radius = size / 2;
      final centreY = size / 2;
      final band = painter.readoutBand;
      final valueRect = painter.valueTextRect;

      expect(band, isNot(Rect.zero), reason: 'the readout must be measured');
      expect(valueRect, isNot(Rect.zero));

      // The whole readout block - value and unit - is below the vertical
      // centre. That is the change requested: it used to straddle the centre.
      expect(
        band.top,
        greaterThan(centreY),
        reason: 'the readout should be pulled down out of the dial centre',
      );

      // The big number's midpoint is what the eye reads as the gauge centre.
      // It must be clearly below the dial centre and clear of the hub, whose
      // lower edge sits at +0.155r.
      final valueCentre = valueRect.center.dy;
      expect(
        valueCentre - centreY,
        greaterThan(radius * 0.20),
        reason: 'the speed value should read as sitting low in the dial',
      );
      expect(
        valueRect.top,
        greaterThanOrEqualTo(centreY + radius * 0.155),
        reason: 'the value must not overlap the hub',
      );

      // And the whole block stays inside the dial's usable lower bowl rather
      // than spilling out of the face.
      expect(band.bottom, lessThan(centreY + radius * 0.90));
    });

    test('a longer value does not shift the readout vertically', () {
      const size = 234.0;
      final single = painterAt(40);
      final triple = painterAt(340);

      for (final p in [single, triple]) {
        final recorder = ui.PictureRecorder();
        p.paint(Canvas(recorder), const Size(size, size));
        recorder.endRecording();
      }

      // Both are anchored to the same point, so the top of the readout is
      // identical whether the reading is 2 or 3 characters wide.
      expect(single.readoutBand.top, closeTo(triple.readoutBand.top, 0.01));
      // Widths differ, which confirms the band really is measured per value.
      expect(triple.readoutBand.width, greaterThan(single.readoutBand.width));
    });

    test('the value arc ignores gradientColors and stays blue', () async {
      const size = 234.0;
      const pink = Color(0xFFFF00AA);

      // Identical painters except for the gradient list, so any difference in
      // shouldRepaint could only come from that field.
      final blue = painterAt(340);
      final hostile = SpeedometerPainter(
        value: 340,
        maxValue: 400,
        unit: 'KM/H',
        caption: 'TOP SPEED',
        decimals: 0,
        gradientColors: const [pink, Color(0xFF00FF00)],
      );

      expect(
        hostile.shouldRepaint(blue),
        isFalse,
        reason: 'gradientColors must not influence the painting',
      );

      // And the rendered pixels contain no pink - the blue theme never
      // produces a strong red/blue spread with low green, so any such pixel is
      // a leak from the ignored gradient list.
      final canvas = await _renderPainter(hostile, size);
      var pinkPixels = 0;
      for (var y = 0; y < canvas.side; y++) {
        for (var x = 0; x < canvas.side; x++) {
          final (r, g, b, a) = canvas.at(x, y);
          if (a < 13) continue;
          if (r > 200 && g < 120 && b > 120) pinkPixels++;
        }
      }
      expect(pinkPixels, 0, reason: 'a pink gradient leaked into the dial');
    });

    test('the dial paints blue and never the teal or amber accents', () async {
      const size = 234.0;
      final canvas = await _renderPainter(painterAt(340), size);

      var bluePixels = 0;
      var tealPixels = 0;
      var amberPixels = 0;

      for (var y = 0; y < canvas.side; y++) {
        for (var x = 0; x < canvas.side; x++) {
          final (r, g, b, a) = canvas.at(x, y);
          if (a < 13) continue; // fully transparent - skip

          // primary #2F6BE4 -> blue dominant, red well below it.
          if (b > 150 && b - r > 60 && b - g > 40) bluePixels++;

          // secondary #0FA396 -> green and blue close, red low.
          if (g > 120 && r < 90 && b > 110 && b < 200) tealPixels++;

          // amber #F0A82E -> red and green high, blue low.
          if (r > 200 && g > 130 && b < 110) amberPixels++;
        }
      }

      expect(bluePixels, greaterThan(200), reason: 'expected a blue gauge');
      expect(tealPixels, 0, reason: 'teal (secondary) leaked into the gauge');
      expect(amberPixels, 0, reason: 'amber leaked into the gauge');
    });
  });
  group('Performance guards', () {
    test('AppStateScope never rebuilds dependants via updateShouldNotify', () {
      // The notifier is final, so `true` here would mean every notifyListeners
      // call - every favourite tap, every keystroke - marks the whole app
      // dirty. This test exists so nobody reintroduces it.
      final state = AppState();
      final scope = AppStateScope(notifier: state, child: const SizedBox());
      final same = AppStateScope(notifier: state, child: const SizedBox());

      expect(scope.updateShouldNotify(same), isFalse);

      // And the inherited notifier stays the same object across changes.
      state.toggleFavourite(carList.first);
      expect(identical(state, scope.notifier), isTrue);
    });

    testWidgets('EntranceFade drops its Opacity layer once settled', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EntranceFade(order: 0, child: Text('card')),
          ),
        ),
      );

      // Mid-animation the wrapper is compositing.
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.byType(Opacity), findsOneWidget);

      // Once it settles, the child is returned bare - no saveLayer per frame
      // per list item while scrolling.
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(Opacity), findsNothing);
      expect(find.text('card'), findsOneWidget);
    });

    testWidgets('car card image is not rendered at full resolution', (
      tester,
    ) async {
      await tester.pumpWidget(
        AppStateScope(
          notifier: AppState(),
          child: MaterialApp(
            home: Scaffold(
              body: CarCard(car: carList.first, onTap: () {}),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // `cacheWidth` is not exposed on the widget, but the framework wraps the
      // provider in a ResizeImage when it is set - that is the observable
      // proof the decode is being downscaled rather than done at source size.
      final image = tester.widget<widgets.Image>(find.byType(widgets.Image).first);
      expect(
        image.image,
        isA<ResizeImage>(),
        reason: 'car images must declare a decode width so scrolling does not '
            'downscale full-resolution PNGs every frame',
      );
      final resized = image.image as ResizeImage;
      expect(resized.width, isNotNull);
      expect(resized.width!, greaterThan(0));
    });
  });
}

/// Renders [painter] at [side] x [side] into an RGBA byte buffer via
/// [Picture.toImageSync] - no golden files, no platform font quirks to fight.
///
/// Returns the raw RGBA bytes plus the side length so callers can sample any
/// pixel. `dart:ui` has no `Image.getPixel`, so we go through [ByteData].
Future<_RgbaCanvas> _renderPainter(CustomPainter painter, double side) async {
  final recorder = ui.PictureRecorder();
  painter.paint(Canvas(recorder), Size(side, side));
  final picture = recorder.endRecording();
  final image = picture.toImageSync(side.toInt(), side.toInt());
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  image.dispose();
  picture.dispose();
  return _RgbaCanvas(data!.buffer.asUint8List(), side.toInt());
}

/// A decoded RGBA buffer with a tiny pixel accessor.
class _RgbaCanvas {
  _RgbaCanvas(this.bytes, this.side);

  final Uint8List bytes;
  final int side;

  /// Returns (r, g, b, a) for the pixel at [x], [y].
  (int, int, int, int) at(int x, int y) {
    final i = (y * side + x) * 4;
    return (bytes[i], bytes[i + 1], bytes[i + 2], bytes[i + 3]);
  }
}
