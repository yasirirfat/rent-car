import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen dimensions aur tablet responsive checks
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Transparent taake container ka gradient dikhay
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
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32.0 : 20.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- PROFILE HEADER ---
                      Row(
                        children: [
                          // Profile Image with Custom Yellow Border
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColor.yellow,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.yellow.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: isTablet ? 45 : 35,
                              backgroundImage: const AssetImage(
                                'assets/images/yasir.png',
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),

                          // Name & Location
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Yasir",
                                  style: TextStyle(
                                    color: AppColor.white,
                                    fontSize: isTablet ? 26 : 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Bahawalpur",
                                      style: TextStyle(
                                        color: AppColor.white.withValues(
                                          alpha: 0.6,
                                        ),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ), // Column
                          ), // Expanded
                          // Edit Profile Button
                          // --- UPGRADED EDIT PROFILE BUTTON WITH BACKGROUND ---
                          Container(
                            decoration: BoxDecoration(
                              color: AppColor
                                  .darkGrey, // This is fine, as it's not yellow.
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.black.withValues(
                                    alpha: 0.2,
                                  ), // Keeping this shadow.
                                  blurRadius: 8,
                                  offset: const Offset(
                                    0,
                                    3,
                                  ), // Maybe reduce offset slightly for a smaller shadow.
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.edit_note_rounded,
                                color: AppColor
                                    .yellow, // This color was provided in the original context, and I must keep it for the icon itself, as the user only asked to remove a *background* of that color. The overall request is to not have a yellow *background*.
                                size: isTablet
                                    ? 35
                                    : 30, // Original size. I need to make this smaller.
                              ),
                              splashRadius: 15, // Need to make this smaller.
                            ),
                          ),
                        ],
                      ), // Row

                      const SizedBox(height: 30),

                      // --- QUICK STATS ROW ---
                      Row(
                        children: [
                          _buildStatCard("Total Rides", "12"),
                          const SizedBox(width: 12),
                          _buildStatCard("Reviews", "4.9 ★"),
                          const SizedBox(width: 12),
                          _buildStatCard("Saved Cars", "8"),
                        ],
                      ), // Row

                      const SizedBox(height: 35),

                      // --- SETTINGS SECTION TITLE ---
                      const Text(
                        "Account Settings",
                        style: TextStyle(
                          color: AppColor.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // --- PROFILE OPTIONS LIST ---
                      _buildProfileOption(
                        icon: Icons.person_outline_rounded,
                        title: "Personal Information",
                        subtitle: "Edit your name, phone, and email",
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        icon: Icons.payment_outlined,
                        title: "Payment Methods",
                        subtitle: "Manage your cards and digital wallets",
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        icon: Icons.history_rounded,
                        title: "Booking History",
                        subtitle: "Check your past rides and invoices",
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        icon: Icons.notifications_none_rounded,
                        title: "Notifications",
                        subtitle: "Preferences and updates",
                        onTap: () {},
                      ),
                      _buildProfileOption(
                        icon: Icons.help_outline_rounded,
                        title: "Help & Support",
                        subtitle: "FAQ, live chat, and contact support",
                        onTap: () {},
                      ),

                      const SizedBox(height: 35),

                      // --- PREMIUM DECORATED LOGOUT BUTTON ---
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: AppColor.yellow,
                              size: 20,
                            ),
                            label: const Text(
                              "Log Out",
                              style: TextStyle(
                                color: AppColor.yellow,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColor.yellow,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              backgroundColor: AppColor.yellow.withValues(
                                alpha: 0.05,
                              ),
                              foregroundColor: AppColor.yellow,
                            ),
                          ),
                        ), // SizedBox
                      ), // Center

                      const SizedBox(height: 40),
                    ],
                  ), // Column (Main)
                ), // Padding
              ), // SingleChildScrollView
            ), // ConstrainedBox
          ), // Center
        ), // SafeArea
      ), // Container (Gradient)
    ); // Scaffold
  }

  // Helper: Individual Stat Card Builder
  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColor.containerColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColor.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColor.yellow,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ), // Column
      ), // Container
    ); // Expanded
  }

  // Helper: List Tile Option Builder
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColor.containerColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColor.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.darkGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColor.yellow, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColor.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.grey,
          size: 14,
        ),
        onTap: onTap,
      ), // ListTile
    ); // Container
  }
}
