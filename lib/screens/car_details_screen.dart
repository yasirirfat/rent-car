import 'package:flutter/material.dart';
import 'package:rent_car/car_data/custom_date_picker_dialoge.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/core/app_state.dart';
import 'package:rent_car/main.dart';
import 'package:rent_car/model/car_model.dart';
import 'package:rent_car/widgets/car_card_painter.dart';
import 'package:rent_car/widgets/painters/aurora_background.dart';
import 'package:rent_car/widgets/painters/glass_card.dart';
import 'package:rent_car/widgets/painters/hero_banner_painter.dart';
import 'package:rent_car/widgets/painters/progress_ring.dart';
import 'package:rent_car/widgets/painters/speedometer_widget.dart';

/// Full detail view for a single car with a painter-driven spec dashboard and
/// the rental booking flow.
class CarDetailsScreen extends StatefulWidget {
  const CarDetailsScreen({super.key, required this.car});

  final CarModel car;

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  DateTimeRange? _selectedDateRange;
  int _galleryIndex = 0;
  late final PageController _galleryController;

  CarModel get car => widget.car;

  int get _rentalDays {
    if (_selectedDateRange == null) return 1;
    return _selectedDateRange!.end.difference(_selectedDateRange!.start).inDays +
        1;
  }

  double get _totalPrice => car.price * _rentalDays;

  DateTimeRange get _effectiveRange {
    if (_selectedDateRange != null) return _selectedDateRange!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTimeRange(start: today, end: today);
  }

