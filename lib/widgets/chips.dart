import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

class Chips extends StatefulWidget {
  const Chips({super.key});

  @override
  State<Chips> createState() => _ChipsState();
}

class _ChipsState extends State<Chips> {
  List<String> cars = [
    "All",
    "Purosangue SUV",
    "Roma",
    "Tributo",
    "488 GTB",
    "F8 Tributo",
    "SF90 Stradale",
    "812 Superfast",
    "296 GTB",
    "Daytona SP3",
    "LaFerrari",
    "Portofino M",
  ];
  String? selectedCar = "All";
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cars.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final car = cars[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCar = car;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selectedCar == car
                    ? AppColor.yellow
                    : AppColor.containerColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Text(
                car,
                style: TextStyle(
                  color: selectedCar == car ? AppColor.black : AppColor.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
