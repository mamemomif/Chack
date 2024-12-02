// lib/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // 기본 색상
  static const Color primary = Colors.black;
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF000000);

  // 포인트 색상
  static const Color pointColor = Color(0xFF59BFAE);
  static const Color activeReadingColor = Color(0xFFFF9C56);
  static const Color unreadColor = Color(0xFF9D9D9D);

  // 상태 색상
  static const Color errorColor = Color(0xFFFF5353);

  // 투명도가 있는 색상
  static Color textFieldBackground = Colors.black.withOpacity(0.05);
  static Color hintTextColor = Colors.black.withOpacity(0.3);
  static Color subTextColor = Colors.black.withOpacity(0.5);
  static Color borderColor = Colors.black.withOpacity(0.3);
}
