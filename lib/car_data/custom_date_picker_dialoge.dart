import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

class CustomDatePicker {
  // Static function jisko aap kahin se bhi call kar sakte hain
  static void openRangePicker({
    required BuildContext context,
    required DateTimeRange? initialDateRange,
    required Function(DateTimeRange) onDatesSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColor.white, // Pure Crisp White Background
          elevation: 24,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: AppColor.black.withValues(alpha: 0.05), // Soft subtle boundary ring
              width: 1,
            ),
          ),
          child: Theme(
            data: ThemeData.light().copyWith(
              scaffoldBackgroundColor: AppColor.white,
              dividerColor: Colors.transparent,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

              // --- TEXT THEME OVERRIDE ---
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: AppColor.black),
                bodyLarge: TextStyle(color: AppColor.black),
              ),

              // --- LIGHT HIGH-CONTRAST COLOR SCHEME ---
              colorScheme: const ColorScheme.light(
                primary: AppColor.black, 
                onPrimary: AppColor.white, 
                surface: AppColor.white, 
                onSurface: AppColor.black, 
                onSurfaceVariant: AppColor.black, 
                secondary: AppColor.black,
              ),

              // --- INTERACTIVE ACTION BUTTONS ---
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColor.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ),

              // --- CALENDAR RANGE OVERLAYS ---
              datePickerTheme: DatePickerThemeData(
                headerBackgroundColor: AppColor.white,
                headerForegroundColor: AppColor.black,
                backgroundColor: AppColor.white,
                
                dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) {
                    return AppColor.black.withValues(alpha: 0.25);
                  }
                  if (states.contains(WidgetState.selected)) {
                    return AppColor.white; 
                  }
                  return AppColor.black; 
                }),

                rangeSelectionBackgroundColor: AppColor.black.withValues(alpha: 0.12),
                
                dayStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                yearStyle: const TextStyle(color: AppColor.black),
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 330,
                maxHeight: 460,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 6),
                    Container(
                      width: 30,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColor.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "SELECT DATES",
                      style: TextStyle(
                        color: AppColor.black,
                        fontSize: 12, 
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),

                    // Main clean date picker viewport
                    Expanded(
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler: TextScaler.noScaling,
                        ),
                        child: DateRangePickerDialog(
                          firstDate: DateTime(2026),
                          lastDate: DateTime(2030),
                          initialDateRange: initialDateRange,
                          confirmText: "CONFIRM",
                          cancelText: "DISMISS",
                        ),
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
        // Callback function ko data wapas bhejna
        onDatesSelected(pickedValue);
      }
    });
  }
}