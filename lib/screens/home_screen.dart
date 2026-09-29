import 'package:flutter/material.dart';
import 'package:rent_car/car_data/car_data.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/core/app_state.dart';
import 'package:rent_car/main.dart';
import 'package:rent_car/model/car_model.dart';
import 'package:rent_car/screens/car_details_screen.dart';
import 'package:rent_car/screens/compare_screen.dart';
import 'package:rent_car/widgets/car_card.dart';
import 'package:rent_car/widgets/chips.dart';
import 'package:rent_car/widgets/entrance_fade.dart';
import 'package:rent_car/widgets/header.dart';
import 'package:rent_car/widgets/painters/aurora_background.dart';
import 'package:rent_car/widgets/painters/glass_card.dart';
import 'package:rent_car/widgets/painters/hero_banner_painter.dart';
import 'package:rent_car/widgets/search_bar.dart';

/// Sort modes available from the home screen toolbar.
enum SortMode {
  recommended('Recommended'),
  priceLow('Price: Low to High'),
  priceHigh('Price: High to Low'),
  topSpeed('Top Speed'),
  rating('Top Rated');

  const SortMode(this.label);
  final String label;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  CarCategory _category = CarCategory.all;
  SortMode _sortMode = SortMode.recommended;
  bool _gridView = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Applies search, category filter and the active sort.
  List<CarModel> get _visibleCars {
    final query = _searchQuery.trim().toLowerCase();

    var cars = carList.where((car) {
      final matchesCategory =
          _category == CarCategory.all || car.category == _category;
      if (!matchesCategory) return false;
      if (query.isEmpty) return true;
      return car.model.toLowerCase().contains(query) ||
          car.company.toLowerCase().contains(query) ||
          car.category.label.toLowerCase().contains(query);
    }).toList();

    switch (_sortMode) {
      case SortMode.recommended:
        cars.sort((a, b) => b.rating.compareTo(a.rating));
      case SortMode.priceLow:
        cars.sort((a, b) => a.price.compareTo(b.price));
      case SortMode.priceHigh:
        cars.sort((a, b) => b.price.compareTo(a.price));
      case SortMode.topSpeed:
        cars.sort((a, b) => b.topSpeedKmh.compareTo(a.topSpeedKmh));
      case SortMode.rating:
        cars.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return cars;
  }

  /// The single highest rated car, promoted into the hero banner.
  CarModel get _featuredCar {
    final sorted = [...carList]..sort((a, b) {
      final byScore = b.performanceScore.compareTo(a.performanceScore);
      return byScore != 0 ? byScore : b.rating.compareTo(a.rating);
    });
    return sorted.first;
  }

  void _openDetails(CarModel car) {
    AppState.of(context).markViewed(car);
    Navigator.push(
      context,
      PageRouteBuilder(
        // A short fade-through, which reads as the car taking over the screen
        // without the heavy platform push that a MaterialPageRoute gives.
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) => CarDetailsScreen(car: car),
        transitionsBuilder: (context, animation, secondary, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.035),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Future<void> _showSortSheet() async {
    final picked = await showModalBottomSheet<SortMode>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(current: _sortMode),
    );
    if (picked != null && mounted) {
      setState(() => _sortMode = picked);
    }
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _category = CarCategory.all;
      _sortMode = SortMode.recommended;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final cars = _visibleCars;
    final hasFilters =
        _searchQuery.isNotEmpty || _category != CarCategory.all;

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
              // --- Header ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Header(
                    onNotificationTap: () =>
                        MainWrapper.goToTab(MainWrapper.bookingsTab),
                  ),
                ),
              ),

              // --- Hero spotlight ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: _HeroSpotlight(
                    car: _featuredCar,
                    onTap: () => _openDetails(_featuredCar),
                  ),
                ),
              ),

              // --- Quick stats ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          icon: Icons.directions_car_filled_rounded,
                          value: '${carList.length}',
                          label: 'In Fleet',
                          accent: AppColor.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniStat(
                          icon: Icons.favorite_rounded,
                          value: '${state.favouriteCount}',
                          label: 'Saved',
                          accent: AppColor.danger,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MiniStat(
                          icon: Icons.bolt_rounded,
                          value: '${cars.length}',
                          label: 'Showing',
                          accent: AppColor.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Search ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: SearchBars(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
              ),

              // --- Category chips (now wired to filtering) ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: CategoryChips(
                    selected: _category,
                    onSelected: (category) =>
                        setState(() => _category = category),
                  ),
                ),
              ),

              // --- Toolbar: count, sort, layout ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _category == CarCategory.all
                                ? 'The Collection'
                                : _category.label,
                            style: const TextStyle(
                              color: AppColor.textPrimary,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${cars.length} car${cars.length == 1 ? '' : 's'} available',
                            style: const TextStyle(
                              color: AppColor.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (hasFilters)
                        _IconChip(
                          icon: Icons.filter_alt_off_rounded,
                          onTap: _resetFilters,
                          tooltip: 'Clear filters',
                        ),
                      const SizedBox(width: 8),
                      _IconChip(
                        icon: _gridView
                            ? Icons.view_agenda_rounded
                            : Icons.grid_view_rounded,
                        onTap: () => setState(() => _gridView = !_gridView),
                        tooltip: 'Change layout',
                      ),
                      const SizedBox(width: 8),
                      _IconChip(
                        icon: Icons.swap_vert_rounded,
                        onTap: _showSortSheet,
                        tooltip: 'Sort',
                        active: _sortMode != SortMode.recommended,
                      ),
                    ],
                  ),
                ),
              ),

              // --- Results ---
              if (cars.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyResults(),
                )
              else if (_gridView)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.32,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final car = cars[index];
                      return EntranceFade(
                        order: index,
                        child: CarGridCard(
                          car: car,
                          onTap: () => _openDetails(car),
                          accent: AppColor.accentFor(index),
                        ),
                      );
                    }, childCount: cars.length),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
                  sliver: SliverList.builder(
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      return EntranceFade(
                        order: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: CarCard(
                            car: car,
                            accent: AppColor.accentFor(index),
                            onTap: () => _openDetails(car),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ],
              ),

              // --- Floating compare bar ---
              if (state.compareCount > 0)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 96,
                  child: _CompareBar(
                    count: state.compareCount,
                    onOpen: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CompareScreen(),
                      ),
                    ),
                    onClear: state.clearCompare,
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
// Compare bar
// -----------------------------------------------------------------------------

