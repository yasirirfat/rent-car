import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rent_car/core/app_color.dart';

class CarCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    print("Paint Called : $size");
    var Size(:height, :width) = size;
    final radius = min(width / 2, height / 2);
    final paint = Paint()
      ..color = AppColor.containerColor
      ..style = PaintingStyle.fill;
    final circlePaint = Paint()
      ..color = AppColor.yellow
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, height * 0.1);
    path.lineTo(0, height * 0.9);
    path.quadraticBezierTo(0, height, width * 0.05, height);
    path.lineTo(width * 0.855, height);
    path.quadraticBezierTo(width * 0.875, height, width * 0.875, height * 0.9);
    path.quadraticBezierTo(
      width * 0.87,
      height * 0.74,
      width * 0.92,
      height * 0.74,
    );
    path.lineTo(width * 0.95, height * 0.74);
    path.quadraticBezierTo(width, height * 0.74, width, height * 0.65);
    path.lineTo(width, height * 0.1);
    path.quadraticBezierTo(width, 0, width * 0.95, 0);
    path.lineTo(width * 0.05, 0);
    path.quadraticBezierTo(0, 0, 0, height * 0.1);

    canvas.drawPath(path, paint);

    canvas.drawCircle(
      Offset(width * 0.93, height * 0.88),
      radius * 0.24,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
