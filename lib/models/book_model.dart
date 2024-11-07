class Book {
  final String title;
  final String author;
  final String publisher;
  final String isbn;
  final String imageUrl;
  final String availability;
  final String closestLibrary;

  Book({
    required this.title,
    required this.author,
    required this.publisher,
    required this.isbn,
    required this.imageUrl,
    required this.availability,
    required this.closestLibrary,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      publisher: json['publisher'] ?? '',
      isbn: json['isbn'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      availability: json['availability'] ?? '',
      closestLibrary: json['closestLibrary'] ?? '',
    );
  }

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'publisher': publisher,
      'isbn': isbn,
      'imageUrl': imageUrl,
      'availability': availability,
      'closestLibrary': closestLibrary,
    };
  }
}
