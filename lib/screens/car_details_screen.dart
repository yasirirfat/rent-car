import 'package:flutter/material.dart';
import 'package:rent_car/car_data/custom_date_picker_dialoge.dart';
import 'package:rent_car/core/app_color.dart';
import 'package:rent_car/model/car_model.dart';



class CarDetailsScreen extends StatefulWidget {
  final CarModel car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  DateTimeRange? _selectedDateRange;
  int _rentalDays = 1;

  // 1. Function: Aapki CustomDatePicker Class ko call karne ke liye
  void _openCustomRentalDatePicker() {
    CustomDatePicker.openRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      onDatesSelected: (pickedRange) {
        setState(() {
          _selectedDateRange = pickedRange;
          // Total rental days calculate karna (+1 taake starting aur ending days dono count hon)
          _rentalDays = pickedRange.end.difference(pickedRange.start).inDays + 1;
        });
      },
    );
  }

  // 2. Function: "Book Now" Sheet Summary
  void _showBookingBottomSheet() {
    final double totalPrice = widget.car.price * _rentalDays;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColor.darkGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColor.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Confirm Booking',
                style: TextStyle(color: AppColor.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildSummaryRow('Vehicle', '${widget.car.company} ${widget.car.model}'),
              _buildSummaryRow('Duration', '$_rentalDays Day(s)'),
              _buildSummaryRow(
                'Dates',
                _selectedDateRange != null
                    ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}'
                    : 'Not Selected (1 Day Default)',
              ),
              const Divider(color: Colors.white10, height: 30),
              _buildSummaryRow('Total Amount', '\$ ${totalPrice.toStringAsFixed(2)}', isTotal: true),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.yellow,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Summary sheet close
                    _showSuccessDialog();   // Success dialog popup
                  },
                  child: const Text(
                    'Confirm & Pay',
                    style: TextStyle(color: AppColor.black, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Summary Row Helper Widget
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: TextStyle(
              color: isTotal ? AppColor.white : AppColor.white.withValues(alpha: 0.5), 
              fontSize: isTotal ? 18 : 14, 
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal
            )
          ),
          Text(
            value, 
            style: TextStyle(
              color: isTotal ? AppColor.yellow : AppColor.white, 
              fontSize: isTotal ? 20 : 14, 
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }

  // 3. Function: Final Payment Success Dialog
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColor.darkGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline_rounded, color: AppColor.yellow, size: 70),
            const SizedBox(height: 20),
            const Text('Booking Successful!', style: TextStyle(color: AppColor.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              'Your ${widget.car.company} ride has been reserved successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColor.white.withValues(alpha: 0.6), fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.white.withValues(alpha: 0.1),
                foregroundColor: AppColor.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context); // Dialog close
                Navigator.pop(context); // Details screen pop (Back to home)
              },
              child: const Text('Great!'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size(:height, :width) = MediaQuery.sizeOf(context);
    final double currentDisplayPrice = widget.car.price * _rentalDays;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: MediaQuery.paddingOf(context).top + 10),

                        // 1. Top Header Controls
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColor.white.withValues(alpha: 0.1),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back, color: AppColor.white, size: 20),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                              Image.network(
                                'https://upload.wikimedia.org/wikipedia/en/thumb/d/d1/Ferrari-Logo.svg/800px-Ferrari-Logo.svg.png',
                                height: 42,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.directions_car, color: AppColor.yellow),
                              ),
                              // Calendar Button (Aapki custom class ko trigger karega)
                              CircleAvatar(
                                backgroundColor: _selectedDateRange != null ? AppColor.yellow : AppColor.white.withValues(alpha: 0.1),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.calendar_month_outlined, 
                                    color: _selectedDateRange != null ? AppColor.black : AppColor.white, 
                                    size: 20
                                  ),
                                  onPressed: _openCustomRentalDatePicker,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: height * 0.04),

                        // 2. Car Showcase Section
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                width: width * 0.9,
                                height: height * 0.18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.all(Radius.elliptical(width * 0.85, 90)),
                                  border: Border.all(color: AppColor.white.withValues(alpha: 0.15), width: 1.5),
                                  color: Colors.transparent,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 25.0),
                                child: Image.asset(
                                  widget.car.image,
                                  width: width * 0.85,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColor.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColor.black.withValues(alpha: 0.3),
                                        blurRadius: 5,
                                      )
                                    ]
                                  ),
                                  child: const Icon(Icons.code, size: 14, color: AppColor.black),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.04),
                        
                        // 3. Title & Rating Row
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${widget.car.company} ${widget.car.model}",
                                style: const TextStyle(
                                  color: AppColor.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: AppColor.yellow, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.car.rating.toString(),
                                    style: TextStyle(
                                      color: AppColor.white.withValues(alpha: 0.7), 
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.04),

                        // 4. Specs Grid Box
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: AppColor.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColor.white.withValues(alpha: 0.05)),
                            ),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 3,
                              childAspectRatio: 0.9,
                              children: [
                                SpecItemCard(icon: Icons.speed, title: 'Max Speed', value: widget.car.maxSpeed),
                                SpecItemCard(icon: Icons.brightness_7_sharp, title: 'Engine', value: widget.car.engine, showLeftDivider: true),
                                SpecItemCard(icon: Icons.airline_seat_recline_normal_rounded, title: 'Ability', value: widget.car.ability, showLeftDivider: true),
                                SpecItemCard(icon: Icons.personal_video_rounded, title: 'Airbag', value: widget.car.airbag),
                                SpecItemCard(icon: Icons.local_gas_station_rounded, title: 'Fuel Type', value: widget.car.fuelType, showLeftDivider: true),
                                SpecItemCard(icon: Icons.token_outlined, title: 'Drivetrain', value: widget.car.drivetrain, showLeftDivider: true),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.04),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 5. Fixed Bottom Navigation Layout (Dynamic Calculations Integrated)
            Container(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.025),
              color: Colors.transparent,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Rent Price',
                          style: TextStyle(color: AppColor.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        RichText(
                          text: TextSpan(
                            text: '\$ ${currentDisplayPrice.toStringAsFixed(2)} ',
                            style: const TextStyle(color: AppColor.yellow, fontSize: 20, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: '/ $_rentalDays Day${_rentalDays > 1 ? 's' : ''}',
                                style: TextStyle(color: AppColor.white.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.yellow,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _showBookingBottomSheet,
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            color: AppColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpecItemCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool showLeftDivider;

  const SpecItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.showLeftDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: showLeftDivider 
              ? BorderSide(color: AppColor.white.withValues(alpha: 0.05), width: 1) 
              : BorderSide.none,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.white.withValues(alpha: 0.04),
              border: Border.all(color: AppColor.white.withValues(alpha: 0.05)),
            ),
            child: Icon(icon, color: AppColor.white.withValues(alpha: 0.8), size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: AppColor.white.withValues(alpha: 0.4), fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColor.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}