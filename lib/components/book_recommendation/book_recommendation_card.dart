// components/book_recommendation/book_recommendation_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../constants/icons.dart';

class BookRecommendationCard extends StatelessWidget {
  final String title;
  final String author;
  final String publisher;
  final String distance;
  final String availability;
  final String imageUrl;

  const BookRecommendationCard({
    Key? key,
    required this.title,
    required this.author,
    required this.publisher,
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
          // 채크의 추천 배지
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
          // 도서 정보
          Positioned(
            left: 20,
            top: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 도서 제목
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
                // 저자 및 출판사
                Text(
                  '$author / $publisher',
                  style: AppTextStyles.authorLabelStyle,
                ),
                const SizedBox(height: 10),
                // 가까운 도서관 및 대출 가능 여부
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
                      style: AppTextStyles.libraryLabelStyle.copyWith(
                        color: availability == '대출 가능' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 도서 이미지
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
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 126,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, color: Colors.grey),
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
