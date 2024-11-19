import 'package:flutter/material.dart';
import 'package:chack_project/constants/text_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Firebase import 추가
import '../../constants/icons.dart';
import '../../constants/colors.dart';
import '../components/book_review/book_readingtime_card.dart';
import '../components/book_review/book_review_card.dart';
import '../../services/book_review_service.dart';

class ReviewWritingScreen extends StatefulWidget {  // StatelessWidget에서 StatefulWidget으로 변경
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
    Key? key,
    required this.title,
    required this.author,
    required this.publisher,
    required this.image,
    required this.userId,
    required this.isbn,
    required this.startedAt,
    this.finishedAt,
    required this.readTime,
  }) : super(key: key);

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
    _loadBookData();  // 데이터 리로드
  }

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
                        widget.image,
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
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: "SUITE",
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.author} / ${widget.publisher}',
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

              // 독서 정보 카드 - finishedAt 업데이트 반영
              BookReadingtimeCard(
                startedAt: widget.startedAt,
                finishedAt: _finishedAt,  // 업데이트된 값 사용
                readTime: widget.readTime,
              ),
              const SizedBox(height: 20),

              // 리뷰 카드 - 콜백 추가
              BookReviewCard(
                userId: widget.userId,
                isbn: widget.isbn,
                onReviewSaved: _onReviewSaved,  // 콜백 전달
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}