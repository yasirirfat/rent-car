import 'package:flutter/material.dart';
import 'package:rent_car/car_data/custom_date_picker_dialoge.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/core/app_state.dart';
import 'package:rent_car/main.dart';
import 'package:rent_car/widgets/painters/aurora_background.dart';
import 'package:rent_car/widgets/painters/glass_card.dart';

/// Bookings tab: segmented view over the user's real bookings with an optional
/// date-range filter. Bookings made from the details screen appear here
/// immediately.
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _segment = 0;
  DateTimeRange? _selectedDateRange;

  List<Booking> _filtered(AppState state) {
    final all = state.bookings;
    final base = _segment == 0
        ? all.where((b) => b.status != BookingStatus.completed).toList()
        : all.where((b) => b.status == BookingStatus.completed).toList();

    if (_selectedDateRange == null) return base;

    return base.where((booking) {
      // Overlap test: booking intersects the selected window.
      return !booking.start.isAfter(_selectedDateRange!.end) &&
          !booking.end.isBefore(_selectedDateRange!.start);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final bookings = _filtered(state);

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // --- Header ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MY GARAGE',
                          style: TextStyle(
                            color: AppColor.secondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.4,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Bookings',
                          style: TextStyle(
                            color: AppColor.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => CustomDatePicker.openRangePicker(
                        context: context,
                        initialDateRange: _selectedDateRange,
                        title: 'FILTER BY DATES',
                        onDatesSelected: (range) =>
                            setState(() => _selectedDateRange = range),
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _selectedDateRange != null
                              ? AppColor.accentVeil(AppColor.secondary)
                              : AppColor.surfaceVeil,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedDateRange != null
                                ? AppColor.secondary
                                : AppColor.stroke,
                            width: _selectedDateRange != null ? 1.4 : 1,
                          ),
                        ),
                        child: Icon(
                          _selectedDateRange == null
                              ? Icons.calendar_today_rounded
                              : Icons.edit_calendar_rounded,
                          color: _selectedDateRange == null
                              ? AppColor.textSecondary
                              : AppColor.secondary,
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Summary strip ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryPill(
                        label: 'Total rides',
                        value: '${state.totalRides}',
                        accent: AppColor.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryPill(
                        label: 'Active',
                        value: '${state.activeCount}',
                        accent: AppColor.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryPill(
                        label: 'Spend',
                        value: '\$${state.totalSpend.toStringAsFixed(0)}',
                        accent: AppColor.amber,
                      ),
                    ),
                  ],
                ),
              ),

              // --- Active date filter chip ---
              if (_selectedDateRange != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_alt_rounded,
                        size: 14,
                        color: AppColor.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        CustomDatePicker.formatRange(_selectedDateRange!),
                        style: const TextStyle(
                          color: AppColor.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDateRange = null),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.secondary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Clear',
                                style: TextStyle(
                                  color: AppColor.secondary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                Icons.close_rounded,
                                color: AppColor.secondary,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // --- Segmented control ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColor.surfaceVeil,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColor.stroke),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _Segment(
                          label: 'Active & Upcoming',
                          selected: _segment == 0,
                          accent: AppColor.secondary,
                          onTap: () => setState(() => _segment = 0),
                        ),
                      ),
                      Expanded(
                        child: _Segment(
                          label: 'History',
                          selected: _segment == 1,
                          accent: AppColor.textMuted,
                          onTap: () => setState(() => _segment = 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // --- List ---
              Expanded(
                child: bookings.isEmpty
                    ? _EmptyBookings(hasFilter: _selectedDateRange != null)
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) => _BookingCard(
                          booking: bookings[index],
                          onCancel: () => state.cancelBooking(bookings[index]),
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

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 17,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      accent: accent,
      glowStrength: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColor.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          color: selected ? AppColor.primary : null,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColor.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking, required this.onCancel});

  final Booking booking;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final status = booking.status;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        radius: 20,
        accent: status.color,
        glowStrength: 0.10,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: status.color.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.label.toUpperCase(),
                          style: TextStyle(
                            color: status.color,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 11),
                      Text(
                        booking.car.company.toUpperCase(),
                        style: const TextStyle(
                          color: AppColor.textMuted,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.car.model,
                        style: const TextStyle(
                          color: AppColor.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(
                            Icons.confirmation_number_outlined,
                            size: 12,
                            color: AppColor.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            booking.confirmationCode,
                            style: const TextStyle(
                              color: AppColor.textMuted,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 140,
                  height: 84,
                  child: Image.asset(
                    booking.car.image,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.directions_car_filled_rounded,
                      color: AppColor.textMuted,
                      size: 44,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: AppColor.stroke),
            const SizedBox(height: 14),
            Row(
              children: [
                _MetaChip(
                  icon: Icons.date_range_rounded,
                  label: CustomDatePicker.formatRange(
                    DateTimeRange(start: booking.start, end: booking.end),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '\$${booking.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColor.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${booking.days} day${booking.days == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppColor.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  booking.timelineLabel,
                  style: TextStyle(
                    color: status == BookingStatus.active
                        ? AppColor.secondary
                        : AppColor.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (status == BookingStatus.upcoming) ...[
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.danger.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          color: AppColor.danger,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.surfaceVeil,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.stroke),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppColor.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColor.textPrimary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBookings extends StatelessWidget {
  const _EmptyBookings({required this.hasFilter});

  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AccentHalo(
              color: AppColor.primary,
              size: 150,
              opacity: 0.16,
              child: const Icon(
                Icons.event_busy_rounded,
                size: 46,
                color: AppColor.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasFilter ? 'No rides in these dates' : 'No rentals yet',
              style: const TextStyle(
                color: AppColor.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilter
                  ? 'Try widening the date range.'
                  : 'Pick a car and book your first drive.',
              style: const TextStyle(
                color: AppColor.textMuted,
                fontSize: 12.5,
              ),
            ),
            if (!hasFilter) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => MainWrapper.goToTab(MainWrapper.homeTab),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Browse cars',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
