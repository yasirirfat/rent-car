import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/core/app_state.dart';
import 'package:rent_car/screens/car_details_screen.dart';
import 'package:rent_car/widgets/painters/glass_card.dart';

// =============================================================================
// Shared chrome
// =============================================================================

/// Standard scaffold used by every account sub-screen so they share one
/// header treatment and one background.
class AccountScaffold extends StatelessWidget {
  const AccountScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.accent = AppColor.primary,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColor.surfaceHigh,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColor.stroke),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColor.textPrimary,
                        size: 19,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtitle.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: accent,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColor.textPrimary,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small reusable text field styled for the dark surfaces.
class AccountField extends StatelessWidget {
  const AccountField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType,
    this.readOnly = false,
    this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool readOnly;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 7),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColor.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              height: 1.2,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          style: const TextStyle(
            color: AppColor.textPrimary,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColor.surfaceHigh,
            suffixIcon: suffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColor.stroke),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: AppColor.primary, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

/// Primary full-width action button.
class AccountButton extends StatelessWidget {
  const AccountButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color = AppColor.primary,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 9),
            ],
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 1. Personal information
// =============================================================================

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _city = TextEditingController();
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // AppState is an inherited widget, so it can only be read once the
    // dependencies are resolved - not in initState.
    if (_seeded) return;
    _seeded = true;
    final p = AppState.of(context).profile;
    _name.text = p.name;
    _email.text = p.email;
    _phone.text = p.phone;
    _city.text = p.city;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccountScaffold(
      title: 'Personal information',
      subtitle: 'Account',
      children: [
        GlassCard(
          radius: 20,
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              AccountField(
                label: 'Full name',
                controller: _name,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
              AccountField(
                label: 'Email address',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              AccountField(
                label: 'Phone number',
                controller: _phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AccountField(
                label: 'City',
                controller: _city,
                keyboardType: TextInputType.text,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        AccountButton(
          label: 'Save changes',
          icon: Icons.check_rounded,
          onTap: () {
            final messenger = ScaffoldMessenger.of(context);
            AppState.of(context).updateProfile(
              name: _name.text,
              email: _email.text,
              phone: _phone.text,
              city: _city.text,
            );
            FocusScope.of(context).unfocus();
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Profile updated.'),
                  duration: Duration(seconds: 2),
                ),
              );
            Navigator.maybePop(context);
          },
        ),
      ],
    );
  }
}

// =============================================================================
// 2. Payment methods
// =============================================================================

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final methods = state.paymentMethods;

    return AccountScaffold(
      title: 'Payment methods',
      subtitle: 'Wallet',
      accent: AppColor.secondary,
      children: [
        if (methods.isEmpty)
          GlassCard(
            radius: 20,
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const Icon(
                  Icons.credit_card_off_rounded,
                  color: AppColor.textMuted,
                  size: 30,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No cards saved',
                  style: TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Add a card to speed up checkout.',
                  style: TextStyle(color: AppColor.textMuted, fontSize: 12.5),
                ),
              ],
            ),
          )
        else
          for (final method in methods)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PaymentTile(
                method: method,
                onMakeDefault: () =>
                    state.makeDefaultPaymentMethod(method.id),
                onDelete: () => _confirmDelete(state, method),
              ),
            ),
        const SizedBox(height: 12),
        AccountButton(
          label: 'Add a new card',
          icon: Icons.add_rounded,
          color: AppColor.secondary,
          onTap: () => _showAddCardSheet(context),
        ),
      ],
    );
  }

  void _confirmDelete(AppState state, PaymentMethod method) {
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
          'Remove card?',
          style: TextStyle(
            color: AppColor.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          '${method.display} will be removed from your wallet.',
          style: const TextStyle(
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
              state.removePaymentMethod(method.id);
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Remove',
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

  void _showAddCardSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _AddCardSheet(
          onAdd: (brand, last4, expiry) {
            AppState.of(context).addPaymentMethod(
              PaymentMethod(
                id: 'pm_${DateTime.now().millisecondsSinceEpoch}',
                brand: brand,
                last4: last4,
                expiry: expiry,
              ),
            );
            Navigator.pop(sheetContext);
          },
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.onMakeDefault,
    required this.onDelete,
  });

  final PaymentMethod method;
  final VoidCallback onMakeDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 18,
      accent: method.isDefault ? AppColor.secondary : null,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColor.surfaceHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColor.stroke),
                ),
                child: const Icon(
                  Icons.credit_card_rounded,
                  color: AppColor.textSecondary,
                  size: 17,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.display,
                      style: const TextStyle(
                        color: AppColor.textPrimary,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Expires ${method.expiry}',
                      style: const TextStyle(
                        color: AppColor.textMuted,
                        fontSize: 11.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (method.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.secondary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Text(
                    'DEFAULT',
                    style: TextStyle(
                      color: AppColor.secondary,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      height: 1.3,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!method.isDefault)
                Expanded(
                  child: _MiniButton(
                    label: 'Set as default',
                    onTap: onMakeDefault,
                  ),
                )
              else
                const Spacer(),
              const SizedBox(width: 8),
              _MiniButton(
                label: 'Remove',
                color: AppColor.danger,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({
    required this.label,
    required this.onTap,
    this.color = AppColor.textSecondary,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColor.surfaceHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.stroke),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet({required this.onAdd});

  final void Function(String brand, String last4, String expiry) onAdd;

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final _number = TextEditingController();
  final _expiry = TextEditingController();
  String _brand = 'Visa';
  String? _error;

  @override
  void dispose() {
    _number.dispose();
    _expiry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColor.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(
          top: BorderSide(color: AppColor.strokeStrong),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColor.strokeStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Add a card',
            style: TextStyle(
              color: AppColor.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 18),
          // Brand selector.
          Row(
            children: [
              for (final brand in const ['Visa', 'Mastercard', 'Amex'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _brand = brand),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: _brand == brand
                            ? AppColor.secondary
                            : AppColor.surfaceHigh,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: _brand == brand
                              ? AppColor.secondary
                              : AppColor.stroke,
                        ),
                      ),
                      child: Text(
                        brand,
                        style: TextStyle(
                          color: _brand == brand
                              ? AppColor.scrim
                              : AppColor.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          AccountField(
            label: 'Card number',
            controller: _number,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          AccountField(
            label: 'Expiry (MM/YY)',
            controller: _expiry,
            keyboardType: TextInputType.datetime,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                color: AppColor.danger,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 22),
          AccountButton(
            label: 'Save card',
            icon: Icons.add_rounded,
            color: AppColor.secondary,
            onTap: _submit,
          ),
        ],
      ),
    );
  }

  void _submit() {
    final digits = _number.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) {
      setState(() => _error = 'Enter at least the last four digits.');
      return;
    }
    final expiry = _expiry.text.trim().isEmpty ? '12/29' : _expiry.text.trim();
    widget.onAdd(_brand, digits.substring(digits.length - 4), expiry);
  }
}

// =============================================================================
// 3. Rental history
// =============================================================================

class RentalHistoryScreen extends StatelessWidget {
  const RentalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.of(context);
    final bookings = state.bookings;

    return AccountScaffold(
      title: 'Rental history',
      subtitle: 'Activity',
      accent: AppColor.amber,
      children: [
        if (bookings.isEmpty)
          GlassCard(
            radius: 20,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.history_rounded,
                  color: AppColor.textMuted,
                  size: 30,
                ),
                const SizedBox(height: 12),
                const Text(
                  'No rentals yet',
                  style: TextStyle(
                    color: AppColor.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Book a car and it will show up here.',
                  style: TextStyle(color: AppColor.textMuted, fontSize: 12.5),
                ),
              ],
            ),
          )
        else ...[
          GlassCard(
            radius: 18,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryBlock(
                    value: '${state.totalRides}',
                    label: 'Rentals',
                    accent: AppColor.amber,
                  ),
                ),
                Container(
                  width: 1,
                  height: 34,
                  color: AppColor.stroke,
                ),
                Expanded(
                  child: _SummaryBlock(
                    value: '\$${state.totalSpend.toStringAsFixed(0)}',
                    label: 'Spent',
                    accent: AppColor.success,
                  ),
                ),
                Container(
                  width: 1,
                  height: 34,
                  color: AppColor.stroke,
                ),
                Expanded(
                  child: _SummaryBlock(
                    value: '${state.activeCount}',
                    label: 'Active',
                    accent: AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final booking in bookings)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CarDetailsScreen(car: booking.car),
                  ),
                ),
                behavior: HitTestBehavior.opaque,
                child: GlassCard(
                  radius: 18,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 62,
                        height: 46,
                        child: Image.asset(
                          booking.car.image,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, stack) => const Icon(
                            Icons.directions_car_filled_rounded,
                            color: AppColor.textMuted,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.car.model,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColor.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_fmt(booking.start)} → ${_fmt(booking.end)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColor.textMuted,
                                fontSize: 11,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: booking.status.color.withValues(
                                      alpha: 0.16,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    booking.status.label.toUpperCase(),
                                    style: TextStyle(
                                      color: booking.status.color,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.7,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  booking.confirmationCode,
                                  style: const TextStyle(
                                    color: AppColor.textMuted,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${booking.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColor.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${booking.days}d',
                            style: const TextStyle(
                              color: AppColor.textMuted,
                              fontSize: 10.5,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  static String _fmt(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({
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
            fontSize: 17,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
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

// =============================================================================
// 4. Driving licence
// =============================================================================

class DrivingLicenceScreen extends StatefulWidget {
  const DrivingLicenceScreen({super.key});

  @override
  State<DrivingLicenceScreen> createState() => _DrivingLicenceScreenState();
}

class _DrivingLicenceScreenState extends State<DrivingLicenceScreen> {
  final TextEditingController _number = TextEditingController();
  DateTime? _expiry;
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    final p = AppState.of(context).profile;
    _number.text = p.licenceNumber;
    _expiry = p.licenceExpiry ?? DateTime(2028, 6, 30);
  }

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AccountScaffold(
      title: 'Driving licence',
      subtitle: 'Verification',
      accent: AppColor.success,
      children: [
        // Status card
        GlassCard(
          radius: 20,
          accent: AppColor.success,
          glowStrength: 0.10,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColor.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppColor.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Verified',
                      style: TextStyle(
                        color: AppColor.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Valid until ${_fmtLong(_expiry!)}',
                      style: const TextStyle(
                        color: AppColor.textMuted,
                        fontSize: 11.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        GlassCard(
          radius: 20,
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              AccountField(
                label: 'Licence number',
                controller: _number,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              // Expiry picker as a tappable field.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 7),
                    child: Text(
                      'EXPIRY DATE',
                      style: TextStyle(
                        color: AppColor.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        height: 1.2,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickExpiry,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.surfaceHigh,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColor.stroke),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _fmtLong(_expiry!),
                              style: const TextStyle(
                                color: AppColor.textPrimary,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.calendar_month_rounded,
                            color: AppColor.textMuted,
                            size: 17,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        AccountButton(
          label: 'Save licence',
          icon: Icons.check_rounded,
          color: AppColor.success,
          onTap: () {
            final messenger = ScaffoldMessenger.of(context);
            AppState.of(context).updateProfile(
              licenceNumber: _number.text,
              licenceExpiry: _expiry,
            );
            FocusScope.of(context).unfocus();
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Licence details updated.'),
                  duration: Duration(seconds: 2),
                ),
              );
            Navigator.maybePop(context);
          },
        ),
      ],
    );
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry ?? DateTime(now.year + 2),
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 20),
      builder: (pickerContext, child) => Theme(
        data: Theme.of(pickerContext).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColor.success,
            onPrimary: AppColor.scrim,
            surface: AppColor.surfaceHigh,
            onSurface: AppColor.textPrimary,
          ),
          dialogTheme: const DialogThemeData(
            backgroundColor: AppColor.surfaceHigh,
          ),
        ),
        child: MediaQuery(
          data: MediaQuery.of(pickerContext).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: child!,
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _expiry = picked);
  }

  static String _fmtLong(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// =============================================================================
// 5. Help & support
// =============================================================================

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const List<(String, String)> _faqs = [
    (
      'How do I extend an active rental?',
      'Open the booking from the Bookings tab, tap Extend rental and pick the '
          'new return date. The extra days are charged at the same daily rate.',
    ),
    (
      'What is included in the daily rate?',
      'Comprehensive insurance, 200 km per day, roadside assistance and a '
          'full tank on collection. Additional kilometres are billed per km.',
    ),
    (
      'Can I add a second driver?',
      'Yes. Add them under Personal information, then present their licence at '
          'collection. There is no additional fee for a second driver.',
    ),
    (
      'How do I cancel a booking?',
      'Open the booking and tap Cancel. Cancellations more than 48 hours '
          'before pickup are refunded in full.',
    ),
    (
      'What happens if the car breaks down?',
      'Call the 24/7 assistance line from the booking screen. Recovery and a '
          'replacement car are included in every rental.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AccountScaffold(
      title: 'Help & support',
      subtitle: 'Support',
      accent: AppColor.info,
      children: [
        // Contact row
        GlassCard(
          radius: 20,
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColor.info.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: AppColor.info,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Talk to a human',
                          style: TextStyle(
                            color: AppColor.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Available 24/7 · average wait 2 min',
                          style: TextStyle(
                            color: AppColor.textMuted,
                            fontSize: 11.5,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AccountButton(
                label: 'Start live chat',
                icon: Icons.chat_bubble_outline_rounded,
                color: AppColor.info,
                onTap: () => _snack(
                  context,
                  'A support agent will be with you shortly.',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ContactButton(
                      icon: Icons.call_rounded,
                      label: 'Call',
                      onTap: () => _snack(context, 'Dialling +92 300 0000000…'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ContactButton(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email',
                      onTap: () => _snack(
                        context,
                        'Opening support@rentcar.example…',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'FREQUENTLY ASKED',
          style: TextStyle(
            color: AppColor.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 12),
        for (final (question, answer) in _faqs)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _FaqTile(question: question, answer: answer),
          ),
      ],
    );
  }

  static void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColor.surfaceHigh,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColor.stroke),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColor.textSecondary, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColor.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 16,
      padding: EdgeInsets.zero,
      child: GestureDetector(
        onTap: () => setState(() => _open = !_open),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        color: AppColor.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColor.textMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: _open
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    widget.answer,
                    style: const TextStyle(
                      color: AppColor.textSecondary,
                      fontSize: 12.5,
                      height: 1.55,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
