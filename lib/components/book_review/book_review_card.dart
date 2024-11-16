import 'package:flutter/material.dart';
import '../../constants/colors.dart';
class BookReviewCard extends StatefulWidget {
  const BookReviewCard({Key? key}) : super(key: key);

  @override
  _BookReviewCard createState() => _BookReviewCard();
}

class _BookReviewCard extends State<BookReviewCard> {
  bool _isEditing = false; // 수정 상태 여부
  String _reviewText = '책 읽은 후 소감을 알려주세요.'; // 초기 텍스트
  int _rating = 3; // 초기 별점 (0~5 범위)

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = _reviewText; // 초기 값 설정
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 내 별점 타이틀 + 별점 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      '내 별점',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFamily: "SUITE",
                        fontSize: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8), // 간격 추가
                    Row(
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: _isEditing
                              ? () {
                            setState(() {
                              _rating = index + 1; // 클릭한 별점 설정
                            });
                          }
                              : null, // 수정 상태가 아니면 클릭 이벤트 비활성화
                          child: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: AppColors.pointColor,
                            size: 24, // 별 크기
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_isEditing) {
                        _reviewText = _controller.text; // 입력값 저장
                      }
                      _isEditing = !_isEditing; // 수정 상태 토글
                    });
                  },
                  icon: Icon(
                    _isEditing ? Icons.check : Icons.edit,
                    color: _isEditing ? Colors.teal : Colors.grey,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 독후감 입력 또는 표시
            _isEditing
                ? TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '독후감을 작성하세요.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),

                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.unreadColor),
                ),

              ),
              onSubmitted: (value) {
                setState(() {
                  _reviewText = value;
                  _isEditing = false; // 입력 후 수정 상태 종료
                });
              },
            )
                : Text(
              _reviewText,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: "SUITE",
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
