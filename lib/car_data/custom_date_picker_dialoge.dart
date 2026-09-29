import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

/// Themed range date picker used for rental selection and booking filters.
///
/// Renders the stock [DateRangePickerDialog] inside a custom light shell so it
/// reads as a focused "sheet" against the dark app, and normalises the result
/// to a day-precision [DateTimeRange].
class CustomDatePicker {
  static void openRangePicker({
    required BuildContext context,
    required DateTimeRange? initialDateRange,
    required Function(DateTimeRange) onDatesSelected,
    DateTime? firstDate,
    DateTime? lastDate,
    String title = 'SELECT DATES',
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    showDialog(
      context: context,
      barrierColor: AppColor.scrim.withValues(alpha: 0.75),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          // Kept tight so the stock range picker gets the maximum usable
          // width - its header Row is split 50/50 and overflows on narrow
          // phones if the dialog eats too much of the screen.
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360, maxHeight: 520),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColor.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColor.primary.withValues(alpha: 0.28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withValues(alpha: 0.22),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColor.scrim.withValues(alpha: 0.7),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColor.textMuted.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: AppColor.secondary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColor.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _PickerShell(
                        initialDateRange: initialDateRange,
                        firstDate: firstDate ?? today,
                        lastDate: lastDate ?? DateTime(today.year + 4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((pickedValue) {
      if (pickedValue != null && pickedValue is DateTimeRange) {
        onDatesSelected(_normalise(pickedValue));
      }
    });
  }

  /// Strips the time component so day-count maths stays exact.
  static DateTimeRange _normalise(DateTimeRange range) {
    return DateTimeRange(
      start: DateTime(range.start.year, range.start.month, range.start.day),
      end: DateTime(range.end.year, range.end.month, range.end.day),
    );
  }

  /// Formats a range the way the app displays it, e.g. "12 Mar - 15 Mar".
  static String formatRange(DateTimeRange range, {List<String>? months}) {
    const defaultMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final m = months ?? defaultMonths;
    return '${range.start.day} ${m[range.start.month - 1]} - '
        '${range.end.day} ${m[range.end.month - 1]}';
  }
}

/// Applies the app's accent colours to the stock range picker.
class _PickerShell extends StatelessWidget {
  const _PickerShell({
    required this.initialDateRange,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTimeRange? initialDateRange;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColor.secondary,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: AppColor.surface,
          surfaceTintColor: Colors.transparent,
          headerBackgroundColor: AppColor.surfaceHigh,
          headerForegroundColor: AppColor.textPrimary,
          dividerColor: Colors.transparent,
          rangeSelectionBackgroundColor:
              AppColor.primary.withValues(alpha: 0.22),
          rangePickerBackgroundColor: Colors.transparent,
          rangePickerSurfaceTintColor: Colors.transparent,
          dayForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColor.textMuted.withValues(alpha: 0.35);
            }
            if (states.contains(WidgetState.selected)) {
              return AppColor.scrim;
            }
            return AppColor.textPrimary;
          }),
          dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColor.secondary;
            }
            return null;
          }),
          dayOverlayColor: WidgetStateProperty.all(
            AppColor.primary.withValues(alpha: 0.18),
          ),
          dayStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          yearForegroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColor.scrim;
            }
            return AppColor.textPrimary;
          }),
          yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColor.secondary;
            }
            return null;
          }),
          yearStyle: const TextStyle(fontWeight: FontWeight.w700),
          todayBorder: const BorderSide(color: AppColor.amber, width: 1.4),
          todayForegroundColor: WidgetStateProperty.all(AppColor.amber),
          rangePickerHeaderForegroundColor: AppColor.textPrimary,
          // The stock header text is sized for a tablet-width dialog. Pinning
          // both header styles to a compact scale is what stops the header Row
          // from overflowing on a 360-400px phone, which it otherwise did by
          // more than 100px once a range was selected.
          rangePickerHeaderHeadlineStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
          rangePickerHeaderHelpStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: DateRangePickerDialog(
          firstDate: firstDate,
          lastDate: lastDate,
          initialDateRange: initialDateRange,
          confirmText: 'CONFIRM',
          cancelText: 'DISMISS',
          helpText: '',
          saveText: 'CONFIRM',
        ),
      ),
    );
  }
}
