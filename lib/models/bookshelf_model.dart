// models/bookshelf_book.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BookshelfBook {
  final String isbn;
  final String title;
  final String author;
  final String publisher;
  final String imageUrl;
  final String status;
  final DateTime addedAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  BookshelfBook({
    required this.isbn,
    required this.title,
    required this.author,
    required this.publisher,
    required this.imageUrl,
    required this.status,
    required this.addedAt,
    this.startedAt,
    this.finishedAt,
  });

  factory BookshelfBook.fromFirestore(Map<String, dynamic> data) {
    return BookshelfBook(
      isbn: data['isbn'] ?? '',
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      publisher: data['publisher'] ?? '',
      imageUrl: data['image'] ?? '',
      status: data['status'] ?? '읽기 전',
      addedAt: (data['addedAt'] as Timestamp).toDate(),
      startedAt: data['startedAt'] != null 
          ? (data['startedAt'] as Timestamp).toDate() 
          : null,
      finishedAt: data['finishedAt'] != null 
          ? (data['finishedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'isbn': isbn,
      'title': title,
      'author': author,
      'publisher': publisher,
      'image': imageUrl,
      'status': status,
      'addedAt': Timestamp.fromDate(addedAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'finishedAt': finishedAt != null ? Timestamp.fromDate(finishedAt!) : null,
    };
  }
}
