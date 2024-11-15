// providers/book_recommendation_provider.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import '../services/recommended_books_service.dart';
import '../services/location_service.dart';
import '../models/book_model.dart';

class BookRecommendationProvider with ChangeNotifier {
  final RecommendedBooksService _recommendedBooksService;
  final LocationService _locationService;
  final Logger _logger = Logger();
  final String age;
  final int pageSize;
  
  List<Book> _books = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  Position? _currentPosition;
  bool _isInitialized = false;
  Timer? _libraryUpdateTimer;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  BookRecommendationProvider({
    required this.age,
    required RecommendedBooksService recommendedBooksService,
    required LocationService locationService,
    this.pageSize = 10,
  })  : _recommendedBooksService = recommendedBooksService,
        _locationService = locationService {
    _init();
  }

  Future<void> _init() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      _logger.i("Initializing BookRecommendationProvider for age group $age");
      
      // 먼저 캐시된 책 데이터를 로드
      _logger.i("Loading cached books");
      await _loadCachedBooks();

      // 위치 정보 초기화 및 도서관 정보 업데이트
      await _initializeLocation();

      _isInitialized = true;
    } catch (e, stackTrace) {
      _logger.e("Error initializing BookRecommendationProvider", e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCachedBooks() async {
    final cachedBooks = await _recommendedBooksService.fetchRecommendedBooks(
      age,
      pageSize,
      page: _currentPage,
    );

    if (cachedBooks.isNotEmpty) {
      _books = cachedBooks;
      _currentPage = (_books.length / pageSize).floor();
      notifyListeners();
    }
  }

  Future<void> _initializeLocation() async {
    try {
      //첫 위치 정보 가져오기
      _currentPosition = await _locationService.getCurrentLocation();
      _logger.i("Current location aquired: Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}");

      if (_currentPosition != null && _books.isNotEmpty) {
        await _updateLibraryInfo();
      }

      _locationService.positionStream.listen(
        (position) {
          if (_shouldUpdateLocation(position)) {
            _currentPosition = position;
            _logger.i("Location updated: Latitude: ${position.latitude}, Longitude: ${position.longitude}");
            _updateLibraryInfo();
          }
        },
      );
    } catch (e, stackTrace) {
      _logger.e("Error initializing location", e, stackTrace);

      if (_books.isEmpty) {
        await _loadCachedBooks();
      }
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final newBooks = await _recommendedBooksService.fetchRecommendedBooks(
        age,
        pageSize,
        page: _currentPage,
      );

      if (newBooks.isEmpty) {
        _hasMore = false;
      } else {
        _books.addAll(newBooks);
        _currentPage++;

        if (_currentPosition != null) {
          // 새로 로드된 책들의 도서관 정보만 업데이트
          await _updateLibraryInfoForBooks(newBooks);
        }
      }
    } catch (e, stackTrace) {
      _logger.e("Error loading more books", e, stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _shouldUpdateLocation(Position newPosition) {
    if (_currentPosition == null) return true;

    final distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );
    
    return distance > 100; // 100m 이상 이동했을 때만 업데이트
  }

  Future<void> _updateLibraryInfo() async {
    if (_books.isEmpty || _currentPosition == null) return;
    
    try {
      await _updateLibraryInfoForBooks(_books);
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.e("Error updating library info", e, stackTrace);
    }
  }

  Future<void> _updateLibraryInfoForBooks(List<Book> books) async {
    final futures = books.map((book) async {
      try {
        final libraryInfo = await _recommendedBooksService.fetchLibrary(
          book.isbn,
          _currentPosition!,
        );

        if (libraryInfo != null) {
          book.availability = libraryInfo['loanAvailable'] == 'Y'
              ? '대출 가능'
              : '대출 불가';

          double distanceKm = libraryInfo['distance'] / 1000;
          book.closestLibrary =
              '${libraryInfo['name']} (${distanceKm.toStringAsFixed(1)}km)';
        } else {
          book.availability = '정보 없음';
          book.closestLibrary = '주변 도서관 정보 없음';
        }
      } catch (e) {
        _logger.w("Failed to update library info for book ${book.isbn}", e);
      }
    }).toList();

    await Future.wait(futures);
  }

  @override
  void dispose() {
    _libraryUpdateTimer?.cancel();
    super.dispose();
  }
}