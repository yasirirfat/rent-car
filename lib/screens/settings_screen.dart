import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _pushNotifications = true;
  bool _biometricsEnabled = false;
  String _selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    final Size(:height, :width) = MediaQuery.sizeOf(context);
    final bool isTablet = width > 600;

    return Scaffold(
      backgroundColor: AppColor.black.withValues(
        alpha: 0.1,
      ), // Matched with HomeScreen
      body: Container(
        // --- MATCHED PREMIUM GRADIENT BACKGROUND ---
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
                  // --- PREMIUM DYNAMIC HEADER ---
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet
                          ? 32.0
                          : width * 0.03, // Synced horizontal padding
                      vertical: 24.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CONTROL PANEL",
                              style: TextStyle(
                                color: AppColor.yellow,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Settings",
                              style: TextStyle(
                                color: AppColor.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColor.containerColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.display_settings_rounded,
                            color: AppColor.yellow,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- MAIN SCROLLABLE CONTENT AREA ---
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet
                            ? 32.0
                            : width * 0.03, // Synced horizontal padding
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          // --- 1. PREFERENCES: SPLIT STAGGERED BLOCKS ---
                          _buildSectionHeader("Preferences"),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedLanguage =
                                          _selectedLanguage == "English"
                                          ? "Urdu"
                                          : "English";
                                    });
                                  },
                                  child: Container(
                                    height: 100,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColor.containerColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Icon(
                                          Icons.language_rounded,
                                          color: AppColor.white,
                                          size: 22,
                                        ),
                                        Text(
                                          _selectedLanguage,
                                          style: const TextStyle(
                                            color: AppColor.yellow,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Container(
                                  height: 100,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColor.containerColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(
                                        Icons.notifications_active_rounded,
                                        color: AppColor.white,
                                        size: 22,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Alerts",
                                            style: TextStyle(
                                              color: AppColor.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Transform.scale(
                                            scale: 0.8,
                                            child: Switch.adaptive(
                                              value: _pushNotifications,
                                              activeColor: AppColor.yellow,
                                              activeTrackColor: AppColor.black,
                                              onChanged: (val) {
                                                setState(() {
                                                  _pushNotifications = val;
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // --- 2. SECURITY & PRIVACY ---
                          _buildSectionHeader("Security & Privacy"),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColor.containerColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.fingerprint_rounded,
                                    color: AppColor.yellow,
                                  ),
                                  title: const Text(
                                    "Biometric Login",
                                    style: TextStyle(
                                      color: AppColor.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: Switch.adaptive(
                                    value: _biometricsEnabled,
                                    activeColor: AppColor.yellow,
                                    activeTrackColor: AppColor.black,
                                    onChanged: (val) {
                                      setState(() {
                                        _biometricsEnabled = val;
                                      });
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Divider(
                                    color: AppColor.black.withValues(
                                      alpha: 0.3,
                                    ),
                                    height: 1,
                                  ),
                                ),
                                _buildListTileRow(
                                  icon: Icons.location_on_rounded,
                                  title: "Location Access",
                                  statusText: "Always On",
                                  statusColor: Colors.greenAccent,
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // --- 3. SYSTEM & MAINTENANCE ---
                          _buildSectionHeader("System & Maintenance"),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColor.containerColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              children: [
                                _buildListTileRow(
                                  icon: Icons.cleaning_services_rounded,
                                  title: "Clear App Cache",
                                  statusText: "24.5 MB",
                                  statusColor: AppColor.white.withValues(
                                    alpha: 0.4,
                                  ),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Cache Cleared"),
                                      ),
                                    );
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Divider(
                                    color: AppColor.black.withValues(
                                      alpha: 0.3,
                                    ),
                                    height: 1,
                                  ),
                                ),
                                _buildListTileRow(
                                  icon: Icons.cloud_done_rounded,
                                  title: "Server Status",
                                  statusText: "Optimal",
                                  statusColor: AppColor.yellow,
                                  onTap: () {},
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // --- 4. APP INFO: COMPACT BORDERLESS TILES ---
                          _buildSectionHeader("App Info"),
                          const SizedBox(height: 16),
                          _buildImpressiveBorderlessRow(
                            icon: Icons.info_outline_rounded,
                            title: "Terms of Service",
                            statusText: "Read",
                            statusColor: AppColor.white.withValues(alpha: 0.4),
                            onTap: () {},
                          ),
                          const SizedBox(height: 12),
                          _buildImpressiveBorderlessRow(
                            icon: Icons.rate_review_rounded,
                            title: "Rate App",
                            statusText: "5 Stars",
                            statusColor: AppColor.yellow,
                            onTap: () {},
                          ),

                          // --- VERSION DATA INSIDE SCROLLVIEW ---
                          const SizedBox(height: 40),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  "RentCar Premium",
                                  style: TextStyle(
                                    color: AppColor.white.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Version 2.0.16 (Stable Build)",
                                  style: TextStyle(
                                    color: AppColor.yellow.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "All rights reserved © 2026",
                                  style: TextStyle(
                                    color: AppColor.white.withValues(
                                      alpha: 0.15,
                                    ),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ), // Balanced scroll bottom padding
                        ],
                      ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          color: AppColor.white.withValues(alpha: 0.4),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTileRow({
    required IconData icon,
    required String title,
    required String statusText,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColor.white, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColor.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColor.white.withValues(alpha: 0.2),
            size: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildImpressiveBorderlessRow({
    required IconData icon,
    required String title,
    required String statusText,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        child: Row(
          children: [
            Container(
              width: 3.5,
              height: 24,
              decoration: BoxDecoration(
                color: statusColor == AppColor.yellow
                    ? AppColor.yellow
                    : AppColor.containerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),
            Icon(icon, color: AppColor.white.withValues(alpha: 0.8), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColor.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColor.white.withValues(alpha: 0.15),
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}
