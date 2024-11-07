import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/book_model.dart';
import '../models/api_exception.dart';
import 'library_service.dart';

// To print log
import 'dart:developer' as developer;

class RecommendedBooksService {
  final LibraryService _libraryService = LibraryService();
  final String baseUrl = "http://data4library.kr/api";
  final String authKey = dotenv.env['LIBRARY_DATANARU_API_KEY']!;

  Future<List<Book>> fetchRecommendedBooks(Position userLocation) async {
    try {
      developer.log('추천 도서 검색 시작');

      final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
      final String searchDt = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

      final url = Uri.parse(
        "$baseUrl/hotTrend?"
        "authKey=$authKey"
        "&searchDt=$searchDt"
        "&format=json"
      );
      developer.log('Hot trend API request: $url');

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw ApiException('추천 도서 조회 시간 초과'),
      );

      developer.log('추천 도서 API 응답: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (!jsonData.containsKey('response') || 
            !jsonData['response'].containsKey('results') ||
            jsonData['response']['results'].isEmpty) {
          throw ApiException('올바르지 않은 응답 데이터');
        }

        final List<Book> books = [];
        
        for (var result in jsonData['response']['results']) {
          final resultDate = result['result']['date'];
          
          if (resultDate == searchDt) {
            final List<dynamic>? docs = result['result']['docs'];
            
            if (docs != null && docs.isNotEmpty) {
              final bookFutures = docs.map((bookData) async {
                try {
                  final doc = bookData['doc'];
                  final String isbn = doc['isbn13'] ?? '';

                  if (isbn.isEmpty) {
                    developer.log('ISBN 정보 없음');
                    return null;
                  }

                  // 제목 파싱 - ':'을 기준으로 앞의 책 이름만 추출
                  final String rawTitle = doc['bookname'] ?? '제목 없음';
                  final String title = rawTitle.split(':').first;

                  // 저자 파싱 - '지은이:' 이후 저자명만 추출하고 ';'로 분리된 경우 첫 부분만 사용
                  final String rawAuthor = doc['authors'] ?? '저자 미상';
                  String author = rawAuthor.split('지은이:').last;
                  author = author.split(';').first.trim();

                  // 출판사 파싱
                  final String publisher = doc['publisher'] ?? '출판사 미상';
                  final String authorWithPublisher = '$author / $publisher';

                  final libraries = await _libraryService.fetchLibrariesWithBook(isbn, userLocation);

                  return Book(
                    title: title,
                    author: authorWithPublisher,
                    publisher: doc['publisher'] ?? '출판사 미상',
                    isbn: isbn,
                    imageUrl: doc['bookImageURL'] ?? 'assets/images/placeholder.png',
                    availability: libraries.isNotEmpty ? '대출 가능' : '대출 불가',
                    closestLibrary: libraries.isNotEmpty 
                        ? '${libraries[0]['name']} (${(libraries[0]['distance'] / 1000).toStringAsFixed(1)}km)'
                        : '근처에 도서 없음',
                  );
                } catch (e) {
                  developer.log('도서 정보 처리 중 오류 발생', error: e);
                  return null;
                }
              }).toList();

              books.addAll((await Future.wait(bookFutures))
                  .where((book) => book != null)
                  .cast<Book>()
                  .toList());
            }
          }
        }

        books.sort((a, b) {
          if (a.availability == '대출 가능' && b.availability != '대출 가능') return -1;
          if (a.availability != '대출 가능' && b.availability == '대출 가능') return 1;
          return 0;
        });

        developer.log('검색된 도서 수: ${books.length}');
        return books;
      } else {
        throw ApiException('도서 정보 조회 실패', statusCode: response.statusCode);
      }
    } catch (e) {
      developer.log('추천 도서 검색 오류', error: e);
      if (e is ApiException) rethrow;
      throw ApiException('도서 정보 조회 실패: $e');
    }
  }
}