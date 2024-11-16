// lib/models/book_search_result.dart
class BookSearchResult {
  final String title;
  final String author;
  final String publisher;
  final String isbn;
  final String description;
  final String imageUrl;
  final int price;
  final String pubDate;

  BookSearchResult({
    required this.title,
    required this.author,
    required this.publisher,
    required this.isbn,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.pubDate,
  });

  factory BookSearchResult.fromJson(Map<String, dynamic> json) {
    return BookSearchResult(
      title: _removeHtmlTags(json['title'] ?? ''),
      author: _removeHtmlTags(json['author'] ?? ''),
      publisher: json['publisher'] ?? '',
      isbn: json['isbn'] ?? '',
      description: _removeHtmlTags(json['description'] ?? ''),
      imageUrl: json['image'] ?? '',
      price: int.tryParse(json['price'] ?? '0') ?? 0,
      pubDate: json['pubdate'] ?? '',
    );
  }

  static String _removeHtmlTags(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}