import 'package:flutter/material.dart';
import 'package:chack_project/constants/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/icons.dart';
class BookDetailScreen extends StatelessWidget {
  final String title;
  final String author;
  final String publisher;
  final String image;
  final String description;

  const BookDetailScreen({
    Key? key,
    required this.title,
    required this.author,
    required this.publisher,
    required this.image,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerLeft, // 텍스트를 좌측으로 정렬
          child: Text(
            '책 정보',
            style: TextStyle(
              fontSize: 24,
              fontFamily: "SUITE",
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 29.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 책 이미지
            Center(
              child: Container(
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
                    width: 150,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.book,
                      size: 150,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 제목
            Text(
              title,
              //textAlign: TextAlign.left,
              style: const TextStyle(
                fontFamily: "SUITE",
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),

            // 저자 및 출판사 정보

            Text(
              '$author / $publisher',
              style: TextStyle(
                fontFamily: "SUITE",
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.black.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: 10),

            // 스크롤 가능한 설명
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontFamily: "SUITE",
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 하단 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // 책장에서 빼기 기능 추가
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  icon: SvgPicture.asset(AppIcons.bookDeleteIcon),
                  label: const Text(
                    '책장에서 빼기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SUITE',
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // 독후감 작성 기능 추가
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  icon: SvgPicture.asset(AppIcons.bookReportIcon),
                  label: const Text(
                    '독후감 작성하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SUITE',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
