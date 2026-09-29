import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/core/app_state.dart';
import 'package:rent_car/widgets/painters/aurora_background.dart';
import 'package:rent_car/widgets/painters/glass_card.dart';
import 'package:rent_car/widgets/painters/progress_ring.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  double _storageUsedMb = 128;
  static const double _storageTotalMb = 400;

  bool _checking = false;
  String _lastChecked = 'Up to date';

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final usedFraction = (_storageUsedMb / _storageTotalMb).clamp(0.0, 1.0);

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
            children: [
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CONTROL PANEL',
                        style: TextStyle(
                          color: AppColor.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.2,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Settings',
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
                  const Spacer(),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColor.surfaceHigh,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColor.stroke),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: AppColor.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const _GroupLabel('PREFERENCES'),
              const SizedBox(height: 12),
              GlassCard(
                radius: 20,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: Column(
                  children: [
                    _SwitchRow(
                      icon: Icons.notifications_active_rounded,
                      title: 'Push notifications',
                      subtitle: 'Booking updates and reminders',
                      value: state.pushNotifications,
                      accent: AppColor.primary,
                      onChanged: state.setPushNotifications,
                    ),
                    const _RowDivider(),
                    _SwitchRow(
                      icon: Icons.local_offer_rounded,
                      title: 'Promotional offers',
                      subtitle: 'Occasional deals on premium cars',
                      value: state.promoEmails,
                      accent: AppColor.amber,
                      onChanged: state.setPromoEmails,
                    ),
                    const _RowDivider(),
                    _ChoiceRow(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      subtitle: 'App display language',
                      value: state.language,
                      accent: AppColor.secondary,
                      onChanged: state.setLanguage,
                      options: const ['English', 'Urdu', 'Arabic'],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              const _GroupLabel('DISCOVERY'),
              const SizedBox(height: 12),
              GlassCard(
                radius: 20,
                accent: AppColor.secondary,
                glowStrength: 0.06,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColor.secondary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(
                            Icons.radar_rounded,
                            color: AppColor.secondary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 13),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pickup radius',
                                style: TextStyle(
                                  color: AppColor.textPrimary,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'How far to search for available cars',
                                style: TextStyle(
                                  color: AppColor.textMuted,
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${state.searchRadius.round()} km',
                          style: const TextStyle(
                            color: AppColor.secondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColor.secondary,
                        inactiveTrackColor: AppColor.textPrimary.withValues(
                          alpha: 0.08,
                        ),
                        thumbColor: AppColor.textPrimary,
                        overlayColor: AppColor.secondary.withValues(
                          alpha: 0.16,
                        ),
                        trackHeight: 4,
                      ),
                      child: Slider(
                        value: state.searchRadius,
                        min: 5,
                        max: 200,
                        onChanged: state.setSearchRadius,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              const _GroupLabel('SECURITY & PRIVACY'),
              const SizedBox(height: 12),
              GlassCard(
                radius: 20,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: Column(
                  children: [
                    _SwitchRow(
                      icon: Icons.fingerprint_rounded,
                      title: 'Biometric login',
                      subtitle: 'Use fingerprint or face to sign in',
                      value: state.biometricLogin,
                      accent: AppColor.success,
                      onChanged: state.setBiometricLogin,
                    ),
                    const _RowDivider(),
                    _SwitchRow(
                      icon: Icons.location_on_rounded,
                      title: 'Location access',
                      subtitle: 'Needed to show nearby cars',
                      value: state.locationAccess,
                      accent: AppColor.danger,
                      onChanged: state.setLocationAccess,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              const _GroupLabel('SYSTEM'),
              const SizedBox(height: 12),
              GlassCard(
                radius: 20,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: Column(
                  children: [
                    _ActionRow(
                      icon: Icons.cleaning_services_rounded,
                      title: 'Clear app cache',
                      trailingText: _storageUsedMb == 0
                          ? 'Empty'
                          : '${_storageUsedMb.round()} MB',
                      accent: AppColor.textSecondary,
                      onTap: _clearCache,
                    ),
                    const _RowDivider(),
                    _ActionRow(
                      icon: Icons.cloud_done_rounded,
                      title: 'Server status',
                      trailingText: 'Operational',
                      accent: AppColor.success,
                      onTap: () => _showInfo(
                        'All services operational',
                        'Booking, catalogue and payment services are responding '
                            'normally. Last incident: none in the past 90 days.',
                        AppColor.success,
                      ),
                    ),
                    const _RowDivider(),
                    _ActionRow(
                      icon: Icons.system_update_rounded,
                      title: 'Check for updates',
                      trailingText: _checking ? 'Checking…' : _lastChecked,
                      accent: AppColor.primary,
                      onTap: _checking ? null : _checkForUpdates,
                    ),
                    const _RowDivider(),
                    _ActionRow(
                      icon: Icons.restart_alt_rounded,
                      title: 'Reset preferences',
                      trailingText: 'Defaults',
                      accent: AppColor.danger,
                      onTap: _confirmResetPreferences,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              const _GroupLabel('USAGE'),
              const SizedBox(height: 12),
              GlassCard(
                radius: 20,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    ProgressRing(
                      value: usedFraction,
                      size: 78,
                      strokeWidth: 6,
                      gradientColors: const [AppColor.amber, AppColor.danger],
                      child: Text(
                        '${(usedFraction * 100).round()}%',
                        style: const TextStyle(
                          color: AppColor.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Storage used',
                            style: TextStyle(
                              color: AppColor.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${_storageUsedMb.round()} MB of '
                            '${_storageTotalMb.round()} MB used by cached '
                            'car imagery.',
                            style: const TextStyle(
                              color: AppColor.textMuted,
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

              const SizedBox(height: 30),

              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/flogo.png',
                      height: 34,
                      errorBuilder: (ctx, err, stack) => const Icon(
                        Icons.directions_car_filled_rounded,
                        color: AppColor.amber,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'RentCar Premium',
                      style: TextStyle(
                        color: AppColor.textSecondary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Version 2.0.16  •  Stable build',
                      style: TextStyle(
                        color: AppColor.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearCache() {
    if (_storageUsedMb == 0) {
      _snack('There is nothing cached right now.');
      return;
    }
    final freed = _storageUsedMb;
    setState(() => _storageUsedMb = 0);

    AppState.of(context).clearRecentlyViewed();
    _snack('Cleared ${freed.round()} MB of cached imagery.');
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _checking = true;
      _lastChecked = 'Checking…';
    });
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() {
      _checking = false;
      _lastChecked = 'Up to date';
    });
    _showInfo(
      'You are up to date',
      'RentCar Premium 2.0.16 is the latest stable build for this device.',
      AppColor.primary,
    );
  }

  void _confirmResetPreferences() {
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
          'Reset preferences?',
          style: TextStyle(
            color: AppColor.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Every setting on this screen returns to its default value. Your '
          'bookings, favourites and profile are not affected.',
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
              'Cancel',
              style: TextStyle(color: AppColor.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              AppState.of(context).resetPreferences();
              setState(() => _storageUsedMb = 128);
              Navigator.pop(dialogContext);
              _snack('Preferences restored to defaults.');
            },
            child: const Text(
              'Reset',
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

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  void _showInfo(String title, String body, Color accent) {
    showDialog<void>(
      context: context,
      barrierColor: AppColor.scrim.withValues(alpha: 0.85),
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColor.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: accent.withValues(alpha: 0.35)),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: accent, size: 20),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColor.textPrimary,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          body,
          style: const TextStyle(
            color: AppColor.textSecondary,
            fontSize: 13,
            height: 1.55,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Got it',
              style: TextStyle(
                color: AppColor.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 12,
            decoration: BoxDecoration(
              gradient: AppColor.brandGradient,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColor.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        height: 1,
        color: AppColor.stroke.withValues(alpha: 0.5),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.accent,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Color accent;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 13),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColor.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColor.scrim,
            activeTrackColor: accent,
            inactiveThumbColor: AppColor.textMuted,
            inactiveTrackColor: AppColor.surfaceHigh,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.accent,
    required this.onChanged,
    required this.options,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final Color accent;
  final ValueChanged<String> onChanged;
  final List<String> options;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 13),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColor.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            initialValue: value,
            onSelected: onChanged,
            color: AppColor.surfaceHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            itemBuilder: (context) => options
                .map(
                  (o) => PopupMenuItem<String>(
                    value: o,
                    child: Text(
                      o,
                      style: TextStyle(
                        color: o == value ? accent : AppColor.textPrimary,
                        fontWeight: o == value
                            ? FontWeight.w800
                            : FontWeight.w500,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                )
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: accent,
                    size: 16,
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.trailingText,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String trailingText;
  final Color accent;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: onTap == null
                  ? AppColor.textMuted
                  : AppColor.textSecondary,
              size: 19,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: onTap == null
                      ? AppColor.textMuted
                      : AppColor.textPrimary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
            Text(
              trailingText,
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColor.textMuted,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}
