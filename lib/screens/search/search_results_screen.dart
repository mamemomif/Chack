import 'package:flutter/material.dart';
import '../../components/searched_book_list_item.dart';
import '../../components/custom_search_bar.dart';
import '../../constants/colors.dart';
import 'search_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  final String searchText;

  const SearchResultsScreen({
    super.key,
    required this.searchText,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> bookList = [
      {
        'title': '채식주의자',
        'author': '한강',
        'image': 'assets/images/book_cover_1.jpg',
        'library': '한성도서관',
        'publisher': '창비',
        'distance': '2.3km',
        'availability': '대출 가능',
      },
      {
        'title': '토마토 컵라면',
        'author': '차정은',
        'image': 'assets/images/book_cover_2.jpg',
        'library': '중앙도서관',
        'publisher': '부크크(bookk)',
        'distance': '1.8km',
        'availability': '대출 불가',
      },
      {
        'title': '빛의 설계자들',
        'author': '김성훈',
        'publisher': '플레인아카이브',
        'image': 'assets/images/book_cover_3.jpg',
        'library': '서대문도서관',
        'distance': '3.2km',
        'availability': '대출 가능',
      },
      {
        'title': '사랑과 결함',
        'author': '예소연',
        'publisher': '문학동네',
        'image': 'assets/images/book_cover_4.jpg',
        'library': '남산도서관',
        'distance': '4.5km',
        'availability': '대출 불가',
      },
      {
        'title': '지구 끝의 온실',
        'author': '김초엽',
        'publisher': '자이언트북스',
        'image': 'assets/images/book_cover_5.jpg',
        'library': '북서울도서관',
        'distance': '2.7km',
        'availability': '대출 가능',
      },
      {
        'title': '뼈가 자라는 여름',
        'author': '김해경',
        'publisher': '출판사 결',
        'image': 'assets/images/book_cover_6.jpg',
        'library': '강남도서관',
        'distance': '3.1km',
        'availability': '대출 가능',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomSearchBar(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: bookList.length,
                itemBuilder: (context, index) {
                  final book = bookList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SearchedBookListItem(
                          title: book['title']!,
                          author: book['author']!,
                          publisher: book['publisher']!,
                          image: book['image']!,
                          library: book['library']!,
                          distance: book['distance']!,
                          availability: book['availability']!,
                        ),
                        if (index < bookList.length - 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Divider(
                              thickness: 1,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          )
                        else
                          const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
