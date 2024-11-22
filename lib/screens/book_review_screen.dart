import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chack_project/constants/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase import 추가
import '../../constants/icons.dart';
import '../../constants/colors.dart';
import '../components/book_review/book_readingtime_card.dart';
import '../components/book_review/book_review_card.dart';
import '../../services/book_review_service.dart';
import '../constants/icons.dart';

class ReviewWritingScreen extends StatefulWidget {
  // StatelessWidget에서 StatefulWidget으로 변경
  final String title;
  final String author;
  final String publisher;
  final String image;
  final String userId;
  final String isbn;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int readTime;

  const ReviewWritingScreen({
    super.key,
    required this.title,
    required this.author,
    required this.publisher,
    required this.image,
    required this.userId,
    required this.isbn,
    required this.startedAt,
    this.finishedAt,
    required this.readTime,
  });

  @override
  ReviewWritingScreenState createState() => ReviewWritingScreenState();
}

class ReviewWritingScreenState extends State<ReviewWritingScreen> {
  DateTime? _finishedAt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _finishedAt = widget.finishedAt;
    _loadBookData();
  }

  Future<void> _loadBookData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final bookDoc = await FirebaseFirestore.instance
          .collection('userShelf')
          .doc(widget.userId)
          .collection('books')
          .doc(widget.isbn)
          .get();

      if (bookDoc.exists && mounted) {
        setState(() {
          _finishedAt = bookDoc.data()?['finishedAt'] != null
              ? (bookDoc.data()!['finishedAt'] as Timestamp).toDate()
              : null;
        });
      }
    } catch (e) {
      // 에러 처리
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 리뷰 저장 완료 후 호출될 콜백
  void _onReviewSaved() {
    _loadBookData(); // 데이터 리로드
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const SizedBox(width: 10),
              SvgPicture.asset(
                AppIcons.chackIcon,
                width: 30,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${widget.author} / ${widget.publisher}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 책 정보 섹션
            SizedBox(
              height: 450,
              width: double.infinity,
              child: Stack(
                children: [
                  // 이미지
                  Positioned.fill(
                    child: Image.network(
                      widget.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.book,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // 검정색 반투명 상자
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // 독서 정보 카드 - finishedAt 업데이트 반영
            BookReadingtimeCard(
              startedAt: widget.startedAt,
              finishedAt: _finishedAt, // 업데이트된 값 사용
              readTime: widget.readTime,
            ),
            const SizedBox(height: 20),

            // 리뷰 카드 - 콜백 추가
            BookReviewCard(
              userId: widget.userId,
              isbn: widget.isbn,
              onReviewSaved: _onReviewSaved, // 콜백 전달
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
