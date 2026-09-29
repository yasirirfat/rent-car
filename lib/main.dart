import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rent_car/car_data/navigation_bar_data.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/core/app_state.dart';
import 'package:rent_car/screens/bookings_screen.dart';
import 'package:rent_car/screens/home_screen.dart';
import 'package:rent_car/screens/intro_screen.dart';
import 'package:rent_car/screens/profile_screen.dart';
import 'package:rent_car/screens/saved_screen.dart';
import 'package:rent_car/screens/settings_screen.dart';
import 'package:rent_car/widgets/circular_bottom_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // Light page, so the status bar glyphs must be dark.
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColor.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const RentCarApp());
}

class RentCarApp extends StatefulWidget {
  const RentCarApp({super.key});

  @override
  State<RentCarApp> createState() => _RentCarAppState();
}

class _RentCarAppState extends State<RentCarApp> {
  final AppState _appState = AppState();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        title: 'Rent Car',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const IntroScreen(),
        scrollBehavior: const _NoGlowScrollBehavior(),
      ),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColor.canvas,
      colorScheme: const ColorScheme.light(
        primary: AppColor.primary,
        secondary: AppColor.secondary,
        tertiary: AppColor.amber,
        surface: AppColor.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColor.textPrimary,
        error: AppColor.danger,
      ),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColor.textPrimary,
        displayColor: AppColor.textPrimary,
      ),
      dividerTheme: DividerThemeData(
        color: AppColor.stroke,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColor.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColor.surface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColor.textPrimary,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

/// Container that owns the bottom navigation and swaps between screens.
///
/// The active tab is mirrored into a [ValueNotifier] so pushed routes (the car
/// details screen) can jump the user to another tab — for example straight to
/// Bookings after a successful reservation.
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key, this.initialTab = 0});

  final int initialTab;

  /// Tab indices, kept as named constants so callers do not hardcode numbers.
  static const int homeTab = 0;
  static const int savedTab = 1;
  static const int bookingsTab = 2;
  static const int profileTab = 3;
  static const int settingsTab = 4;

  /// Lets any descendant request a tab change. Registered by the active
  /// [MainWrapper]; null when no tab container is mounted.
  static final ValueNotifier<int?> requestedTab = ValueNotifier<int?>(null);

  /// Switches the enclosing [MainWrapper] to [index].
  static void goToTab(int index) {
    requestedTab.value = index;
  }

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late int selectedTab;
  late CircularBottomNavigationController _navigationController;

  final List<Widget> _screens = const [
    HomeScreen(),
    SavedScreen(),
    BookingsScreen(),
    ProfileScreen(),
    SettingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    selectedTab = widget.initialTab.clamp(0, _screens.length - 1);
    _navigationController = CircularBottomNavigationController(selectedTab);
    MainWrapper.requestedTab.addListener(_onTabRequested);
  }

  void _onTabRequested() {
    final requested = MainWrapper.requestedTab.value;
    if (requested == null || !mounted) return;
    if (requested >= 0 && requested < _screens.length) {
      setState(() => selectedTab = requested);
      _navigationController.value = requested;
    }
    MainWrapper.requestedTab.value = null;
  }

  @override
  void dispose() {
    MainWrapper.requestedTab.removeListener(_onTabRequested);
    _navigationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.canvas,
      extendBody: true,
      body: IndexedStack(index: selectedTab, children: _screens),
      bottomNavigationBar: CircularBottomNavigation(
        tabItems,
        controller: _navigationController,
        barHeight: 62,
        circleSize: 54,
        iconsSize: 24,
        selectedIconColor: Colors.white,
        normalIconColor: AppColor.textMuted,
        barBackgroundColor: AppColor.surface,
        backgroundBoxShadow: const [
          BoxShadow(color: Color(0x1A101828), blurRadius: 18),
        ],
        selectedCallback: (int? selectedPos) {
          setState(() {
            selectedTab = selectedPos ?? 0;
          });
        },
      ),
    );
  }
}

/// Removes the default overscroll glow to keep the dark UI clean.
class _NoGlowScrollBehavior extends MaterialScrollBehavior {
  const _NoGlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
