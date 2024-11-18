import 'package:flutter/material.dart';
import 'package:chack_project/constants/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/icons.dart';
import '../../constants/colors.dart';
import '../components/book_review/book_readingtime_card.dart';
import '../components/book_review/book_review_card.dart';

class ReviewWritingScreen extends StatelessWidget {
  final String title;
  final String author;
  final String publisher;
  final String image;

  const ReviewWritingScreen({
    Key? key,
    required this.title,
    required this.author,
    required this.publisher,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '독후감',
            style: TextStyle(
              fontSize: 24,
              fontFamily: "SUITE",
              fontWeight: FontWeight.w800,
              color: AppColors.primary
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 책 정보 섹션
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        image,
                        width: 120,
                        height: 150,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.book,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: "SUITE",
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$author / $publisher',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: "SUITE",
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // 독서 정보 카드
              BookReadingtimeCard(
                startDate: '10월 1일',
                endDate: '10월 31일',
                duration: '30일',
                totalReadingTime: '8시간 5분 23초',
              ),
              const SizedBox(height: 20),

              // 내 별점
              const BookReviewCard(),

              const SizedBox(height: 20),


            ],
          ),
        ),
      ),
    );
  }
}
