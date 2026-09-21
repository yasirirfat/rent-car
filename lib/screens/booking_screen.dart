import 'package:flutter/material.dart';
import 'package:rent_car/car_data/custom_date_picker_dialoge.dart';
import 'package:rent_car/core/app_color.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  // 0 = Active/Upcoming Rides, 1 = Past History
  int _selectedSegment = 0;

  // Custom Filter State
  DateTimeRange? _selectedDateRange;

  // Month names list for package-free date formatting
  final List<String> _monthNames = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  // --- RAW MOCK DATA WITH REAL DATETIME PARSABLE STRINGS ---
  final List<Map<String, dynamic>> _activeBookings = [
    {
      "brand": "Ferrari",
      "model": "Purosangue",
      "image": "assets/images/purosangue.png",
      "dateRange": "18 Jul - 20 Jul",
      "startDate": "2026-07-18",
      "endDate": "2026-07-20",
      "status": "Active",
      "price": "\$428.0",
      "timeLeft": "Ends in 5 hours",
    },
    {
      "brand": "Ferrari",
      "model": "Roma",
      "image": "assets/images/360_modena.png",
      "dateRange": "25 Jul - 28 Jul",
      "startDate": "2026-07-25",
      "endDate": "2026-07-28",
      "status": "Upcoming",
      "price": "\$395.0",
      "timeLeft": "Starts in 7 days",
    },
    {
      "brand": "Ferrari",
      "model": "SF90 Stradale",
      "image": "assets/images/sf90.png",
      "dateRange": "01 Aug - 04 Aug",
      "startDate": "2026-08-01",
      "endDate": "2026-08-04",
      "status": "Upcoming",
      "price": "\$690.0",
      "timeLeft": "Starts in 14 days",
    },
    {
      "brand": "Ferrari",
      "model": "LaFerrari",
      "image": "assets/images/laferrari.png",
      "dateRange": "12 Aug - 15 Aug",
      "startDate": "2026-08-12",
      "endDate": "2026-08-15",
      "status": "Upcoming",
      "price": "\$1200.0",
      "timeLeft": "Starts in 25 days",
    },
  ];

  final List<Map<String, dynamic>> _pastBookings = [
    {
      "brand": "Ferrari",
      "model": "F8 Tributo",
      "image": "assets/images/296_gtb.png",
      "dateRange": "02 Jun - 03 Jun",
      "startDate": "2026-06-02",
      "endDate": "2026-06-03",
      "status": "Completed",
      "price": "\$510.0",
      "timeLeft": "Returned Successfully",
    },
    {
      "brand": "Ferrari",
      "model": "812 Superfast",
      "image": "assets/images/812_superfast.png",
      "dateRange": "20 May - 22 May",
      "startDate": "2026-05-20",
      "endDate": "2026-05-22",
      "status": "Completed",
      "price": "\$620.0",
      "timeLeft": "Returned Successfully",
    },
    {
      "brand": "Ferrari",
      "model": "488 Pista",
      "image": "assets/images/488_pista.png",
      "dateRange": "15 Mar - 17 Mar",
      "startDate": "2026-03-15",
      "endDate": "2026-03-17",
      "status": "Completed",
      "price": "\$540.0",
      "timeLeft": "Returned Successfully",
    },
    {
      "brand": "Ferrari",
      "model": "812 Superfast",
      "image": "assets/images/812_superfast.png",
      "dateRange": "01 Feb - 02 Feb",
      "startDate": "2026-02-01",
      "endDate": "2026-02-02",
      "status": "Completed",
      "price": "\$620.0",
      "timeLeft": "Returned Successfully",
    },
  ];

  // --- LIVE FILTERING LOGIC ---
  List<Map<String, dynamic>> _getFilteredList() {
    List<Map<String, dynamic>> initialList = _selectedSegment == 0
        ? _activeBookings
        : _pastBookings;

    if (_selectedDateRange == null) {
      return initialList;
    }

    return initialList.where((booking) {
      DateTime bookingStart = DateTime.parse(booking['startDate']);
      DateTime bookingEnd = DateTime.parse(booking['endDate']);

      return (bookingStart.isBefore(_selectedDateRange!.end) ||
              bookingStart.isAtSameMomentAs(_selectedDateRange!.end)) &&
          (bookingEnd.isAfter(_selectedDateRange!.start) ||
              bookingEnd.isAtSameMomentAs(_selectedDateRange!.start));
    }).toList();
  }


  @override
  Widget build(BuildContext context) {
    final Size(:height, :width) = MediaQuery.sizeOf(context);
    final bool isTablet = width > 600;

    final currentList = _getFilteredList();

    // Custom formatting without intl package
    String startCustom = "";
    String endCustom = "";
    if (_selectedDateRange != null) {
      startCustom =
          "${_selectedDateRange!.start.day} ${_monthNames[_selectedDateRange!.start.month - 1]}";
      endCustom =
          "${_selectedDateRange!.end.day} ${_monthNames[_selectedDateRange!.end.month - 1]}";
    }

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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  // --- PREMIUM HEADER WITH INTERACTIVE DATE PICKER ---
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32.0 : width * 0.03,
                      vertical: 24.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "MY GARAGE",
                              style: TextStyle(
                                color: AppColor.yellow,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Bookings",
                              style: TextStyle(
                                color: AppColor.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => CustomDatePicker.openRangePicker(context: context, initialDateRange: _selectedDateRange, onDatesSelected: (pickRange) {
                            setState(() {
                              _selectedDateRange = pickRange;
                            });
                          },),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColor.containerColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _selectedDateRange == null
                                  ? Icons.calendar_today_rounded
                                  : Icons.edit_calendar_rounded,
                              color: AppColor.yellow,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- DATE CHIP CLEAR INDICATOR (Package-Free) ---
                  if (_selectedDateRange != null)
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        isTablet ? 32.0 : width * 0.03,
                        0,
                        isTablet ? 32.0 : width * 0.03,
                        16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Filtered: $startCustom - $endCustom",
                            style: const TextStyle(
                              color: AppColor.yellow,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _selectedDateRange = null),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.yellow.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    "Clear",
                                    style: TextStyle(
                                      color: AppColor.yellow,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.close_rounded,
                                    color: AppColor.yellow,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // --- PREMIUM CUSTOM SEGMENTED CONTROLLER ---
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32.0 : width * 0.03,
                    ),
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColor.containerColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedSegment = 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedSegment == 0
                                      ? AppColor.black
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    "Active / Upcoming",
                                    style: TextStyle(
                                      color: _selectedSegment == 0
                                          ? AppColor.yellow
                                          : AppColor.white.withValues(
                                              alpha: 0.5,
                                            ),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedSegment = 1),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _selectedSegment == 1
                                      ? AppColor.black
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    "History",
                                    style: TextStyle(
                                      color: _selectedSegment == 1
                                          ? AppColor.yellow
                                          : AppColor.white.withValues(
                                              alpha: 0.5,
                                            ),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- EXPANDED BOOKINGS CONTENT AREA ---
                  Expanded(
                    child: currentList.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              isTablet ? 32.0 : width * 0.03,
                              0,
                              isTablet ? 32.0 : width * 0.03,
                              24,
                            ),
                            itemCount: currentList.length,
                            itemBuilder: (context, index) {
                              final ride = currentList[index];
                              return _buildBookingCard(ride);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- PREMIUM SYMMETRICAL BOOKING CARD ---
  Widget _buildBookingCard(Map<String, dynamic> ride) {
    bool isActive = ride['status'] == 'Active';
    bool isUpcoming = ride['status'] == 'Upcoming';

    Color tagColor = isActive
        ? Colors.greenAccent
        : (isUpcoming
              ? AppColor.yellow
              : AppColor.white.withValues(alpha: 0.4));

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.containerColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Car Context Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        ride['status'].toUpperCase(),
                        style: TextStyle(
                          color: tagColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ride['brand'],
                      style: TextStyle(
                        color: AppColor.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      ride['model'],
                      style: const TextStyle(
                        color: AppColor.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // --- UNIFORM LARGER CAR IMAGE CONTAINER (180 x 105) ---
              SizedBox(
                width: 180,
                height: 105,
                child: Image.asset(
                  ride['image'],
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.directions_car_filled_rounded,
                      color: AppColor.white.withValues(alpha: 0.05),
                      size: 70,
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Divider(
              color: AppColor.black.withValues(alpha: 0.2),
              height: 1,
            ),
          ),
          const SizedBox(height: 12),

          // Bottom Metric Row Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColor.white,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ride['dateRange'],
                    style: const TextStyle(
                      color: AppColor.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                ride['price'],
                style: const TextStyle(
                  color: AppColor.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ride['timeLeft'],
                style: TextStyle(
                  color: isActive
                      ? AppColor.yellow
                      : AppColor.white.withValues(alpha: 0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- MINIMALIST EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 64,
            color: AppColor.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedDateRange != null
                ? "No rides for these dates"
                : "No rentals recorded",
            style: TextStyle(
              color: AppColor.white.withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedDateRange != null
                ? "Try picking another date slot."
                : "Ready to book your next fast drive?",
            style: TextStyle(
              color: AppColor.white.withValues(alpha: 0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
