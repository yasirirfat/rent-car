import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/core/app_state.dart';
import 'package:rent_car/model/car_model.dart';
import 'package:rent_car/widgets/car_card_painter.dart';

class CarCard extends StatelessWidget {
  const CarCard({
    super.key,
    required this.car,
    required this.onTap,
    this.accent = AppColor.primary,
  });

  final CarModel car;
  final VoidCallback onTap;
  final Color accent;

  static const double imageBoxWidth = 240;
  static const double imageBoxHeight = 104;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final isFav = state.isFavourite(car);
    final isComparing = state.isComparing(car);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CarImageScope(
        path: car.image,
        child: CustomPaint(
          painter: CarCardPainter(accent: accent),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IdentityRow(
                  car: car,
                  accent: accent,
                  isFav: isFav,
                  onFavourite: () => state.toggleFavourite(car),
                ),
                const SizedBox(height: 12),
                const _ImageBox(),
                const SizedBox(height: 12),
                const _Hairline(),
                const SizedBox(height: 12),
                _ActionRow(
                  car: car,
                  accent: accent,
                  isComparing: isComparing,
                  onCompare: () => _handleCompare(context, state),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleCompare(BuildContext context, AppState state) {
    final ok = state.toggleCompare(car);
    if (!ok) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'You can compare up to ${AppState.maxCompare} cars at a time.',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({
    required this.car,
    required this.accent,
    required this.isFav,
    required this.onFavourite,
  });

  final CarModel car;
  final Color accent;
  final bool isFav;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _tint(accent),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(_iconFor(car), size: 22, color: accent),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      car.model,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColor.textPrimary,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.25,
                        height: 1.15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: AppColor.amber,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    car.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColor.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${car.drivetrain} · ${car.seatCount} Seats',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColor.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _FavButton(active: isFav, onTap: onFavourite),
      ],
    );
  }

  static Color _tint(Color accent) => accent.withValues(alpha: 0.10);

  static IconData _iconFor(CarModel car) {
    switch (car.category) {
      case CarCategory.suv:
        return Icons.airport_shuttle_rounded;
      case CarCategory.convertible:
        return Icons.wb_sunny_rounded;
      case CarCategory.hyper:
        return Icons.bolt_rounded;
      case CarCategory.all:
      case CarCategory.coupe:
        return Icons.sports_motorsports_rounded;
    }
  }
}

class _ImageBox extends StatelessWidget {
  const _ImageBox();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: CarCard.imageBoxWidth,
        height: CarCard.imageBoxHeight,
        child: const _CarImage(),
      ),
    );
  }
}

class _CarImage extends StatelessWidget {
  const _CarImage();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cacheWidth = (constraints.maxWidth * 3).round();

        return Image.asset(
          _carImagePathOf(context),
          fit: BoxFit.contain,
          alignment: Alignment.center,
          filterQuality: FilterQuality.medium,
          cacheWidth: cacheWidth,
          errorBuilder: (ctx, err, stack) => CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: CarSilhouettePainter(
              strokeOnly: true,
              opacity: 0.30,
              color: AppColor.textMuted,
              accent: AppColor.textMuted,
            ),
          ),
        );
      },
    );
  }

  static String _carImagePathOf(BuildContext context) {
    return CarImageScope.maybeOf(context)?.path ?? '';
  }
}

class CarImageScope extends InheritedWidget {
  const CarImageScope({super.key, required this.path, required super.child});

  final String path;

  static CarImageScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CarImageScope>();

  @override
  bool updateShouldNotify(CarImageScope oldWidget) => oldWidget.path != path;
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.car,
    required this.accent,
    required this.isComparing,
    required this.onCompare,
  });

  final CarModel car;
  final Color accent;
  final bool isComparing;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 360;

    return Row(
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 3),
              const Text(
                '/ day',
                style: TextStyle(
                  color: AppColor.textMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),

        CompareActionButton(
          active: isComparing,
          onTap: onCompare,
          accent: accent,
          compact: compact,
        ),
      ],
    );
  }
}

class CompareActionButton extends StatelessWidget {
  const CompareActionButton({
    super.key,
    required this.active,
    required this.onTap,
    this.accent = AppColor.primary,
    this.compact = false,
  });

  final bool active;
  final VoidCallback onTap;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16),
        decoration: BoxDecoration(
          color: active ? accent : AppColor.surface,
          borderRadius: BorderRadius.circular(AppColor.radiusControl),
          border: Border.all(
            color: active ? accent : AppColor.strokeStrong,
            width: 1.4,
          ),
          boxShadow: active
              ? AppColor.glow(accent, opacity: 0.30, blur: 12)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                active ? Icons.check_rounded : Icons.compare_arrows_rounded,
                key: ValueKey(active),
                size: 17,
                color: active ? Colors.white : accent,
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 7),
              Text(
                active ? 'Added' : 'Compare',
                style: TextStyle(
                  color: active ? Colors.white : accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                  height: 1.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColor.stroke);
  }
}

class _Pressable extends StatefulWidget {
  const _Pressable({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class CarGridCard extends StatelessWidget {
  const CarGridCard({
    super.key,
    required this.car,
    required this.onTap,
    this.accent = AppColor.primary,
  });

  final CarModel car;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final isFav = state.isFavourite(car);
    final isComparing = state.isComparing(car);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CarImageScope(
        path: car.image,
        child: CustomPaint(
          painter: CarCardPainter(accent: accent),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        car.model,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColor.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                      ),
                    ),
                    _FavButton(
                      active: isFav,
                      size: 32,
                      onTap: () => state.toggleFavourite(car),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${car.drivetrain} · ${car.seatCount} Seats',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColor.textMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: CarCard.imageBoxWidth,
                      height: CarCard.imageBoxHeight,
                      child: const _CarImage(),
                    ),
                  ),
                ),
                const _Hairline(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '\$${car.price.toStringAsFixed(0)} / day',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColor.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColor.amber,
                    ),
                    const SizedBox(width: 2),
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
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: CompareActionButton(
                    active: isComparing,
                    accent: accent,
                    onTap: () => state.toggleCompare(car),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavButton extends StatelessWidget {
  const _FavButton({required this.active, required this.onTap, this.size = 38});

  final bool active;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: active
              ? AppColor.danger.withValues(alpha: 0.10)
              : AppColor.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? AppColor.danger.withValues(alpha: 0.35)
                : AppColor.strokeStrong,
          ),
        ),
        child: Icon(
          active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: size * 0.48,
          color: active ? AppColor.danger : AppColor.textMuted,
        ),
      ),
    );
  }
}
