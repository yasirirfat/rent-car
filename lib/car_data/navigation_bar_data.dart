import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/model/tab_items.dart';

/// Navigation tabs in display order. Colours cycle through the brand accents so
/// the raised handle changes hue as you move across the bar.
List<TabItem> tabItems = [
  TabItem(
    Icons.home_rounded,
    'Home',
    AppColor.primary,
    circleStrokeColor: AppColor.primary,
    labelStyle: const TextStyle(
      color: AppColor.textPrimary,
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
    ),
  ),
  TabItem(
    Icons.favorite_rounded,
    'Saved',
    AppColor.danger,
    circleStrokeColor: AppColor.danger,
    labelStyle: const TextStyle(
      color: AppColor.textPrimary,
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
    ),
  ),
  TabItem(
    Icons.calendar_month_rounded,
    'Bookings',
    AppColor.secondary,
    circleStrokeColor: AppColor.secondary,
    labelStyle: const TextStyle(
      color: AppColor.textPrimary,
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
    ),
  ),
  TabItem(
    Icons.person_rounded,
    'Profile',
    AppColor.amber,
    circleStrokeColor: AppColor.amber,
    labelStyle: const TextStyle(
      color: AppColor.textPrimary,
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
    ),
  ),
  TabItem(
    Icons.settings_rounded,
    'Settings',
    AppColor.primary,
    circleStrokeColor: AppColor.primary,
    labelStyle: const TextStyle(
      color: AppColor.textPrimary,
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
    ),
  ),
];
