import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/model/car_model.dart';

/// Horizontal category filter chips.
///
/// Unlike a purely decorative row, this calls back into the parent so the car
/// list actually filters. The selected chip is a **solid** blue fill with white
/// text - one flat colour, per the no-gradient rule - and an unselected chip is
/// a white pill with a visible outline.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final CarCategory selected;
  final ValueChanged<CarCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: CarCategory.values.length,
        separatorBuilder: (a, b) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final category = CarCategory.values[index];
          final isSelected = category == selected;

          return GestureDetector(
            onTap: () => onSelected(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColor.primary : AppColor.surface,
                borderRadius: BorderRadius.circular(AppColor.radiusChip + 3),
                border: Border.all(
                  color: isSelected ? AppColor.primary : AppColor.strokeStrong,
                  width: 1.2,
                ),
                boxShadow: isSelected
                    ? AppColor.glow(AppColor.primary, opacity: 0.26, blur: 10)
                    : null,
              ),
              child: Row(
                children: [
                  if (isSelected) ...[
                    const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    category.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColor.textSecondary,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
