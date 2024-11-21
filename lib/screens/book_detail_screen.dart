import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chack_project/services/bookshelf_service.dart';
import '../services/recommended_books_service.dart';
import '../services/book_cache_service.dart';
import '../services/library_info_service.dart';
import 'package:chack_project/screens/book_review_screen.dart';
import '../../constants/icons.dart';
import '../../constants/colors.dart';
import 'dart:ui';

class BookDetailScreen extends StatefulWidget {
  final String userId;
  final String isbn;
  final String title;
  final String author;
  final String publisher;
  final String image;
  final String description;

  const BookDetailScreen({
    super.key,
    required this.userId,
    required this.isbn,
    required this.title,
    required this.author,
    required this.publisher,
    required this.image,
    required this.description,
  });

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookshelfService _bookshelfService = BookshelfService();
  bool _isInShelf = false;
  bool _isLoading = true;

  // LibraryInfoProvider 관련 필드 추가
  final LibraryInfoProvider _libraryInfoProvider = LibraryInfoProvider(
    recommendedBooksService: RecommendedBooksService(
      cacheService: BookCacheService(),
    ),
  );
  String _libraryName = '도서관 정보를 불러오는 중입니다...';
  String _libraryDistance = '';
  String _loanStatus = '';

  @override
  void initState() {
    super.initState();
    _checkBookInShelf();
    _initializeLibraryInfo(); // LibraryInfoProvider 초기화 호출
  }

  Future<void> _checkBookInShelf() async {
    final isInShelf = await _bookshelfService.isBookInShelf(
      userId: widget.userId,
      isbn: widget.isbn,
    );
    setState(() {
      _isInShelf = isInShelf;
      _isLoading = false;
    });
  }

  // LibraryInfoProvider 초기화
  Future<void> _initializeLibraryInfo() async {
    await _libraryInfoProvider.setupLocationSubscription(
      isbn: widget.isbn,
      onLibraryNameUpdate: (name) {
        setState(() {
          _libraryName = name;
        });
      },
      onDistanceUpdate: (distance) {
        setState(() {
          _libraryDistance = distance;
        });
      },
      onLoanStatusUpdate: (status) {
        setState(() {
          _loanStatus = status;
        });
      },
      onError: (error) {
        setState(() {
          _libraryName = error;
          _libraryDistance = '';
          _loanStatus = '';
        });
      },
    );
  }

  Future<void> _addBookToShelf() async {
    setState(() {
      _isLoading = true;
    });

    await _bookshelfService.addBookToShelf(
      userId: widget.userId,
      isbn: widget.isbn,
      title: widget.title,
      author: widget.author,
      publisher: widget.publisher,
      image: widget.image,
    );

    setState(() {
      _isInShelf = true;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('책이 서재에 추가되었습니다.')),
      );
    }
  }

  Future<void> _removeBookFromShelf() async {
    setState(() {
      _isLoading = true;
    });

    await _bookshelfService.removeBookFromShelf(
      userId: widget.userId,
      isbn: widget.isbn,
    );

    setState(() {
      _isInShelf = false;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('책이 서재에서 제거되었습니다.')),
      );
    }
  }

  Future<void> _navigateToReviewScreen() async {
    if (!_isInShelf) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 책을 서재에 추가해주세요.')),
      );
      return;
    }

    try {
      final bookDoc = await FirebaseFirestore.instance
          .collection('userShelf')
          .doc(widget.userId)
          .collection('books')
          .doc(widget.isbn)
          .get();

      if (!bookDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('서재에서 책을 찾을 수 없습니다.')),
          );
        }
        return;
      }

      final bookData = bookDoc.data()!;

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewWritingScreen(
              title: widget.title,
              author: widget.author,
              publisher: widget.publisher,
              image: widget.image,
              userId: widget.userId,
              isbn: widget.isbn,
              startedAt: (bookData['startedAt'] as Timestamp).toDate(),
              finishedAt: bookData['finishedAt'] != null
                  ? (bookData['finishedAt'] as Timestamp).toDate()
                  : null,
              readTime: bookData['readTime'] ?? 0,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('책 정보를 불러오는데 실패했습니다.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _libraryInfoProvider.dispose(); // LibraryInfoProvider 리소스 정리
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '책 정보',
            style: TextStyle(
              fontSize: 24,
              fontFamily: "SUITE",
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 500,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              // 배경에 도서 썸네일 추가
                              Positioned(
                                top: -50,
                                bottom: -50,
                                left: 0,
                                right: 0,
                                child: Image.network(
                                  widget.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox(),
                                ),
                              ),
                              // 블러 효과
                              Positioned(
                                top: -50,
                                bottom: -50,
                                left: 0,
                                right: 0,
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.4),
                                  ),
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(10, 25),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          child: Image.network(
                                            widget.image,
                                            width: 170,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                              Icons.book,
                                              size: 150,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 독서 상태 정보 받아와서 읽는 중일 때만 표시
                                      Transform.translate(
                                        offset: const Offset(0, -70),
                                        child: _isInShelf
                                            ? SvgPicture.asset(
                                                AppIcons.bookmarkIcon,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                  AppColors.pointColor,
                                                  BlendMode.srcIn,
                                                ),
                                              )
                                            : const SizedBox(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                height: 30,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white, // 흰색 배경
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      topRight: Radius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: BorderDirectional(
                              bottom: BorderSide(
                                color: Colors.black.withOpacity(0.06),
                                width: 10,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: const TextStyle(
                                      fontFamily: "SUITE",
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${widget.author} / ${widget.publisher}',
                                    style: TextStyle(
                                      fontFamily: "SUITE",
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // LibraryInfoProvider 출력
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.05),
                              borderRadius:
                                  BorderRadiusDirectional.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '근처 도서관 보유 현황',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Text(
                                        _libraryName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Text(
                                        '($_libraryDistance)',
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadiusDirectional.circular(
                                                  30),
                                          border: Border.all(
                                            color: _loanStatus == '대출 가능'
                                                ? Colors.black.withOpacity(0.2)
                                                : AppColors.errorColor
                                                    .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: _loanStatus == '대출 가능'
                                                    ? Colors.black
                                                        .withOpacity(0.4)
                                                    : AppColors.errorColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                            const SizedBox(width: 7),
                                            Text(
                                              _loanStatus,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: _loanStatus == '대출 가능'
                                                    ? Colors.black
                                                        .withOpacity(0.5)
                                                    : AppColors.errorColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '책 소개',
                                    style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        size: 14,
                                        color: Colors.black.withOpacity(0.2),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '네이버 도서 API에서 제공하는 정보입니다.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black.withOpacity(0.3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                widget.description,
                                style: TextStyle(
                                  fontFamily: "SUITE",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  height: 1.5,
                                  color: Colors.black.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 25, right: 25, bottom: 30, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isInShelf
                              ? _removeBookFromShelf
                              : _addBookToShelf,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            foregroundColor: Colors.black,
                            elevation: 0,
                            minimumSize: const Size(160, 50),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          icon: SvgPicture.asset(
                            _isInShelf
                                ? AppIcons.bookDeleteIcon
                                : AppIcons.bookAddIcon,
                          ),
                          label: Text(
                            _isInShelf ? '책장에서 빼기' : '책장에 추가하기',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'SUITE',
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _navigateToReviewScreen,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(170, 50),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
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
                  ),
                )
              ],
            ),
    );
  }
}
