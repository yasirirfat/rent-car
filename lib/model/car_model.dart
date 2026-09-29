class CarModel {
  final String company;
  final String model;
  final String image;
  final double rating;
  final double price;

  final String maxSpeed;
  final String engine;
  final String ability;
  final String airbag;
  final String fuelType;
  final String drivetrain;

  final String mileage;

  final CarCategory category;

  final String tagline;

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

  double get topSpeedKmh {
    final match = RegExp(r'\d+(\.\d+)?').firstMatch(maxSpeed);
    if (match == null) return 0;
    return double.tryParse(match.group(0)!) ?? 0;
  }

  int get seatCount {
    final match = RegExp(r'\d+').firstMatch(ability);
    return int.tryParse(match?.group(0) ?? '') ?? 0;
  }

  double get displacementLitres {
    final match = RegExp(r'(\d+\.\d+)L').firstMatch(engine);
    return double.tryParse(match?.group(1) ?? '') ?? 0;
  }

  int get cylinderCount {
    final match = RegExp(r'(\d+)\s*$').firstMatch(engine.replaceAll('°', ''));
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  int get mileageKm {
    final digits = mileage.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  double get performanceScore {
    final speedPart = (topSpeedKmh / 350).clamp(0.0, 1.0);
    final cylinderPart = (cylinderCount / 12).clamp(0.0, 1.0);
    return (speedPart * 0.65) + (cylinderPart * 0.35);
  }

  double get valueScore {
    final pricePart = 1 - (price / 1500).clamp(0.0, 1.0);
    return (performanceScore * 0.5) + (pricePart * 0.5);
  }

  String get id => '$company-$model'.toLowerCase().replaceAll(' ', '_');

  List<String> get allImages =>
      gallery.isEmpty ? [image] : {image, ...gallery}.toList();

  @override
  bool operator ==(Object other) => other is CarModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

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
