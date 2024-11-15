import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../models/book_model.dart';
import 'dart:convert';

class BookCacheService {
  static const String _booksBoxName = 'books_box';
  static const String _libraryInfoBoxName = 'library_info_box';
  static const String _pageInfoBoxName = 'page_info_box';
  static const Duration _booksCacheExpiration = Duration(hours: 24);
  static const Duration _libraryInfoExpiration = Duration(hours: 1);
  
  late Box<String> _booksBox;
  late Box<String> _libraryInfoBox;
  late Box<String> _pageInfoBox;
  
  static final BookCacheService _instance = BookCacheService._internal();
  factory BookCacheService() => _instance;
  BookCacheService._internal();

  Future<void> initialize() async {
    _booksBox = await Hive.openBox<String>(_booksBoxName);
    _libraryInfoBox = await Hive.openBox<String>(_libraryInfoBoxName);
    _pageInfoBox = await Hive.openBox<String>(_pageInfoBoxName);
    await _cleanExpiredCache();
  }

  Future<void> _cleanExpiredCache() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Clean expired books
    final booksExpiration = now - _booksCacheExpiration.inMilliseconds;
    await _cleanExpiredEntries(_booksBox, booksExpiration);
    
    // Clean expired library info
    final libraryExpiration = now - _libraryInfoExpiration.inMilliseconds;
    await _cleanExpiredEntries(_libraryInfoBox, libraryExpiration);
  }

  Future<void> _cleanExpiredEntries(Box<String> box, int expirationTime) async {
    final keysToDelete = box.keys.where((key) {
      if (!key.endsWith('_timestamp')) return false;
      final timestamp = int.tryParse(box.get(key) ?? '0') ?? 0;
      return timestamp < expirationTime;
    }).map((key) => key.replaceAll('_timestamp', '')).toList();
    
    await box.deleteAll([...keysToDelete, ...keysToDelete.map((k) => '${k}_timestamp')]);
  }

  Future<List<Book>> getCachedBooksPage(String age, int pageNumber, int pageSize) async {
    final cacheKey = 'books_${age}_page_$pageNumber';
    final booksJson = _booksBox.get(cacheKey);
    
    if (booksJson != null) {
      final timestamp = int.tryParse(_booksBox.get('${cacheKey}_timestamp') ?? '0') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (now - timestamp < _booksCacheExpiration.inMilliseconds) {
        try {
          final List<dynamic> decoded = json.decode(booksJson);
          return decoded.map((json) => Book.fromJson(json)).toList();
        } catch (e) {
          await _booksBox.delete(cacheKey);
          return [];
        }
      }
    }
    return [];
  }

  Future<void> cacheBooksPage(String age, int pageNumber, List<Book> books) async {
    final cacheKey = 'books_${age}_page_$pageNumber';
    final booksJson = json.encode(books.map((book) => book.toJson()).toList());
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    await _booksBox.put(cacheKey, booksJson);
    await _booksBox.put('${cacheKey}_timestamp', timestamp);
    
    // Store page info
    await _pageInfoBox.put('last_page_$age', pageNumber.toString());
  }

  Future<List<Map<String, dynamic>>> getCachedLibraryInfoBatch(List<String> isbns) async {
    final results = <Map<String, dynamic>>[];
    final now = DateTime.now().millisecondsSinceEpoch;
    
    for (final isbn in isbns) {
      final libraryInfo = _libraryInfoBox.get(isbn);
      final timestamp = int.tryParse(_libraryInfoBox.get('${isbn}_timestamp') ?? '0') ?? 0;
      
      if (libraryInfo != null && now - timestamp < _libraryInfoExpiration.inMilliseconds) {
        results.add(json.decode(libraryInfo));
      }
    }
    
    return results;
  }

  Future<void> cacheLibraryInfoBatch(Map<String, Map<String, dynamic>> libraryInfoMap) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    
    for (final entry in libraryInfoMap.entries) {
      await _libraryInfoBox.put(entry.key, json.encode(entry.value));
      await _libraryInfoBox.put('${entry.key}_timestamp', timestamp);
    }
  }

  Future<int?> getLastPageNumber(String age) async {
    final lastPage = _pageInfoBox.get('last_page_$age');
    return lastPage != null ? int.tryParse(lastPage) : null;
  }

  Future<void> clearCache() async {
    await _booksBox.clear();
    await _libraryInfoBox.clear();
    await _pageInfoBox.clear();
  }

  Future<void> dispose() async {
    await _booksBox.close();
    await _libraryInfoBox.close();
    await _pageInfoBox.close();
  }
}