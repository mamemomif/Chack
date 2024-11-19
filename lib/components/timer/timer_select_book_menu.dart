import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/bookshelf_service.dart';
import '../../models/bookshelf_model.dart';

class BookSelectionModal extends StatefulWidget {
  final Function(Map<String, String>) onBookSelected;
  final VoidCallback onResetSelection;
  final String userId;

  const BookSelectionModal({
    Key? key,
    required this.onBookSelected,
    required this.onResetSelection,
    required this.userId,
  }) : super(key: key);

  @override
  State<BookSelectionModal> createState() => _BookSelectionModalState();
}

class _BookSelectionModalState extends State<BookSelectionModal> {
  final BookshelfService _bookshelfService = BookshelfService();
  String _searchQuery = '';

  Future<void> _handleBookSelection(BookshelfBook book) async {
    if (book.status == '읽기 전') {
      await _bookshelfService.updateBookStatus(
        userId: widget.userId,
        isbn: book.isbn,
        newStatus: '읽는 중',
      );
    }

    widget.onBookSelected({
      'title': book.title,
      'author': book.author,
      'isbn': book.isbn,
      'imageUrl': book.imageUrl,
      'status': '읽는 중',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: '읽고 싶은 책을 알려주세요',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<BookshelfBook>>(
              stream: _bookshelfService.fetchBookshelf(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final books = snapshot.data ?? [];
                
                final filteredBooks = books.where((book) => 
                  (book.status == '읽기 전' || book.status == '읽는 중') &&
                  (book.title.toLowerCase().contains(_searchQuery.toLowerCase()) || book.author.toLowerCase().contains(_searchQuery.toLowerCase()))
                ).toList();

                if (filteredBooks.isEmpty) {
                  return const Center(
                    child: Text(
                      '선택 가능한 책이 없습니다.\n서재에서 책을 추가해주세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SUITE',
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          book.imageUrl,
                          width: 40,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.book, size: 40, color: Colors.grey),
                        ),
                      ),
                      title: Text(
                        book.title,
                        style: const TextStyle(
                          fontFamily: 'SUITE',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.author),
                          Text(
                            book.status,
                            style: TextStyle(
                              color: book.status == '읽기 전' ? Colors.blue : Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () => _handleBookSelection(book),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              widget.onResetSelection();
              Navigator.pop(context);
            },
            child: const Text(
              "기록할 도서 선택하기 버튼으로 돌아가기",
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'SUITE',
              ),
            ),
          ),
        ],
      ),
    );
  }
}