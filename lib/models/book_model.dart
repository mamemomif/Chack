class Book {
  final String id;
  final String title;
  final String author;
  final String publisher;    // 출판사 필드 추가
  final String isbn;
  String availability;
  String closestLibrary;
  final String imageUrl;
  final DateTime updatedAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,  // 출판사 필드 필수로 변경
    required this.isbn,
    this.availability = '정보 없음',
    this.closestLibrary = '정보 없음',
    required this.imageUrl,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '제목 없음',
      author: json['author'] ?? '저자 없음',
      publisher: json['publisher'] ?? '',
      isbn: json['isbn'] ?? '',
      availability: json['availability'] ?? '정보 없음',
      closestLibrary: json['closestLibrary'] ?? '정보 없음',
      imageUrl: json['imageUrl'] ?? '',
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'publisher': publisher,
      'isbn': isbn,
      'availability': availability,
      'closestLibrary': closestLibrary,
      'imageUrl': imageUrl,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}