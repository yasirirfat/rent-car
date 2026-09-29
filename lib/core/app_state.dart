import 'package:flutter/material.dart';
import 'package:rent_car/model/car_model.dart';

/// A single confirmed rental.
class Booking {
  Booking({
    required this.car,
    required this.start,
    required this.end,
    required this.dailyRate,
    required this.confirmationCode,
  });

  final CarModel car;
  final DateTime start;
  final DateTime end;
  final double dailyRate;
  final String confirmationCode;

  /// Inclusive day count.
  int get days => end.difference(start).inDays + 1;

  double get total => dailyRate * days;

  /// Simple derived status based on today's date.
  BookingStatus get status {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    if (today.isBefore(s)) return BookingStatus.upcoming;
    if (today.isAfter(e)) return BookingStatus.completed;
    return BookingStatus.active;
  }

  /// Human readable countdown / summary.
  String get timelineLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);

    switch (status) {
      case BookingStatus.upcoming:
        final diff = s.difference(today).inDays;
        return diff == 0 ? 'Starts today' : 'Starts in $diff day${diff == 1 ? '' : 's'}';
      case BookingStatus.active:
        final left = e.difference(today).inDays;
        return left == 0 ? 'Ends today' : 'Ends in $left day${left == 1 ? '' : 's'}';
      case BookingStatus.completed:
        return 'Returned successfully';
    }
  }
}

enum BookingStatus {
  active('Active', Color(0xFF3DDC97)),
  upcoming('Upcoming', Color(0xFFFFC24B)),
  completed('Completed', Color(0xFF8A93B4));

  const BookingStatus(this.label, this.color);

  final String label;
  final Color color;
}

/// The user's editable profile, held in [AppState] so the profile screen can
/// actually change it and the rest of the app can read it back.
class UserProfile {
  UserProfile({
    this.name = 'Yasir Ahmed',
    this.email = 'yasir.ahmed@example.com',
    this.phone = '+92 300 1234567',
    this.city = 'Bahawalpur',
    this.licenceNumber = 'PB-DL-2019-4471',
    this.licenceExpiry,
  });

  String name;
  String email;
  String phone;
  String city;
  String licenceNumber;
  DateTime? licenceExpiry;

  /// Two-letter monogram used by the avatar.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

/// A card the user has saved for paying rentals.
class PaymentMethod {
  PaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expiry,
    this.isDefault = false,
  });

  final String id;
  final String brand;
  final String last4;
  final String expiry;
  bool isDefault;

  String get display => '$brand ···· $last4';
}

/// Lightweight app-wide state.
///
/// Deliberately dependency free - an [InheritedNotifier] over a [ChangeNotifier]
/// so favourites, bookings, settings and the profile survive tab switches
/// without pulling in a state management package.
class AppState extends ChangeNotifier {
  static AppState of(BuildContext context) {
    final state = context
        .dependOnInheritedWidgetOfExactType<AppStateScope>()
        ?.notifier;
    assert(state != null, 'AppStateScope not found in widget tree');
    return state!;
  }

  final Set<String> _favouriteIds = {};
  final List<Booking> _bookings = [];
  final Set<String> _recentlyViewedIds = {};

  // --- Settings -------------------------------------------------------------
  // Every value here is read by SettingsScreen and written back through the
  // setters below, so the toggles actually hold state across rebuilds.

  bool _pushNotifications = true;
  bool _promoEmails = false;
  bool _biometricLogin = false;
  bool _locationAccess = true;
  String _language = 'English';
  double _searchRadius = 35;

  bool get pushNotifications => _pushNotifications;
  bool get promoEmails => _promoEmails;
  bool get biometricLogin => _biometricLogin;
  bool get locationAccess => _locationAccess;
  String get language => _language;
  double get searchRadius => _searchRadius;

  void setPushNotifications(bool value) {
    if (_pushNotifications == value) return;
    _pushNotifications = value;
    notifyListeners();
  }

  void setPromoEmails(bool value) {
    if (_promoEmails == value) return;
    _promoEmails = value;
    notifyListeners();
  }

