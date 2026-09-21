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
  });
}