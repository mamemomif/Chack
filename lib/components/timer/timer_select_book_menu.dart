import 'package:flutter/material.dart';

class BookSelectionModal extends StatelessWidget {
  final Function(Map<String, String>) onBookSelected;
  final VoidCallback onResetSelection; // 선택 초기화 콜백 추가

  const BookSelectionModal({
    Key? key,
    required this.onBookSelected,
    required this.onResetSelection,
  }) : super(key: key);

  final List<Map<String, String>> books = const [
    {"title": "토마토 케첩", "author": "차정은"},
    {"title": "영화 보고 오는 길에 글을...", "author": "김종억"},
    {"title": "팬데믹", "author": "김초엽 외 6인"},
    {"title": "뼈가 자라는 여름", "author": "김해경"},
    {"title": "지구 끝의 온실", "author": "김초엽"},
    {"title": "빛의 설계자들", "author": "김성욱"},
    {"title": "채식주의자", "author": "한강"},
  ];

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
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.teal),
                  title: Text(
                    book["title"]!,
                    style: TextStyle(fontFamily:'SUITE',  fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(book["author"]!),
                  trailing: Icon(Icons.check, color: Colors.grey),
                  onTap: () => onBookSelected(book), // 책을 선택했을 때 콜백 호출
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              onResetSelection(); // 선택 초기화 콜백 호출
              Navigator.pop(context); // 모달을 닫음
            },
            child: const Text(
              "기록할 도서 선택하기 버튼으로 돌아가기",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
