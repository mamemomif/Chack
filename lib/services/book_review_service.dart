import 'package:cloud_firestore/cloud_firestore.dart';

class BookReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 리뷰 저장 또는 업데이트
  Future<void> saveBookReview({
    required String userId,
    required String isbn,
    required String review,
    required int rating,
  }) async {
    try {
      final bookRef = _firestore
          .collection('userShelf')
          .doc(userId)
          .collection('books')
          .doc(isbn);

      final docSnapshot = await bookRef.get();
      
      if (docSnapshot.exists) {
        final now = FieldValue.serverTimestamp();
        final updateData = {
          'reviewText': review,
          'reviewRating': rating,
          'reviewUpdatedAt': now,
          'status': '다 읽음',
        };

        // reviewCreatedAt이 없는 경우에만 추가
        if (!docSnapshot.data()!.containsKey('reviewCreatedAt')) {
          updateData['reviewCreatedAt'] = now;
        }

        // finishedAt이 없는 경우에만 추가
        if (!docSnapshot.data()!.containsKey('finishedAt') || 
            docSnapshot.data()!['finishedAt'] == null) {
          updateData['finishedAt'] = now;
        }

        await bookRef.update(updateData);
      } else {
        throw Exception('존재하지 않는 도서입니다.');
      }
    } catch (e) {
      throw Exception('리뷰 저장 중 오류가 발생했습니다: $e');
    }
  }

  // 도서 정보와 리뷰 조회
  Future<Map<String, dynamic>?> getBookReview({
    required String userId,
    required String isbn,
  }) async {
    try {
      final docSnapshot = await _firestore
          .collection('userShelf')
          .doc(userId)
          .collection('books')
          .doc(isbn)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        return {
          // 리뷰 관련 데이터
          'reviewText': data['reviewText'] ?? '',
          'reviewRating': data['reviewRating'] ?? 0,
          'reviewCreatedAt': data['reviewCreatedAt'],
          'reviewUpdatedAt': data['reviewUpdatedAt'],
          
          // 독서 상태 및 시간 관련 데이터
          'status': data['status'],
          'startedAt': data['startedAt'],
          'finishedAt': data['finishedAt'],
          'readTime': data['readTime'] ?? 0,
        };
      }
      return null;
    } catch (e) {
      throw Exception('리뷰 조회 중 오류가 발생했습니다: $e');
    }
  }

  // 리뷰 삭제
  Future<void> deleteBookReview({
    required String userId,
    required String isbn,
  }) async {
    try {
      await _firestore
          .collection('userShelf')
          .doc(userId)
          .collection('books')
          .doc(isbn)
          .update({
        'reviewText': FieldValue.delete(),
        'reviewRating': FieldValue.delete(),
        'reviewCreatedAt': FieldValue.delete(),
        'reviewUpdatedAt': FieldValue.delete(),
        'finishedAt': null,
        'status': '읽는 중',
      });
    } catch (e) {
      throw Exception('리뷰 삭제 중 오류가 발생했습니다: $e');
    }
  }
}