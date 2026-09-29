class CarModel {
  final String company;
  final String model;
  final String image;
  final double rating;
  final double price;

  // UI Details dynamic karne ke liye new fields add ki hain
  final String maxSpeed;
  final String engine;
  final String ability; // Seats
  final String airbag;
  final String fuelType;
  final String drivetrain;

  /// Odometer reading shown on the comparison sheet, e.g. "12,400 km".
  final String mileage;

  /// Body category used by the home screen filter chips.
  final CarCategory category;

  /// Short marketing blurb shown on the details screen.
  final String tagline;

  /// Optional extra gallery images (falls back to [image]).
  final List<String> gallery;

  CarModel({
    required this.company,
    required this.model,
    required this.image,
    required this.rating,
    required this.price,
    required this.maxSpeed,
    required this.engine,
    required this.ability,
    required this.airbag,
    required this.fuelType,
    required this.drivetrain,
    this.mileage = '18,500 km',
    this.category = CarCategory.coupe,
    this.tagline = '',
    this.gallery = const [],
  });

  /// Numeric top speed parsed from [maxSpeed] (e.g. "340Km/h" -> 340).
  /// Used to drive the speedometer gauge and the sort options.
  double get topSpeedKmh {
    final match = RegExp(r'\d+(\.\d+)?').firstMatch(maxSpeed);
    if (match == null) return 0;
    return double.tryParse(match.group(0)!) ?? 0;
  }

  /// Number of seats parsed from [ability] (e.g. "4 Seats" -> 4).
  int get seatCount {
    final match = RegExp(r'\d+').firstMatch(ability);
    return int.tryParse(match?.group(0) ?? '') ?? 0;
  }

  /// Displacement in litres parsed from [engine], if present.
  double get displacementLitres {
    final match = RegExp(r'(\d+\.\d+)L').firstMatch(engine);
    return double.tryParse(match?.group(1) ?? '') ?? 0;
  }

  /// Cylinder count parsed from [engine] (V12, Flat-12, V8 ...).
  int get cylinderCount {
    final match = RegExp(r'(\d+)\s*$').firstMatch(engine.replaceAll('°', ''));
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  /// Odometer reading in kilometres parsed from [mileage].
  /// Tolerates "12,400 km" and "12400km".
  int get mileageKm {
    final digits = mileage.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  /// 0..1 performance score used for the details screen stat bars.
  /// Blends top speed, cylinders and price into a single comparative figure.
  double get performanceScore {
    final speedPart = (topSpeedKmh / 350).clamp(0.0, 1.0);
    final cylinderPart = (cylinderCount / 12).clamp(0.0, 1.0);
    return (speedPart * 0.65) + (cylinderPart * 0.35);
  }

  /// 0..1 value score - cheaper cars with high performance score higher.
  double get valueScore {
    final pricePart = 1 - (price / 1500).clamp(0.0, 1.0);
    return (performanceScore * 0.5) + (pricePart * 0.5);
  }

  /// Unique key used for favourites and booking lookups.
  String get id => '$company-$model'.toLowerCase().replaceAll(' ', '_');

  /// Gallery with the primary image guaranteed to be first.
  List<String> get allImages =>
      gallery.isEmpty ? [image] : {image, ...gallery}.toList();

  @override
  bool operator ==(Object other) =>
      other is CarModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Coarse body-style categories used by the filter chips.
enum CarCategory {
  all('All', 'Every car in the fleet'),
  suv('SUV', 'Practical grand tourers'),
  coupe('Coupe', 'Two seat track weapons'),
  convertible('Spider', 'Open top thrills'),
  hyper('Hyper', 'Limited run flagships');

  const CarCategory(this.label, this.description);

  final String label;
  final String description;
}