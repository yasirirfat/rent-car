import 'package:flutter/material.dart';
import 'package:rent_car/car_data/car_data.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/core/app_state.dart';
import 'package:rent_car/screens/account_screens.dart';
import 'package:rent_car/screens/car_details_screen.dart';
import 'package:rent_car/widgets/painters/aurora_background.dart';
import 'package:rent_car/widgets/painters/glass_card.dart';
import 'package:rent_car/widgets/painters/progress_ring.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final profile = state.profile;
    final saved = state.favouritesFrom(carList);
    final recent = state.recentlyViewedFrom(carList);

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
            children: [
              GlassCard(
                radius: AppColor.radiusPanel,
                accent: AppColor.primary,
                glowStrength: 0.10,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColor.brandGradient,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.surface,
                        ),
                        child: CircleAvatar(
                          radius: 33,
                          backgroundColor: AppColor.surfaceHigh,
                          backgroundImage: const AssetImage(
                            'assets/images/yasir.png',
                          ),
                          onBackgroundImageError: (_, _) {},
                          child: null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  profile.name.split(' ').first,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColor.textPrimary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppColor.amberGradient,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: AppColor.secondary,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${profile.city}, Pakistan',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColor.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 9),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.success.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: AppColor.success,
                                  size: 11,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Verified renter',
                                  style: TextStyle(
                                    color: AppColor.success,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      radius: 18,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: _StatBlock(
                        value: '${state.totalRides}',
                        label: 'Total rides',
                        accent: AppColor.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      radius: 18,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: _StatBlock(
                        value: '\$${state.totalSpend.toStringAsFixed(0)}',
                        label: 'Lifetime spend',
                        accent: AppColor.amber,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassCard(
                      radius: 18,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: _StatBlock(
                        value: '${saved.length}',
                        label: 'Saved cars',
                        accent: AppColor.danger,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              GlassCard(
                radius: AppColor.radiusPanel,
                accent: AppColor.secondary,
                glowStrength: 0.08,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    ProgressRing(
                      value: (state.totalRides / 10).clamp(0.0, 1.0),
                      size: 84,
                      strokeWidth: 6,
                      gradientColors: const [
                        AppColor.secondary,
                        AppColor.primary,
                        AppColor.amber,
                      ],
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(state.totalRides * 10).clamp(0, 100)}%',
                            style: const TextStyle(
                              color: AppColor.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'GARAGE LEVEL',
                            style: TextStyle(
                              color: AppColor.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _levelName(state.totalRides),
                            style: const TextStyle(
                              color: AppColor.textPrimary,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.totalRides >= 10
                                ? 'You have unlocked every tier. Legend.'
                                : '${10 - state.totalRides} more ride(s) to '
                                      'reach the next tier.',
                            style: const TextStyle(
                              color: AppColor.textSecondary,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              if (recent.isNotEmpty) ...[
                const _SectionLabel('RECENTLY VIEWED'),
                const SizedBox(height: 12),
                SizedBox(
                  height: 108,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: recent.length,
                    separatorBuilder: (a, b) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final car = recent[i];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CarDetailsScreen(car: car),
                          ),
                        ),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 118,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColor.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColor.stroke),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.asset(
                                  car.image,
                                  fit: BoxFit.contain,
                                  errorBuilder: (ctx, err, stack) => const Icon(
                                    Icons.directions_car_filled_rounded,
                                    color: AppColor.textMuted,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                car.model,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColor.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 26),
              ],

              const _SectionLabel('ACCOUNT'),
              const SizedBox(height: 12),
              _OptionTile(
                icon: Icons.person_outline_rounded,
                title: 'Personal information',
                subtitle: profile.email,
                accent: AppColor.primary,
                onTap: () => _push(context, const PersonalInfoScreen()),
              ),
              _OptionTile(
                icon: Icons.payment_outlined,
                title: 'Payment methods',
                subtitle: _paymentSubtitle(state),
                accent: AppColor.secondary,
                onTap: () => _push(context, const PaymentMethodsScreen()),
              ),
              _OptionTile(
                icon: Icons.history_rounded,
                title: 'Rental history',
                subtitle: '${state.totalRides} completed booking(s)',
                accent: AppColor.amber,
                onTap: () => _push(context, const RentalHistoryScreen()),
              ),
              _OptionTile(
                icon: Icons.drive_eta_rounded,
                title: 'Driving licence',
                subtitle: _licenceSubtitle(profile.licenceExpiry),
                accent: AppColor.success,
                onTap: () => _push(context, const DrivingLicenceScreen()),
              ),
              _OptionTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & support',
                subtitle: 'FAQ, live chat and contact',
                accent: AppColor.info,
                onTap: () => _push(context, const HelpSupportScreen()),
              ),

              const SizedBox(height: 22),

              GestureDetector(
                onTap: () => _confirmLogout(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColor.danger.withValues(alpha: 0.5),
                    ),
                    color: AppColor.danger.withValues(alpha: 0.07),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: AppColor.danger,
                        size: 18,
                      ),
                      SizedBox(width: 9),
                      Text(
                        'Log out',
                        style: TextStyle(
                          color: AppColor.danger,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  static String _paymentSubtitle(AppState state) {
    final methods = state.paymentMethods;
    if (methods.isEmpty) return 'No cards saved';
    if (methods.length == 1) return methods.first.display;
    return '${methods.first.display} and ${methods.length - 1} more';
  }

  static String _licenceSubtitle(DateTime? expiry) {
    if (expiry == null) return 'Verified · tap to review';
    return 'Verified until ${expiry.year}';
  }

  static String _levelName(int rides) {
    if (rides >= 10) return 'Elite Collector';
    if (rides >= 6) return 'Track Veteran';
    if (rides >= 3) return 'Road Enthusiast';
    if (rides >= 1) return 'First Timer';
    return 'Newcomer';
  }

  static void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: AppColor.scrim.withValues(alpha: 0.85),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColor.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColor.stroke),
        ),
        title: const Text(
          'Log out?',
          style: TextStyle(
            color: AppColor.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'This clears your saved cars, bookings and recently viewed list on '
          'this device.',
          style: TextStyle(
            color: AppColor.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Stay signed in',
              style: TextStyle(color: AppColor.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              AppState.of(context).signOut();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Signed out. Local data cleared.'),
                    duration: Duration(seconds: 2),
                  ),
                );
            },
            child: const Text(
              'Log out',
              style: TextStyle(
                color: AppColor.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.value,
    required this.label,
    required this.accent,
  });

  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: accent,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            height: 1.0,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColor.textMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            gradient: AppColor.brandGradient,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppColor.textSecondary,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          radius: 18,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 19),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColor.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColor.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColor.textMuted,
                size: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
