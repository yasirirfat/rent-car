import 'package:flutter/material.dart';
import 'package:rent_car/car_data/car_data.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/core/app_state.dart';
import 'package:rent_car/screens/car_details_screen.dart';
import 'package:rent_car/widgets/car_card.dart';
import 'package:rent_car/widgets/painters/aurora_background.dart';
import 'package:rent_car/widgets/painters/glass_card.dart';

/// Saved (favourites) tab plus the recently viewed rail.
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final saved = state.favouritesFrom(carList);
    final recent = state.recentlyViewedFrom(carList);

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR GARAGE',
                        style: TextStyle(
                          color: AppColor.danger,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.4,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Saved Cars',
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
                ),
              ),

              // --- Recently viewed rail ---
              if (recent.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'RECENTLY VIEWED',
                            style: TextStyle(
                              color: AppColor.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 92,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: recent.length,
                            separatorBuilder: (a, b) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final car = recent[i];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CarDetailsScreen(car: car),
                                  ),
                                ),
                                child: GlassCard(
                                  radius: 16,
                                  padding: const EdgeInsets.all(10),
                                  accent: AppColor.secondary,
                                  glowStrength: 0.08,
                                  child: SizedBox(
                                    width: 128,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Image.asset(
                                              car.image,
                                              fit: BoxFit.contain,
                                              errorBuilder: (ctx, err, stack) =>
                                                  const Icon(
                                                Icons
                                                    .directions_car_filled_rounded,
                                                color: AppColor.textMuted,
                                                size: 26,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          car.model,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColor.textPrimary,
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
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
                      ],
                    ),
                  ),
                ),

              // --- Saved list ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                  child: Row(
                    children: [
                      const Text(
                        'SAVED',
                        style: TextStyle(
                          color: AppColor.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.danger.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          '${saved.length}',
                          style: const TextStyle(
                            color: AppColor.danger,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (saved.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptySaved(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverList.builder(
                    itemCount: saved.length,
                    itemBuilder: (context, index) {
                      final car = saved[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Dismissible(
                          key: ValueKey(car.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 22),
                            decoration: BoxDecoration(
                              color: AppColor.danger.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColor.danger,
                            ),
                          ),
                          onDismissed: (_) => state.toggleFavourite(car),
                          child: CarCard(
                            car: car,
                            accent: AppColor.accentFor(index),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CarDetailsScreen(car: car),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySaved extends StatelessWidget {
  const _EmptySaved();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AccentHalo(
              color: AppColor.danger,
              size: 150,
              opacity: 0.16,
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 46,
                color: AppColor.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Nothing saved yet',
              style: TextStyle(
                color: AppColor.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap the heart on any car to keep it here.',
              style: TextStyle(color: AppColor.textMuted, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}
