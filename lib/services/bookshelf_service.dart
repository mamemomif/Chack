import 'package:cloud_firestore/cloud_firestore.dart';

class BookshelfService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 사용자의 서재에 책 추가
  Future<void> addBookToShelf({
    required String userId,
    required String isbn,
    required String title,
    required String author,
    required String publisher,
    required String image,
  }) async {
    final userShelfRef = _firestore
        .collection('userShelf') // 최상위 컬렉션
        .doc(userId) // 사용자 문서
        .collection('books'); // 하위 컬렉션

    await userShelfRef.doc(isbn).set({
      'isbn': isbn,
      'title': title,
      'author': author,
      'publisher': publisher,
      'image': image,
      'status': '읽기 전', // 초기 상태
      'addedAt': Timestamp.now(), // 추가된 시간
      'startedAt': null, // 읽기 시작한 시간
      'finishedAt': null, // 읽기 완료 시간
    });
  }

  /// 사용자의 서재에서 책 삭제
  Future<void> removeBookFromShelf({
    required String userId,
    required String isbn,
  }) async {
    final userShelfRef = _firestore
        .collection('userShelf')
        .doc(userId)
        .collection('books');

    await userShelfRef.doc(isbn).delete();
  }

  /// 사용자의 서재에 책이 있는지 확인
  Future<bool> isBookInShelf({
    required String userId,
    required String isbn,
  }) async {
    final userShelfRef = _firestore
        .collection('userShelf')
        .doc(userId)
        .collection('books');

    final doc = await userShelfRef.doc(isbn).get();
    return doc.exists; // 데이터가 존재하면 true 반환
  }

  /// 사용자의 서재에서 책 데이터를 실시간으로 가져오기
  Stream<List<Map<String, dynamic>>> fetchBookshelf(String userId) {
    return _firestore
        .collection('userShelf')
        .doc(userId)
        .collection('books')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