  @override
  void initState() {
    super.initState();
    _galleryController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppState.of(context).markViewed(car);
    });
  }

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  void _openDatePicker() {
    CustomDatePicker.openRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      title: 'RENTAL PERIOD',
      onDatesSelected: (range) => setState(() => _selectedDateRange = range),
    );
  }

  void _showBookingSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _BookingSheet(
        car: car,
        range: _effectiveRange,
        rentalDays: _rentalDays,
        totalPrice: _totalPrice,
        onConfirm: () {
          Navigator.pop(sheetContext);
          final booking = AppState.of(context).addBooking(
            car: car,
            start: _effectiveRange.start,
            end: _effectiveRange.end,
          );
          _showSuccessDialog(booking);
        },
      ),
    );
  }

  void _showSuccessDialog(Booking booking) {
    showDialog(
      context: context,
      barrierColor: AppColor.scrim.withValues(alpha: 0.8),
      builder: (dialogContext) => _SuccessDialog(
        car: car,
        booking: booking,
        onDone: () {
          // Close the dialog, leave the details screen, then land the user on
          // the Bookings tab so they can see the reservation they just made.
          Navigator.pop(dialogContext);
          Navigator.pop(context);
          MainWrapper.goToTab(MainWrapper.bookingsTab);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final isFav = state.isFavourite(car);
    final hasRange = _selectedDateRange != null;

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- Header: back ... calendar + favourite ---
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      // Calendar and favourite sit together at the right edge,
                      // both as bare circular icon buttons.
                      _RoundIconButton(
                        icon: Icons.calendar_month_rounded,
                        color: hasRange ? AppColor.primary : AppColor.textPrimary,
                        active: hasRange,
                        onTap: _openDatePicker,
                      ),
                      const SizedBox(width: 8),
                      _RoundIconButton(
                        icon: isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? AppColor.danger : AppColor.textPrimary,
                        onTap: () => state.toggleFavourite(car),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- Gallery ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: _Gallery(
                  car: car,
                  controller: _galleryController,
                  index: _galleryIndex,
                  onPageChanged: (i) => setState(() => _galleryIndex = i),
                ),
              ),
            ),

            // --- Title block ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                car.company.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColor.secondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.2,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                car.model,
                                style: const TextStyle(
                                  color: AppColor.textPrimary,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w800,
                                  height: 1.08,
                                  letterSpacing: -0.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.surfaceVeilStrong,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: AppColor.stroke),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColor.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                car.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: AppColor.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (car.tagline.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        car.tagline,
                        style: const TextStyle(
                          color: AppColor.textSecondary,
                          fontSize: 13.5,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // --- Performance dashboard: speedometer + rings ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('PERFORMANCE'),
                    const SizedBox(height: 14),
                    GlassCard(
                      radius: AppColor.radiusPanel,
                      accent: AppColor.primary,
                      glowStrength: 0.16,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Speedometer(
                            value: car.topSpeedKmh,
                            maxValue: 400,
                            size: 234,
                            label: 'TOP SPEED',
                            unit: 'KM/H',
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _RingStat(
                                  value: car.performanceScore,
                                  label: 'Power',
                                  display:
                                      '${(car.performanceScore * 100).round()}%',
                                  icon: Icons.bolt_rounded,
                                  accent: AppColor.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _RingStat(
                                  value: car.valueScore,
                                  label: 'Value',
                                  display:
                                      '${(car.valueScore * 100).round()}%',
                                  icon: Icons.savings_rounded,
                                  accent: AppColor.primary,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _RingStat(
                                  value: (car.rating / 5).clamp(0.0, 1.0),
                                  label: 'Rating',
                                  display: car.rating.toStringAsFixed(1),
                                  icon: Icons.star_rounded,
                                  accent: AppColor.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Spec stat bars ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('SPECIFICATIONS'),
                    const SizedBox(height: 14),
                    GlassCard(
                      radius: AppColor.radiusPanel,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          StatBar(
                            label: 'Top speed',
                            icon: Icons.speed_rounded,
                            value: car.topSpeedKmh,
                            max: 400,
                            displayValue: car.maxSpeed,
                            accent: AppColor.primary,
                          ),
                          const SizedBox(height: 18),
                          StatBar(
                            label: 'Acceleration potential',
                            icon: Icons.bolt_rounded,
                            value: car.performanceScore * 100,
                            max: 100,
                            displayValue:
                                '${(car.performanceScore * 100).round()} pts',
                            accent: AppColor.primary,
                          ),
                          const SizedBox(height: 18),
                          StatBar(
                            label: 'Cylinders',
                            icon: Icons.settings_rounded,
                            value: car.cylinderCount.toDouble(),
                            max: 12,
                            displayValue: '${car.cylinderCount}',
                            accent: AppColor.primary,
                          ),
                          const SizedBox(height: 18),
                          StatBar(
                            label: 'Passenger seats',
                            icon: Icons.airline_seat_recline_normal_rounded,
                            value: car.seatCount.toDouble(),
                            max: 4,
                            displayValue: '${car.seatCount} seats',
                            accent: AppColor.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Spec grid ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('AT A GLANCE'),
                    const SizedBox(height: 14),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.86,
                      children: [
                        SpecTile(
                          icon: Icons.speed_rounded,
                          title: 'Top Speed',
                          value: car.maxSpeed,
                          accent: AppColor.primary,
                        ),
                        SpecTile(
                          icon: Icons.settings_rounded,
                          title: 'Engine',
                          value: car.engine,
                          accent: AppColor.primary,
                        ),
                        SpecTile(
                          icon: Icons.airline_seat_recline_normal_rounded,
                          title: 'Seats',
                          value: car.ability,
                          accent: AppColor.primary,
                        ),
                        SpecTile(
                          icon: Icons.shield_rounded,
                          title: 'Airbags',
                          value: car.airbag,
                          accent: AppColor.primary,
                        ),
                        SpecTile(
                          icon: Icons.local_gas_station_rounded,
                          title: 'Fuel',
                          value: car.fuelType,
                          accent: AppColor.primary,
                        ),
                        SpecTile(
                          icon: Icons.tune_rounded,
                          title: 'Drivetrain',
                          value: car.drivetrain,
                          accent: AppColor.primary,
                        ),
                        SpecTile(
                          icon: Icons.route_rounded,
                          title: 'Mileage',
                          value: car.mileage,
                          accent: AppColor.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- Rental period is picked from the chip in the header ---

            const SliverToBoxAdapter(child: SizedBox(height: 140)),
          ],
        ),

        // --- Sticky booking bar ---
        bottomNavigationBar: _BookingBar(
          dailyPrice: car.price,
          rentalDays: _rentalDays,
          totalPrice: _totalPrice,
          onBook: _showBookingSheet,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Gallery
// -----------------------------------------------------------------------------

class _Gallery extends StatelessWidget {
  const _Gallery({
    required this.car,
    required this.controller,
    required this.index,
    required this.onPageChanged,
  });

  final CarModel car;
  final PageController controller;
  final int index;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final images = car.allImages;

    return Column(
      children: [
        SizedBox(
          height: 214,
          child: PageView.builder(
            controller: controller,
            itemCount: images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: CustomPaint(
                    painter: _GalleryBackdropPainter(index: i),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Decorative dashed ring behind the car.
                        Positioned(
                          child: SizedBox(
                            width: 230,
                            height: 230,
                            child: CustomPaint(
                              painter: DashedRingPainter(
                                color: AppColor.primary,
                                opacity: 0.22,
                                dashCount: 56,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: LayoutBuilder(
                            builder: (context, c) => Image.asset(
                              images[i],
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.medium,
                              // The gallery pages are a pager, so each decoded
                              // frame is retained; decoding at paint size keeps
                              // swiping smooth instead of thrashing the cache.
                              cacheWidth: (c.maxWidth * 3).round(),
                              errorBuilder: (ctx, err, stack) => CustomPaint(
                                size: const Size(230, 100),
                                painter: CarSilhouettePainter(
                                  strokeOnly: true,
                                  opacity: 0.35,
                                  accent: AppColor.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Image counter
                        Positioned(
                          right: 14,
                          top: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.scrim.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColor.stroke.withValues(alpha: 0.8),
                              ),
                            ),
                            child: Text(
                              '${i + 1} / ${images.length}',
                              style: const TextStyle(
                                color: AppColor.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (i) {
              final active = i == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  gradient: active ? AppColor.brandGradient : null,
                  color: active ? null : AppColor.stroke,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _GalleryBackdropPainter extends CustomPainter {
  _GalleryBackdropPainter({required this.index});

  final int index;

  @override
  void paint(Canvas canvas, Size size) {
    final accent = AppColor.accentFor(index);
    final rect = Offset.zero & size;

    // Flat light panel - no gradient. A faint accent tint distinguishes the
    // gallery from the page without introducing a colour transition.
    canvas.drawRect(
      rect,
      Paint()
        ..color = Color.alphaBlend(
          accent.withValues(alpha: 0.05),
          AppColor.surfaceHigh,
        ),
    );

    // A soft contact shadow under the car, so it sits on the surface rather
    // than floating. Drawn as a blurred flat ellipse.
    final center = Offset(size.width * 0.5, size.height * 0.80);
    final shadowRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.56,
      height: 26,
    );
    canvas.drawOval(
      shadowRect,
      Paint()
        ..color = const Color(0xFF101828).withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Hairline border.
    canvas.drawRect(
      rect.deflate(0.7),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = AppColor.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _GalleryBackdropPainter oldDelegate) =>
      oldDelegate.index != index;
}

// -----------------------------------------------------------------------------
// Building blocks
// -----------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            gradient: AppColor.brandGradient,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppColor.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.color = AppColor.textPrimary,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  /// Tints the button blue to signal that the thing it controls has a value
  /// set - used by the calendar button once a rental range is chosen.
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active
              ? AppColor.primary.withValues(alpha: 0.12)
              : AppColor.surfaceVeil,
          shape: BoxShape.circle,
          border: Border.all(
            color: active
                ? AppColor.primary.withValues(alpha: 0.45)
                : AppColor.stroke,
          ),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _RingStat extends StatelessWidget {
  const _RingStat({
    required this.value,
    required this.label,
    required this.display,
    required this.icon,
    required this.accent,
  });

  final double value;
  final String label;
  final String display;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProgressRing(
          value: value.clamp(0.0, 1.0),
          size: 62,
          strokeWidth: 5,
          // Blue only - the ring used to lerp toward the teal secondary.
          gradientColors: [accent, accent],
          child: Icon(icon, size: 19, color: accent),
        ),
        const SizedBox(height: 9),
        Text(
          display,
          style: const TextStyle(
            color: AppColor.textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColor.textMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// A single spec cell with an accent-tinted icon chip.
class SpecTile extends StatelessWidget {
  const SpecTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      padding: const EdgeInsets.all(10),
      accent: accent,
      glowStrength: 0.08,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColor.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColor.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingBar extends StatelessWidget {
  const _BookingBar({
    required this.dailyPrice,
    required this.rentalDays,
    required this.totalPrice,
    required this.onBook,
  });

  final double dailyPrice;
  final int rentalDays;
  final double totalPrice;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColor.navBarGradient,
        border: Border(
          top: BorderSide(color: AppColor.stroke.withValues(alpha: 0.8)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              // Flexible so the breakdown line ("$428 x 3 d") yields rather
              // than pushing the Book button off the edge on narrow screens.
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        color: AppColor.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            '\$${totalPrice.toStringAsFixed(0)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColor.amber,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              '\$${dailyPrice.toStringAsFixed(0)} x $rentalDays d',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColor.textMuted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Spacer(),
              GestureDetector(
                onTap: onBook,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColor.glow(
                      AppColor.primary,
                      opacity: 0.32,
                      blur: 16,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Book Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(width: 7),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Booking sheet + success dialog
// -----------------------------------------------------------------------------

class _BookingSheet extends StatelessWidget {
  const _BookingSheet({
    required this.car,
    required this.range,
    required this.rentalDays,
    required this.totalPrice,
    required this.onConfirm,
  });

  final CarModel car;
  final DateTimeRange range;
  final int rentalDays;
  final double totalPrice;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColor.textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColor.surfaceHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(
                    car.image,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.directions_car_filled_rounded,
                      color: AppColor.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.model,
                      style: const TextStyle(
                        color: AppColor.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${car.engine}  •  ${car.drivetrain}',
                      style: const TextStyle(
                        color: AppColor.textMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const _SheetDivider(),
          const SizedBox(height: 18),
          _SummaryRow(label: 'Daily rate', value: '\$${car.price.toStringAsFixed(0)}'),
          _SummaryRow(label: 'Rental days', value: '$rentalDays'),
          _SummaryRow(
            label: 'Period',
            value: CustomDatePicker.formatRange(range),
          ),
          _SummaryRow(label: 'Insurance', value: 'Included'),
          const SizedBox(height: 14),
          const _SheetDivider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total amount',
                style: TextStyle(
                  color: AppColor.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColor.amber,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: onConfirm,
            child: Container(
              height: 56,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: AppColor.amberGradient,
                borderRadius: BorderRadius.circular(17),
                boxShadow: AppColor.glow(
                  AppColor.amber,
                  opacity: 0.35,
                  blur: 22,
                ),
              ),
              child: const Text(
                'Confirm & Pay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColor.stroke);
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColor.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColor.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({
    required this.car,
    required this.booking,
    required this.onDone,
  });

  final CarModel car;
  final Booking booking;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColor.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColor.success.withValues(alpha: 0.35),
          ),
          boxShadow: AppColor.glow(AppColor.success, opacity: 0.25, blur: 34),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AccentHalo(
              color: AppColor.success,
              size: 104,
              opacity: 0.3,
              child: const Icon(
                Icons.check_rounded,
                color: AppColor.success,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Booking Confirmed',
              style: TextStyle(
                color: AppColor.textPrimary,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${car.company} ${car.model} is reserved for '
              '${booking.days} day${booking.days == 1 ? '' : 's'}.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColor.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: AppColor.surfaceHigh,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColor.stroke),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.confirmation_number_outlined,
                    color: AppColor.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Confirmation',
                    style: TextStyle(
                      color: AppColor.textMuted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    booking.confirmationCode,
                    style: const TextStyle(
                      color: AppColor.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: onDone,
              child: Container(
                height: 50,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColor.brandGradient,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'View in Bookings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
