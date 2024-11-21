import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'dart:async';

class RecentBookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();
  
  Timestamp? _lastAddedAt;  // 마지막으로 본 책의 addedAt 시간
  final _recentBookController = StreamController<({String? imageUrl, String? title})>.broadcast();

  Stream<({String? imageUrl, String? title})> watchRecentBook(String userId) {
    // 스트림 설정
    _firestore
        .collection('userShelf')
        .doc(userId)
        .collection('books')
        .orderBy('addedAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        _logger.d('No recent books found for user: $userId');
        _recentBookController.add((imageUrl: null, title: null));
        return;
      }

      final recentBook = snapshot.docs.first.data();
      final addedAt = recentBook['addedAt'] as Timestamp;

      // 새로운 책이 추가된 경우에만 UI 업데이트
      if (_lastAddedAt == null || addedAt.compareTo(_lastAddedAt!) > 0) {
        _lastAddedAt = addedAt;
        _logger.i('Found recent book: ${recentBook['title']}');

        _recentBookController.add((
          imageUrl: recentBook['image'] as String?,
          title: recentBook['title'] as String?,
        ));
      }
    });

    return _recentBookController.stream;
  }

  // 서비스 정리
  void dispose() {
    _recentBookController.close();
  }
}