  void setBiometricLogin(bool value) {
    if (_biometricLogin == value) return;
    _biometricLogin = value;
    notifyListeners();
  }

  void setLocationAccess(bool value) {
    if (_locationAccess == value) return;
    _locationAccess = value;
    notifyListeners();
  }

  void setLanguage(String value) {
    if (_language == value) return;
    _language = value;
    notifyListeners();
  }

  void setSearchRadius(double value) {
    if (_searchRadius == value) return;
    _searchRadius = value;
    notifyListeners();
  }

  /// Clears the recently-viewed list. Called by the settings screen's
  /// "Clear app cache" action, since that list is what the cache holds.
  void clearRecentlyViewed() {
    if (_recentlyViewedIds.isEmpty) return;
    _recentlyViewedIds.clear();
    notifyListeners();
  }

  /// Resets every preference back to its default. Backs the "Reset
  /// preferences" action so that button does something real.
  void resetPreferences() {
    _pushNotifications = true;
    _promoEmails = false;
    _biometricLogin = false;
    _locationAccess = true;
    _language = 'English';
    _searchRadius = 35;
    _recentlyViewedIds.clear();
    notifyListeners();
  }

  // --- Profile --------------------------------------------------------------

  final UserProfile profile = UserProfile();

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: 'pm_1',
      brand: 'Visa',
      last4: '4242',
      expiry: '08/28',
      isDefault: true,
    ),
    PaymentMethod(
      id: 'pm_2',
      brand: 'Mastercard',
      last4: '9315',
      expiry: '02/27',
    ),
  ];

  List<PaymentMethod> get paymentMethods => List.unmodifiable(_paymentMethods);

  PaymentMethod? get defaultPaymentMethod {
    for (final m in _paymentMethods) {
      if (m.isDefault) return m;
    }
    return _paymentMethods.isEmpty ? null : _paymentMethods.first;
  }

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? city,
    String? licenceNumber,
    DateTime? licenceExpiry,
  }) {
    if (name != null && name.trim().isNotEmpty) profile.name = name.trim();
    if (email != null && email.trim().isNotEmpty) profile.email = email.trim();
    if (phone != null && phone.trim().isNotEmpty) profile.phone = phone.trim();
    if (city != null && city.trim().isNotEmpty) profile.city = city.trim();
    if (licenceNumber != null && licenceNumber.trim().isNotEmpty) {
      profile.licenceNumber = licenceNumber.trim();
    }
    if (licenceExpiry != null) profile.licenceExpiry = licenceExpiry;
    notifyListeners();
  }

  void addPaymentMethod(PaymentMethod method) {
    if (method.isDefault) {
      for (final m in _paymentMethods) {
        m.isDefault = false;
      }
    }
    _paymentMethods.add(method);
    notifyListeners();
  }

  void removePaymentMethod(String id) {
    final wasDefault = _paymentMethods.any((m) => m.id == id && m.isDefault);
    _paymentMethods.removeWhere((m) => m.id == id);
    if (wasDefault && _paymentMethods.isNotEmpty) {
      _paymentMethods.first.isDefault = true;
    }
    notifyListeners();
  }

  void makeDefaultPaymentMethod(String id) {
    for (final m in _paymentMethods) {
      m.isDefault = m.id == id;
    }
    notifyListeners();
  }

  /// Clears the signed-in user's local data. Used by "Log out".
  void signOut() {
    _favouriteIds.clear();
    _bookings.clear();
    _recentlyViewedIds.clear();
    _compareIds.clear();
    notifyListeners();
  }

  // --- Favourites -----------------------------------------------------------

  Set<String> get favouriteIds => Set.unmodifiable(_favouriteIds);

  int get favouriteCount => _favouriteIds.length;

  bool isFavourite(CarModel car) => _favouriteIds.contains(car.id);

  void toggleFavourite(CarModel car) {
    if (!_favouriteIds.remove(car.id)) {
      _favouriteIds.add(car.id);
    }
    notifyListeners();
  }

  List<CarModel> favouritesFrom(List<CarModel> all) =>
      all.where((c) => _favouriteIds.contains(c.id)).toList();

  // --- Recently viewed ------------------------------------------------------

  List<String> get recentlyViewedIds => List.unmodifiable(_recentlyViewedIds);

  void markViewed(CarModel car) {
    _recentlyViewedIds.remove(car.id);
    _recentlyViewedIds.add(car.id);
    // Keep only the last 6.
    if (_recentlyViewedIds.length > 6) {
      _recentlyViewedIds.remove(_recentlyViewedIds.first);
    }
    notifyListeners();
  }

  List<CarModel> recentlyViewedFrom(List<CarModel> all) {
    final byId = {for (final c in all) c.id: c};
    return _recentlyViewedIds
        .map((id) => byId[id])
        .whereType<CarModel>()
        .toList()
        .reversed
        .toList();
  }

  // --- Comparison -----------------------------------------------------------

  /// Cars queued for side-by-side comparison. Capped at [maxCompare].
  static const int maxCompare = 4;

  final List<String> _compareIds = [];

  List<String> get compareIds => List.unmodifiable(_compareIds);

  int get compareCount => _compareIds.length;

  bool isComparing(CarModel car) => _compareIds.contains(car.id);

  bool get canCompareMore => _compareIds.length < maxCompare;

  /// Adds or removes [car] from the comparison set.
  ///
  /// Returns false when the set is already full and the car was not in it, so
  /// the caller can surface a message.
  bool toggleCompare(CarModel car) {
    if (_compareIds.remove(car.id)) {
      notifyListeners();
      return true;
    }
    if (_compareIds.length >= maxCompare) return false;
    _compareIds.add(car.id);
    notifyListeners();
    return true;
  }

  void clearCompare() {
    if (_compareIds.isEmpty) return;
    _compareIds.clear();
    notifyListeners();
  }

  List<CarModel> compareCarsFrom(List<CarModel> all) {
    final byId = {for (final c in all) c.id: c};
    return _compareIds
        .map((id) => byId[id])
        .whereType<CarModel>()
        .toList();
  }

  // --- Bookings -------------------------------------------------------------

  List<Booking> get bookings => List.unmodifiable(_bookings);

  int get totalRides => _bookings.length;

  double get totalSpend =>
      _bookings.fold(0.0, (sum, booking) => sum + booking.total);

  int get activeCount => _bookings
      .where((b) => b.status != BookingStatus.completed)
      .length;

  /// Confirms a rental and returns the created record.
  Booking addBooking({
    required CarModel car,
    required DateTime start,
    required DateTime end,
  }) {
    final booking = Booking(
      car: car,
      start: start,
      end: end,
      dailyRate: car.price,
      confirmationCode: _generateCode(),
    );
    _bookings.insert(0, booking);
    notifyListeners();
    return booking;
  }

  void cancelBooking(Booking booking) {
    _bookings.remove(booking);
    notifyListeners();
  }

  static String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final now = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer('RC-');
    var seed = now;
    for (var i = 0; i < 6; i++) {
      seed = (seed * 1103515245 + 12345) & 0x7fffffff;
      buffer.write(chars[seed % chars.length]);
    }
    return buffer.toString();
  }
}

/// Provides [AppState] to the subtree.
///
/// **Performance note.** [updateShouldNotify] must return `false`.
///
/// [InheritedNotifier] rebuilds *every* dependant whenever `updateShouldNotify`
/// reports a change, and it calls this method on every single
/// `notifyListeners()`. Returning `true` therefore marks every caller of
/// [AppState.of] dirty - and because each tab is a direct child of the
/// [_MainWrapperState]'s `IndexedStack`, that means the whole app rebuilds on
/// every favourite toggle, every search keystroke and every scroll-driven
/// `notifyListeners()`. That is the dominant source of the scroll and tap lag.
///
/// The notifier itself is final and never swapped, so the inherited value can
/// never actually change. Listeners are still notified correctly: the
/// [InheritedNotifier] element subscribes to the [ChangeNotifier] directly and
/// rebuilds its dependants when it fires, independently of this method.
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  @override
  bool updateShouldNotify(AppStateScope oldWidget) => false;
}
