import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/model/tab_items.dart';

late List<TabItem> tabItems = [
  TabItem(
    Icons.home_rounded,
    'Home',
    AppColor.yellow, // Circle background
    circleStrokeColor: AppColor.darkGrey,
    labelStyle: const TextStyle(
      color: AppColor.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  TabItem(
    Icons.person_rounded,
    'Profile',
    AppColor.yellow,
    circleStrokeColor: AppColor.darkGrey,
    labelStyle: const TextStyle(
      color: AppColor.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  TabItem(
    Icons.calendar_month_rounded,
    'Bookings',
    AppColor.yellow,
    circleStrokeColor: AppColor.darkGrey,
    labelStyle: const TextStyle(
      color: AppColor.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  TabItem(
    Icons.settings,
    'Setting',
    AppColor.yellow,
    circleStrokeColor: AppColor.darkGrey,
    labelStyle: const TextStyle(
      color: AppColor.white,
      fontWeight: FontWeight.bold,
    ),
  ),
];
