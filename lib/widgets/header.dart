import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundImage: AssetImage("assets/images/yasir.png"),
        ),

        SizedBox(width: 12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello Yasir",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey, size: 16),

                SizedBox(width: 2),

                Text("bahawalpur", style: TextStyle(color: Colors.grey)),

                Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ],
        ),

        Spacer(),

        Container(
          height: 48,
          width: 48,

          decoration: BoxDecoration(
            color: Color(0xff2B2B2B),
            shape: BoxShape.circle,
            border: Border.all(color: AppColor.white.withValues(alpha: 0.1)),
          ),

          child: Icon(Icons.notifications_none, color: Colors.yellow),
        ),
      ],
    );
  }
}
