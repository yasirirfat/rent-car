import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/core/app_state.dart';

class Header extends StatelessWidget {
  const Header({super.key, this.onNotificationTap});

  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);

    final alerts = state.activeCount;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColor.brandGradient,
          ),
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.canvas,
            ),
            child: ClipOval(
              child: SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: AppColor.surfaceHigh,
                      alignment: Alignment.center,
                      child: Text(
                        state.profile.initials,
                        style: const TextStyle(
                          color: AppColor.secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/yasir.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good to see you',
                style: TextStyle(
                  color: AppColor.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Text(
                    'Yasir',
                    style: TextStyle(
                      color: AppColor.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.amber.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: AppColor.amber,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppColor.secondary,
                    size: 12,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Bahawalpur',
                    style: TextStyle(
                      color: AppColor.textMuted,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColor.textMuted,
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: onNotificationTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppColor.surfaceHigh,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColor.stroke),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColor.textPrimary,
                  size: 21,
                ),
              ),
              if (alerts > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColor.amberGradient,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColor.scrim, width: 1.5),
                    ),
                    child: Text(
                      '$alerts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
