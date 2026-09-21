import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/model/car_model.dart';
import 'package:rent_car/widgets/car_card_painter.dart';

class CarCard extends StatelessWidget {
  const CarCard({
    super.key,
    required this.height,
    required this.width,
    required this.car, required this.onTap,
  });
  final double height;
  final double width;
  final CarModel car;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    String carRent = car.price.toString();
    return SizedBox(
      height: height * 0.15,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              CustomPaint(
                size: Size(double.infinity, height * 0.17),
                painter: CarCardPainter(),
              ),
              Row(
                children: [
                  SizedBox(
                    width: constraints.maxWidth * 0.035,
                    height: constraints.maxHeight * 0.3,
                  ),
                  Icon(Icons.star, color: AppColor.yellow, size: 20),
                  SizedBox(width: constraints.maxWidth * 0.02),
                  Text(
                    car.rating.toString(),
                    style: TextStyle(color: AppColor.white),
                  ),
                ],
              ),
              Positioned(
                left: constraints.maxWidth * 0.035,
                top: constraints.maxHeight * 0.25,
                child: Text(
                  car.company,
                  style: TextStyle(
                    color: AppColor.yellow.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight(500),
                  ),
                ),
              ),

              Positioned(
                left: constraints.maxWidth * 0.035,
                top: constraints.maxHeight * 0.40,
                child: Text(
                  car.model,
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 16,
                    fontWeight: FontWeight(500),
                  ),
                ),
              ),

              Positioned(
                left: constraints.maxWidth * 0.035,
                top: constraints.maxHeight * 0.7,
                child: Row(
                  children: [
                    Text(
                      "\$$carRent",
                      style: TextStyle(
                        color: AppColor.white,
                        fontSize: 18,
                        fontWeight: FontWeight(500),
                      ),
                    ),
                    SizedBox(width: constraints.maxWidth * 0.02),
                    Text(
                      "1 day rent",
                      style: TextStyle(
                        color: AppColor.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight(400),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: constraints.maxWidth * 0.4,
                bottom: constraints.maxHeight * 0.15,
                child: Image.asset(
                  fit: BoxFit.cover,
                  car.image,
                  height: constraints.maxHeight * 0.75,
                  width: constraints.maxWidth * 0.6,
                ),
              ),
              Positioned(
                left: constraints.maxWidth * 0.9,
                top: constraints.maxHeight * 0.79,
                child: GestureDetector(onTap: onTap,child: Icon(Icons.arrow_forward_rounded, color: AppColor.black)),
              ),
            ],
          );
        },
      ),
    );
  }
}