/// Floating action bar shown once at least one car is queued for comparison.
class _CompareBar extends StatelessWidget {
  const _CompareBar({
    required this.count,
    required this.onOpen,
    required this.onClear,
  });

  final int count;
  final VoidCallback onOpen;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final canCompare = count >= 2;

    return GlassCard(
      radius: 18,
      accent: AppColor.secondary,
      glowStrength: 0.22,
      padding: const EdgeInsets.fromLTRB(14, 11, 11, 11),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.compare_arrows_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count car${count == 1 ? '' : 's'} selected',
                  style: const TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  canCompare
                      ? 'Ready to compare'
                      : 'Add one more to compare',
                  style: const TextStyle(
                    color: AppColor.textMuted,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Icon(
                Icons.close_rounded,
                size: 17,
                color: AppColor.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: canCompare ? onOpen : null,
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: canCompare ? AppColor.primary : AppColor.surfaceHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: canCompare ? AppColor.primary : AppColor.stroke,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.compare_arrows_rounded,
                    size: 15,
                    color: canCompare
                        ? Colors.white
                        : AppColor.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Compare',
                    style: TextStyle(
                      color: canCompare
                          ? Colors.white
                          : AppColor.textMuted,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
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
// Hero spotlight
// -----------------------------------------------------------------------------

/// Large promotional banner for the highest performance car in the fleet.
class _HeroSpotlight extends StatelessWidget {
  const _HeroSpotlight({required this.car, required this.onTap});

  final CarModel car;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppColor.radiusPanel),
        child: CustomPaint(
          painter: HeroBannerPainter(fill: AppColor.surface),
          child: SizedBox(
            height: 164,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Text column: a bounded box, so nothing can spill ------
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'FEATURED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Flexible(
                          child: Text(
                            car.model,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColor.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: AppColor.amber,
                              size: 15,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              car.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColor.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Price - now inside the text column, so it can never
                        // sit underneath the car image.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Flexible(
                              child: Text(
                                '\$${car.price.toStringAsFixed(0)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColor.textPrimary,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '/ day',
                              style: TextStyle(
                                color: AppColor.textMuted,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // --- Image column: its own bounded box, centred ------------
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, c) => Image.asset(
                          car.image,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          filterQuality: FilterQuality.medium,
                          // Decode at the size we paint at (3x for crispness on
                          // high-DPI). The hero is the first thing on screen,
                          // so decoding a full-resolution PNG here shows up as
                          // a visible hitch on load.
                          cacheWidth: (c.maxWidth * 3).round(),
                          errorBuilder: (ctx, err, stack) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Small building blocks
// -----------------------------------------------------------------------------

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      radius: 18,
      accent: accent,
      glowStrength: 0.10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 17),
          const SizedBox(height: 9),
          Text(
            value,
            style: const TextStyle(
              color: AppColor.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: AppColor.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: active
                ? AppColor.accentVeil(AppColor.primary)
                : AppColor.surfaceVeilStrong,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: active
                  ? AppColor.primary.withValues(alpha: 0.6)
                  : AppColor.stroke,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: active ? AppColor.secondary : AppColor.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: AccentHalo(
          color: AppColor.primary,
          size: 180,
          opacity: 0.16,
          child: const Icon(
            Icons.search_off_rounded,
            size: 54,
            color: AppColor.textSecondary,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Sort sheet
// -----------------------------------------------------------------------------

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.current});

  final SortMode current;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sort by',
            style: TextStyle(
              color: AppColor.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...SortMode.values.map((mode) {
            final selected = mode == current;
            return GestureDetector(
              onTap: () => Navigator.pop(context, mode),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColor.accentVeil(AppColor.primary, alpha: 0.14)
                      : AppColor.surfaceVeil,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: selected
                        ? AppColor.primary.withValues(alpha: 0.55)
                        : AppColor.stroke,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 19,
                      color: selected
                          ? AppColor.secondary
                          : AppColor.textMuted,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      mode.label,
                      style: TextStyle(
                        color: selected
                            ? AppColor.textPrimary
                            : AppColor.textSecondary,
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
