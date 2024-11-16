// screens/book_recommendation_list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_recommendation_provider.dart';
import '../../services/recommended_books_service.dart';
import '../../services/book_cache_service.dart';
import '../../services/location_service.dart';
import 'book_recommendation_card.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BookRecommendationList extends StatelessWidget {
  final String userId;
  final String age;

  const BookRecommendationList({
    Key? key,
    required this.userId,
    required this.age,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cacheService = BookCacheService();
    final locationService = LocationService();

    return FutureBuilder(
      future: Hive.initFlutter().then((_) => cacheService.initialize()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ChangeNotifierProvider(
          create: (_) => BookRecommendationProvider(
            age: age,
            recommendedBooksService: RecommendedBooksService(cacheService: cacheService),
            locationService: locationService,
          ),
          child: Consumer<BookRecommendationProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.books.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.books.isEmpty) {
                return const Center(child: Text('추천 도서가 없습니다.'));
              }

              return PageView.builder(
                itemCount: provider.hasMore 
                    ? provider.books.length + 1  // 추가 페이지를 위한 +1
                    : provider.books.length,
                onPageChanged: (index) {
                  // 마지막 페이지 2개 전에 도달하면 더 로드
                  if (index >= provider.books.length - 2) {
                    provider.loadMore();
                  }
                },
                itemBuilder: (context, index) {
                  // 마지막 아이템이고 더 있다면 로딩 표시
                  if (index == provider.books.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final book = provider.books[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: BookRecommendationCard(
                      title: book.title,
                      author: book.author,
                      publisher: book.publisher,
                      distance: book.closestLibrary ?? '정보 없음',
                      availability: book.availability ?? '알 수 없음',
                      imageUrl: book.imageUrl,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}