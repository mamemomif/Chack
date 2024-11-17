import 'package:flutter/material.dart';

class RecentBookPopup extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onClose;
  final String imageUrl; // 이미지 URL
  final String title; // 도서 제목

  const RecentBookPopup({
    super.key,
    required this.isVisible,
    required this.onClose,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      // 팝업 위치와 마진값 설정
      bottom: 15,
      left: 15,
      right: 15,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // 책 이미지
            Positioned(
              left: 35,
              bottom: 0,
              child: Container(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: 60,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 50,
              top: 15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      const Text(
                        '최근에 담은 책',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Text(
                        '독서 시간 기록하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 닫기 버튼
            Positioned(
              right: 0,
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
