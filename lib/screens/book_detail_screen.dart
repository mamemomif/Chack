import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chack_project/services/bookshelf_service.dart';
import 'package:chack_project/screens/book_review_screen.dart';
import '../../constants/icons.dart';

class BookDetailScreen extends StatefulWidget {
  final String userId;
  final String isbn;
  final String title;
  final String author;
  final String publisher;
  final String image;
  final String description;

  const BookDetailScreen({
    Key? key,
    required this.userId,
    required this.isbn,
    required this.title,
    required this.author,
    required this.publisher,
    required this.image,
    required this.description,
  }) : super(key: key);

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookshelfService _bookshelfService = BookshelfService();
  bool _isInShelf = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBookInShelf();
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
  Widget build(BuildContext context) {
    return Scaffold(
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
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          widget.image,
                          width: 150,
                          height: 200,
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

                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontFamily: "SUITE",
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  Text(
                    '${widget.author} / ${widget.publisher}',
                    style: TextStyle(
                      fontFamily: "SUITE",
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.description,
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isInShelf ? _removeBookFromShelf : _addBookToShelf,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          elevation: 0,
                          minimumSize: const Size(150, 50),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        icon: SvgPicture.asset(
                          _isInShelf ? AppIcons.bookDeleteIcon : AppIcons.bookAddIcon,
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
                          minimumSize: const Size(150, 50),
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
                ],
              ),
            ),
    );
  }
}