import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../components/bookshelf_book_card.dart';
import '../components/filter_bottom_sheet.dart';

class BookshelfScreen extends StatefulWidget {
  const BookshelfScreen({super.key});

  @override
  State<BookshelfScreen> createState() => _BookshelfScreenState();
}

// 필터 옵션 리스트
class _BookshelfScreenState extends State<BookshelfScreen> {
  final List<String> _filterOptions = ['전체', '읽기 전', '읽는 중', '다 읽음'];
  String _selectedFilter = '전체';

  // 샘플 책 데이터
  final List<Map<String, String>> _books = List.generate(
    10,
    (index) => {
      'title': '책 제목 $index',
      'author': '지은이 $index',
      'status': index % 3 == 0
          ? '읽기 전'
          : index % 3 == 1
              ? '읽는 중'
              : '다 읽음',
    },
  );

  List<Map<String, String>> get filteredBooks {
    if (_selectedFilter == '전체') {
      return _books;
    }
    return _books.where((book) => book['status'] == _selectedFilter).toList();
  }

  // 필터 바텀시트 표시
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        // 책 리스트 그리드 뷰
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
            return BookshelfBookCard(
              title: book['title']!,
              author: book['author']!,
              status: book['status']!,
            );
          },
        ),
      ),
    );
  }
}
