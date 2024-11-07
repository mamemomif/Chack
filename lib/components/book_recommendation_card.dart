import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../constants/icons.dart';

class BookRecommendationCard extends StatelessWidget {
  final String title;
  final String author;
  final String distance;
  final String availability;
  final String imageUrl;

  const BookRecommendationCard({
    Key? key,
    required this.title,
    required this.author,
    required this.distance,
    required this.availability,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.pointColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.pointColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppIcons.chackIcon,
                    height: 10,
                    width: 10,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '채크의 추천',
                    style: AppTextStyles.labelStyle,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 150,
                  child: Text(
                    title,
                    style: AppTextStyles.titleLabelStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  author,
                  style: AppTextStyles.authorLabelStyle,
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      distance,
                      style: AppTextStyles.libraryLabelStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      availability,
                      style: AppTextStyles.libraryLabelStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 0,
            child: Container(
              width: 90,
              height: 126,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: 90,
                  height: 126,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                    width: 90,
                    height: 126,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
