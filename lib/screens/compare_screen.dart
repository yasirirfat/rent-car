import 'package:flutter/material.dart';
import 'package:rent_car/car_data/car_data.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/core/app_state.dart';
import 'package:rent_car/model/car_model.dart';
import 'package:rent_car/widgets/car_card.dart' show CompareActionButton;
import 'package:rent_car/widgets/painters/comparison_chart.dart';

/// Side-by-side comparison of the cars queued via [AppState.toggleCompare].
///
/// Structure, top to bottom:
///
///   1. App bar          - back, title, live count, clear.
///   2. Column headers   - a card per car, each colour-coded so the same car is
///                         recognisable in every chart and every table row.
///   3. Metric charts    - three labelled bars (speed / price / performance).
///   4. Spec matrix      - price, engine, top speed, mileage, fuel, seats,
///                         drivetrain, airbags. The winner of each numeric row
///                         is highlighted with a `BEST` tag.
///   5. Verdict          - best overall / fastest / best value.
///
/// The car header strip is rendered twice: once as a normal sliver and once as
/// a pinned sliver that fades in on scroll. That way the colour legend is never
/// more than a glance away when you are deep in the spec matrix.
class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final cars = state.compareCarsFrom(carList);

    return Scaffold(
      backgroundColor: AppColor.canvas,
      body: SafeArea(
        bottom: false,
        child: cars.length < 2
            ? _NotEnough(cars: cars)
            : _ComparisonBody(cars: cars),
      ),
    );
  }
}

class _ComparisonBody extends StatelessWidget {
  const _ComparisonBody({required this.cars});

  final List<CarModel> cars;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // --- 1. App bar -----------------------------------------------------
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColor.canvas,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 62,
          leadingWidth: 62,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _RoundButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.maybePop(context),
            ),
          ),
          titleSpacing: 8,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'COMPARISON',
                style: TextStyle(
                  color: AppColor.textMuted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${cars.length} cars side by side',
                style: const TextStyle(
                  color: AppColor.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  height: 1.15,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: state.clearCompare,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.surfaceHigh,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColor.stroke),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.close_rounded,
                        size: 13,
                        color: AppColor.textSecondary,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Clear',
                        style: TextStyle(
                          color: AppColor.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // --- 2. Column headers (colour legend) ------------------------------
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: _CarHeaderRow(cars: cars, height: 132),
          ),
        ),

        // --- 3. Metric charts -----------------------------------------------
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(
                  'PERFORMANCE',
                  trailing: 'higher is better',
                  accent: AppColor.primary,
                ),
                const SizedBox(height: 12),
                _ChartPanel(
                  accent: AppColor.secondary,
                  child: ComparisonChart(
                    height: 168,
                    entries: [
                      for (var i = 0; i < cars.length; i++)
                        ComparisonEntry(
                          label: _short(cars[i].model),
                          value: (cars[i].topSpeedKmh / 400).clamp(0.06, 1.0),
                          valueLabel: '${cars[i].topSpeedKmh.round()}',
                          color: _accentFor(i),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                _SectionLabel(
                  'DAILY RATE',
                  trailing: 'USD per day · lower is better',
                  accent: AppColor.amber,
                ),
                const SizedBox(height: 12),
                _ChartPanel(
                  accent: AppColor.amber,
                  child: ComparisonChart(
                    height: 168,
                    entries: [
                      for (var i = 0; i < cars.length; i++)
                        ComparisonEntry(
                          label: _short(cars[i].model),
                          // Cheaper renders taller, so invert the ratio.
                          value:
                              (1 - cars[i].price / _maxPrice(cars))
                                  .clamp(0.06, 1.0),
                          valueLabel:
                              '\$${cars[i].price.toStringAsFixed(0)}',
                          color: _accentFor(i),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                _SectionLabel(
                  'PERFORMANCE INDEX',
                  trailing: 'composite score · 0-100',
                  accent: AppColor.primary,
                ),
                const SizedBox(height: 12),
                _ChartPanel(
                  accent: AppColor.primary,
                  child: ComparisonChart(
                    height: 168,
                    entries: [
                      for (var i = 0; i < cars.length; i++)
                        ComparisonEntry(
                          label: _short(cars[i].model),
                          value: cars[i].performanceScore.clamp(0.06, 1.0),
                          valueLabel:
                              '${(cars[i].performanceScore * 100).round()}',
                          color: _accentFor(i),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- 4. Spec matrix --------------------------------------------------
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(
                  'SPECIFICATION',
                  trailing: 'winner marked BEST',
                  accent: AppColor.success,
                ),
                const SizedBox(height: 12),
                _SpecMatrix(cars: cars),
              ],
            ),
          ),
        ),

        // --- 5. Verdict ------------------------------------------------------
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: _Verdict(cars: cars),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 130)),
      ],
    );
  }

  static double _maxPrice(List<CarModel> cars) =>
      cars.map((c) => c.price).reduce((a, b) => a > b ? a : b);

  static Color _accentFor(int index) => AppColor.accentFor(index);

  /// Trims a long model name so it fits under a chart bar.
  static String _short(String model) {
    if (model.length <= 11) return model;
    final first = model.split(' ').first;
    return first.length <= 11 ? first : '${first.substring(0, 10)}.';
  }
}

// -----------------------------------------------------------------------------
// Shared bits
// -----------------------------------------------------------------------------

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColor.surfaceHigh,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColor.stroke),
        ),
        child: Icon(icon, color: AppColor.textPrimary, size: 19),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.trailing, required this.accent});

  final String text;
  final String? trailing;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          text,
          style: const TextStyle(
            color: AppColor.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            height: 1.2,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          Flexible(
            child: Text(
              trailing!,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColor.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Flat elevated panel used to frame each chart.
class _ChartPanel extends StatelessWidget {
  const _ChartPanel({required this.child, required this.accent});

  final Widget child;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 6),
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.stroke),
        boxShadow: AppColor.cardShadow,
      ),
      child: child,
    );
  }
}

