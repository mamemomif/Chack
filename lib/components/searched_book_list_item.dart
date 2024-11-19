import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/bookcover_styles.dart';
import '../screens/book_detail_screen.dart';  // BookCoverStyle import

class SearchedBookListItem extends StatelessWidget {
  final String userId; // 추가
  final String isbn; // 추가
  final String title;
  final String author;
  final String publisher;
  final String image;
  final String library;
  final String distance;
  final String availability;
  final String description;

  const SearchedBookListItem({
    super.key,
    required this.userId, // 추가
    required this.isbn, // 추가
    required this.title,
    required this.author,
    required this.publisher,
    required this.image,
    required this.library,
    required this.distance,
    required this.availability,
    required this.description, // 생성자에 추가
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 책 표지
            BookCover(
              style: BookCoverStyles.medium,
              imageUrl: image,
            ),
            const SizedBox(width: 16),

            // 책 제목, 저자 / 출판사, 도서관 정보, 버튼
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SUITE',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$author / $publisher',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black.withOpacity(0.6),
                      fontFamily: 'SUITE',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          library,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            fontFamily: 'SUITE',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        distance,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          fontFamily: 'SUITE',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        availability,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'SUITE',
                          color: availability == '대출 가능'
                              ? AppColors.pointColor
                              : AppColors.errorColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BookDetailScreen(
                              userId: userId, // userId 전달
                              isbn: isbn, // isbn 전달
                              title: title,
                              author: author,
                              publisher: publisher,
                              image: image,
                              description: description, // 검색 결과의 설명 데이터 전달
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                      ),
                      child: const Text(
                        '책 정보 보기',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'SUITE',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
