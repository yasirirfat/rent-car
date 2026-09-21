import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart'; 
import 'package:rent_car/car_data/navigation_bar_data.dart'; 
import 'package:rent_car/widgets/circular_bottom_navigation.dart';

// Screens
import 'package:rent_car/screens/intro_screen.dart'; // IntroScreen import krein
import 'package:rent_car/screens/home_screen.dart';
import 'package:rent_car/screens/booking_screen.dart';
import 'package:rent_car/screens/profile.dart';
import 'package:rent_car/screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rent Car',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColor.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColor.yellow,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // Pehly Intro Screen open hogi
      home: const IntroScreen(), 
    );
  }
}

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int selectedTab = 0;
  late CircularBottomNavigationController _navigationController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProfileScreen(), 
    const BookingsScreen(),
    const SettingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _navigationController = CircularBottomNavigationController(selectedTab);
  }

  @override
  void dispose() {
    _navigationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.black,
      body: IndexedStack(index: selectedTab, children: _screens),
      bottomNavigationBar: CircularBottomNavigation(
        tabItems,
        controller: _navigationController,
        barHeight: 65,
        circleSize: 54,
        iconsSize: 28,
        selectedIconColor: AppColor.black,
        normalIconColor: AppColor.white.withValues(alpha: 0.6),
        barBackgroundColor: AppColor.darkGrey,
        selectedCallback: (int? selectedPos) {
          setState(() {
            selectedTab = selectedPos ?? 0;
          });
        },
      ),
    );
  }
}
