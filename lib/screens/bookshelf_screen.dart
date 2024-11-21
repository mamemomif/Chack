import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/bookshelf_service.dart';
import '../services/book_search_service.dart'; // ISBN 검색 서비스
import '../models/bookshelf_model.dart';
import '../components/bookshelf_book_card.dart';
import '../components/filter_bottom_sheet.dart';
import '../screens/book_detail_screen.dart';
import '../screens/search/search_screen.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';
import '../constants/text_styles.dart';

class BookshelfScreen extends StatefulWidget {
  final String userId;

  const BookshelfScreen({
    super.key,
    required this.userId,
  });

  @override
  State<BookshelfScreen> createState() => _BookshelfScreenState();
}

class _BookshelfScreenState extends State<BookshelfScreen> {
  final BookshelfService _bookshelfService = BookshelfService();
  final BookSearchService _bookSearchService =
      BookSearchService(); // ISBN 검색 서비스
  final List<String> _filterOptions = ['전체', '읽기 전', '읽는 중', '다 읽음'];
  String _selectedFilter = '전체';

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterBottomSheet(
        filterOptions: _filterOptions,
        selectedFilter: _selectedFilter,
        onFilterSelected: (filter) {
          setState(() {
            _selectedFilter = filter;
          });
        },
      ),
    );
  }

  Future<void> _navigateToDetail(
      BuildContext context, BookshelfBook book) async {
    try {
      // ISBN으로 책 설명 검색
      final bookSearchResult =
          await _bookSearchService.searchBookByISBN(book.isbn);

      if (bookSearchResult != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailScreen(
              userId: widget.userId,
              isbn: book.isbn,
              title: book.title,
              author: book.author,
              publisher: book.publisher,
              image: book.imageUrl,
              description: bookSearchResult.description, // 가져온 책 설명 전달
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('책 설명을 불러올 수 없습니다.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('책 정보를 불러오는 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '서재',
                  style: AppTextStyles.titleStyle,
                ),
              ),
              GestureDetector(
                onTap: () => _showFilterBottomSheet(context),
                child: Row(
                  children: [
                    Text(
                      _selectedFilter,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<BookshelfBook>>(
        stream: _bookshelfService.fetchBookshelf(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data ?? [];
          final filteredBooks = _selectedFilter == '전체'
              ? books
              : books.where((book) => book.status == _selectedFilter).toList();

          if (filteredBooks.isEmpty) {
            return Center(
                child: Column(
              children: [
                const SizedBox(height: 110),
                SvgPicture.asset(
                  AppIcons.emptyBookshelfIcon,
                  width: 190,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  '서재가 비어 있어요',
                  style: AppTextStyles.titleStyle,
                ),
                const SizedBox(height: 15),
                Text(
                  '읽고 싶은 책을 검색하고\n서재에 책을 추가해보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(
                            userId: widget.userId, // userId 전달
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0)),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '책 검색하기',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 5)
                      ],
                    ),
                  ),
                ),
              ],
            ));
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              itemCount: filteredBooks.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: (80 / 122) * 0.9,
                crossAxisSpacing: 14,
                mainAxisSpacing: 20,
              ),
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return GestureDetector(
                  onTap: () => _navigateToDetail(context, book), // 상세 페이지 이동
                  child: BookshelfBookCard(
                    imageUrl: book.imageUrl,
                    title: book.title,
                    author: book.author,
                    status: book.status,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
