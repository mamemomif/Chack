import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_recommendation_provider.dart';
import '../../services/recommended_books_service.dart';
import '../../services/book_cache_service.dart';
import '../../services/location_service.dart';
import 'book_recommendation_card.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BookRecommendationList extends StatefulWidget {
  final String userId;
  final String age;

  const BookRecommendationList({
    Key? key,
    required this.userId,
    required this.age,
  }) : super(key: key);

  @override
  State<BookRecommendationList> createState() => _BookRecommendationListState();
}

class _BookRecommendationListState extends State<BookRecommendationList> with AutomaticKeepAliveClientMixin {
  late final BookRecommendationProvider provider;
  bool isInitialized = false;

  @override
  bool get wantKeepAlive => true; // 탭 변경 시 상태 유지

  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    if (!isInitialized) {
      await Hive.initFlutter();
      final cacheService = BookCacheService();
      await cacheService.initialize();
      
      provider = BookRecommendationProvider(
        age: widget.age,
        recommendedBooksService: RecommendedBooksService(cacheService: cacheService),
        locationService: LocationService(),
      );
      
      isInitialized = true;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return ChangeNotifierProvider.value(
      value: provider,
      child: Consumer<BookRecommendationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.books.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.books.isEmpty) {
            return const Center(child: Text('추천 도서가 없습니다.'));
          }

          return PageView.builder(
            key: PageStorageKey('book_list_${widget.age}'),
            itemCount: provider.hasMore 
                ? provider.books.length + 1
                : provider.books.length,
            onPageChanged: (index) {
              if (index >= provider.books.length - 2) {
                provider.loadMore();
              }
            },
            itemBuilder: (context, index) {
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
                  key: ValueKey('book_${book.isbn}'),
                  userId: widget.userId,
                  isbn: book.isbn,
                  title: book.title,
                  author: book.author,
                  publisher: book.publisher,
                  distance: book.closestLibrary ?? '정보 없음',
                  availability: book.availability ?? '알 수 없음',
                  imageUrl: book.imageUrl,
                  description: book.description ?? '이 책에 대한 설명이 없습니다.',
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    if (isInitialized) {
      provider.dispose();
    }
    super.dispose();
  }
}