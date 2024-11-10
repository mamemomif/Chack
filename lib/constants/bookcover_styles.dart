import 'package:chack_project/constants/colors.dart';
import 'package:flutter/material.dart';

class BookCoverStyles {
  static const small = BookCoverStyle(
    width: 80,
    height: 122,
    borderRadius: 14,
    decoration: BoxDecoration(
      color: Color.fromRGBO(200, 200, 200, 1),
      boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.15),
          blurRadius: 15,
          offset: Offset(0, 10),
        ),
      ],
    ),
  );

  static const medium = BookCoverStyle(
    width: 90,
    height: 137,
    borderRadius: 0,
    decoration: BoxDecoration(
      color: Color.fromRGBO(200, 200, 200, 1),
      boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.15),
          blurRadius: 15,
          offset: Offset(0, 10),
        ),
      ],
    ),
  );

  static const large = BookCoverStyle(
    width: 100,
    height: 153,
    borderRadius: 0,
  );

  static const extraLarge = BookCoverStyle(
    width: 160,
    height: 244,
    borderRadius: 0,
  );
}

class BookCoverStyle {
  final double width;
  final double height;
  final double borderRadius;
  final BoxDecoration? decoration;

  const BookCoverStyle({
    required this.width,
    required this.height,
    required this.borderRadius,
    this.decoration,
  });
}

class BookCover extends StatelessWidget {
  final BookCoverStyle style;

  const BookCover({super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: style.width,
      height: style.height,
      decoration: style.decoration?.copyWith(
            borderRadius: BorderRadius.circular(style.borderRadius),
          ) ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(style.borderRadius),
          ),
    );
  }
}
