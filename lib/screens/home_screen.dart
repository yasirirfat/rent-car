import 'package:flutter/material.dart';
import 'package:rent_car/car_data/car_data.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/screens/car_details_screen.dart';

import 'package:rent_car/widgets/car_card.dart';
import 'package:rent_car/widgets/chips.dart';
import 'package:rent_car/widgets/circular_bottom_navigation.dart';
import 'package:rent_car/widgets/header.dart';
import 'package:rent_car/widgets/search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;
  late CircularBottomNavigationController _navigationController;

  // FIXED HERE: Live search query store karne ke liye variable declare kar diya
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _navigationController = CircularBottomNavigationController(selectedTab);
  }

  @override
  void dispose() {
    _navigationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size(:height, :width) = MediaQuery.sizeOf(context);

    // FIXED HERE: carList ko search query ke mutabiq live filter karne ki logic
    final filteredCars = carList.where((car) {
      final carName = car.model.toLowerCase();
      final searchInput = searchQuery.toLowerCase();
      return carName.contains(searchInput);
    }).toList();

    return Scaffold(
      backgroundColor: AppColor.black.withValues(alpha: 0.1),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.darkGrey,
              AppColor.darkGrey.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.03),
            child: Column(
              children: [
                const Header(),
                SizedBox(height: height * 0.02),
                SearchBars(
                  onChanged: (value) {
                    setState(() {
                      searchQuery =
                          value; // Ab yeh live update karega bina error ke
                    });
                  },
                ),
                SizedBox(height: height * 0.015),
                const Chips(),
                SizedBox(height: height * 0.015),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular',
                      style: TextStyle(
                        color: AppColor.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'See All',
                      style: TextStyle(
                        color: AppColor.yellow.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.015),

                // FIXED HERE: Ab yeh filter ki hui list show karega, aur agar kuch nahi mila to message dikhaye ga
                Expanded(
                  child: filteredCars.isEmpty
                      ? const Center(
                          child: Text(
                            'No cars found!',
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : // HomeScreen ke ListView.builder ke andar is tarah update karein:
                        ListView.builder(
                          itemCount: filteredCars.length,
                          itemBuilder: (context, index) {
                            final currentCar = filteredCars[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: CarCard(
                                height: height,
                                width: width,
                                car: currentCar,
                                onTap: () {
                                  // Tap karne par details screen open hogi aur selected car object pass hoga
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CarDetailsScreen(car: currentCar),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