// -----------------------------------------------------------------------------
// Column headers - one card per car, colour-coded
// -----------------------------------------------------------------------------

class _CarHeaderRow extends StatelessWidget {
  const _CarHeaderRow({required this.cars, required this.height});

  final List<CarModel> cars;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cars.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(
              child: _CarHeader(car: cars[i], accent: AppColor.accentFor(i)),
            ),
          ],
        ],
      ),
    );
  }
}

class _CarHeader extends StatelessWidget {
  const _CarHeader({required this.car, required this.accent});

  final CarModel car;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        boxShadow: AppColor.cardShadow,
      ),
      child: Column(
        children: [
          // Accent spine so the colour legend is obvious.
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Column(
                children: [
                  Expanded(
                    child: Image.asset(
                      car.image,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => Icon(
                        Icons.directions_car_filled_rounded,
                        color: accent,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    car.model,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColor.textPrimary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${car.price.toStringAsFixed(0)} / day',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Spec matrix
// -----------------------------------------------------------------------------

/// A definition row: the label, a value per car, and how to decide the winner.
class _Spec {
  const _Spec({
    required this.label,
    required this.icon,
    required this.values,
    this.raw,
    this.higherIsBetter = true,
    this.accent = AppColor.textSecondary,
  });

  final String label;
  final IconData icon;
  final List<String> values;

  /// Numeric form of [values], used to decide the winner. Null = no winner.
  final List<double>? raw;
  final bool higherIsBetter;
  final Color accent;
}

class _SpecMatrix extends StatelessWidget {
  const _SpecMatrix({required this.cars});

  final List<CarModel> cars;

  @override
  Widget build(BuildContext context) {
    final specs = <_Spec>[
      _Spec(
        label: 'Price / day',
        icon: Icons.payments_rounded,
        values: [
          for (final c in cars) '\$${c.price.toStringAsFixed(0)}',
        ],
        raw: [for (final c in cars) c.price],
        higherIsBetter: false,
        accent: AppColor.amber,
      ),
      _Spec(
        label: 'Engine',
        icon: Icons.settings_rounded,
        values: [for (final c in cars) c.engine],
        accent: AppColor.primary,
      ),
      _Spec(
        label: 'Top speed',
        icon: Icons.speed_rounded,
        values: [for (final c in cars) c.maxSpeed],
        raw: [for (final c in cars) c.topSpeedKmh],
        accent: AppColor.primary,
      ),
      _Spec(
        label: 'Mileage',
        icon: Icons.route_rounded,
        values: [for (final c in cars) c.mileage],
        raw: [for (final c in cars) c.mileageKm.toDouble()],
        higherIsBetter: false,
        accent: AppColor.info,
      ),
      _Spec(
        label: 'Fuel type',
        icon: Icons.local_gas_station_rounded,
        values: [for (final c in cars) c.fuelType],
        accent: AppColor.amber,
      ),
      _Spec(
        label: 'Seats',
        icon: Icons.airline_seat_recline_normal_rounded,
        values: [for (final c in cars) c.ability],
        accent: AppColor.success,
      ),
      _Spec(
        label: 'Drivetrain',
        icon: Icons.alt_route_rounded,
        values: [for (final c in cars) c.drivetrain],
        accent: AppColor.secondary,
      ),
      _Spec(
        label: 'Airbags',
        icon: Icons.shield_rounded,
        values: [for (final c in cars) c.airbag],
        accent: AppColor.danger,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.stroke),
        boxShadow: AppColor.cardShadow,
      ),
      child: Column(
        children: [
          for (var i = 0; i < specs.length; i++)
            _SpecBlock(
              spec: specs[i],
              columnCount: cars.length,
              isFirst: i == 0,
              isLast: i == specs.length - 1,
            ),
        ],
      ),
    );
  }
}

class _SpecBlock extends StatelessWidget {
  const _SpecBlock({
    required this.spec,
    required this.columnCount,
    required this.isFirst,
    required this.isLast,
  });

  final _Spec spec;
  final int columnCount;
  final bool isFirst;
  final bool isLast;

  /// Index of the winning column, or -1 when this row has no numeric winner.
  int _winner() {
    final raw = spec.raw;
    if (raw == null || raw.isEmpty) return -1;
    var best = raw.first;
    var index = 0;
    for (var i = 1; i < raw.length; i++) {
      final beats = spec.higherIsBetter ? raw[i] > best : raw[i] < best;
      if (beats) {
        best = raw[i];
        index = i;
      }
    }
    // All equal - nothing to celebrate.
    if (raw.every((v) => v == best)) return -1;
    return index;
  }

  @override
  Widget build(BuildContext context) {
    final winner = _winner();

    return Column(
      children: [
        if (!isFirst)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: AppColor.stroke,
          ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, isFirst ? 16 : 14, 16, isLast ? 16 : 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row label with an icon, sitting above the values so it never
              // squeezes the columns on a narrow screen.
              Row(
                children: [
                  Icon(spec.icon, size: 13, color: spec.accent),
                  const SizedBox(width: 7),
                  Text(
                    spec.label,
                    style: const TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // One cell per car.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < columnCount; i++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? 0 : 6,
                          right: i == columnCount - 1 ? 0 : 6,
                        ),
                        child: _SpecCell(
                          value: i < spec.values.length ? spec.values[i] : '-',
                          isWinner: i == winner,
                          accent: AppColor.accentFor(i),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpecCell extends StatelessWidget {
  const _SpecCell({
    required this.value,
    required this.isWinner,
    required this.accent,
  });

  final String value;
  final bool isWinner;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: isWinner
            ? AppColor.success.withValues(alpha: 0.10)
            : AppColor.surfaceHigh,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: isWinner
              ? AppColor.success.withValues(alpha: 0.45)
              : AppColor.stroke,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // A tiny colour dot keeps the cell tied to its column.
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isWinner ? AppColor.success : AppColor.textPrimary,
              fontSize: 12,
              fontWeight: isWinner ? FontWeight.w800 : FontWeight.w600,
              height: 1.25,
            ),
          ),
          if (isWinner) ...[
            const SizedBox(height: 4),
            const Text(
              'BEST',
              style: TextStyle(
                color: AppColor.success,
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.9,
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Verdict
// -----------------------------------------------------------------------------

class _Verdict extends StatelessWidget {
  const _Verdict({required this.cars});

  final List<CarModel> cars;

  @override
  Widget build(BuildContext context) {
    // Pick the car with the best blend of performance and value.
    final scored = [...cars]
      ..sort(
        (a, b) => (b.performanceScore + b.valueScore)
            .compareTo(a.performanceScore + a.valueScore),
      );
    final best = scored.first;

    final fastest = ([...cars]
          ..sort((a, b) => b.topSpeedKmh.compareTo(a.topSpeedKmh)))
        .first;
    final cheapest = ([...cars]..sort((a, b) => a.price.compareTo(b.price)))
        .first;
    final lowestMileage = ([...cars]..sort((a, b) => a.mileageKm.compareTo(b.mileageKm)))
        .first;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColor.amber.withValues(alpha: 0.30)),
        boxShadow: AppColor.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColor.amber,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VERDICT',
                        style: TextStyle(
                          color: AppColor.textMuted,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'How they stack up',
                        style: TextStyle(
                          color: AppColor.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _VerdictLine(
            icon: Icons.tune_rounded,
            accent: AppColor.primary,
            label: 'Best overall',
            value: '${best.company} ${best.model}',
          ),
          _VerdictLine(
            icon: Icons.speed_rounded,
            accent: AppColor.secondary,
            label: 'Fastest',
            value: '${fastest.model} · ${fastest.topSpeedKmh.round()} km/h',
          ),
          _VerdictLine(
            icon: Icons.savings_rounded,
            accent: AppColor.success,
            label: 'Best value',
            value:
                '${cheapest.model} · \$${cheapest.price.toStringAsFixed(0)}/day',
          ),
          _VerdictLine(
            icon: Icons.route_rounded,
            accent: AppColor.info,
            label: 'Lowest miles',
            value: '${lowestMileage.model} · ${lowestMileage.mileage}',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _VerdictLine extends StatelessWidget {
  const _VerdictLine({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: AppColor.stroke, width: 1),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: accent),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColor.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColor.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Empty state
// -----------------------------------------------------------------------------

class _NotEnough extends StatelessWidget {
  const _NotEnough({required this.cars});

  final List<CarModel> cars;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(
            children: [
              _RoundButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.maybePop(context),
              ),
              const SizedBox(width: 14),
              const Text(
                'Compare',
                style: TextStyle(
                  color: AppColor.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: AppColor.surfaceHigh,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColor.stroke),
                    ),
                    child: const Icon(
                      Icons.compare_arrows_rounded,
                      size: 40,
                      color: AppColor.textMuted,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Pick at least two cars',
                    style: TextStyle(
                      color: AppColor.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cars.isEmpty
                        ? 'Tap Compare on any car card to add it to the line-up.'
                        : 'You have added 1 car. Add one more to see them side by side.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColor.textMuted,
                      fontSize: 12.5,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (cars.isNotEmpty) ...[
                    SizedBox(
                      width: 220,
                      child: CompareActionButton(
                        active: true,
                        compact: true,
                        onTap: state.clearCompare,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Text(
                        'Browse the fleet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
