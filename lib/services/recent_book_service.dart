import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class RecentBookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // 실시간 스트림 추가
  Stream<({String? imageUrl, String? title})> watchRecentBook(String userId) {
    return _firestore
        .collection('userShelf')
        .doc(userId)
        .collection('books')
        .orderBy('addedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        _logger.d('No recent books found for user: $userId');
        return (imageUrl: null, title: null);
      }

      final recentBook = snapshot.docs.first.data();
      _logger.i('Found recent book: ${recentBook['title']}');

      return (
        imageUrl: recentBook['image'] as String?,
        title: recentBook['title'] as String?,
      );
    });
  }

  // 기존 메서드 유지
  Future<({String? imageUrl, String? title})> getRecentBook(String userId) async {
    try {
      final bookSnapshot = await _firestore
          .collection('userShelf')
          .doc(userId)
          .collection('books')
          .orderBy('addedAt', descending: true)
          .limit(1)
          .get();

      if (bookSnapshot.docs.isEmpty) {
        _logger.d('No recent books found for user: $userId');
        return (imageUrl: null, title: null);
      }

      final recentBook = bookSnapshot.docs.first.data();
      _logger.i('Found recent book: ${recentBook['title']}');

      return (
        imageUrl: recentBook['image'] as String?,
        title: recentBook['title'] as String?,
      );
    } catch (e) {
      _logger.e('Error getting recent book: $e');
      return (imageUrl: null, title: null);
    }
  }
}