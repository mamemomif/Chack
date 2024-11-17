import 'package:flutter/material.dart';
import '../constants/colors.dart';

class MonthlyReadingCard extends StatelessWidget {
  final int daysInMonth; // 해당 월의 일수
  final List<int> readingDays; // 책을 읽은 날의 목록

  const MonthlyReadingCard({
    super.key,
    required this.daysInMonth,
    required this.readingDays,
  });

  @override
  Widget build(BuildContext context) {
    const double blockSize = 12;
    const double spacing = 6;
    const double gridWidth = (blockSize * 7) + (spacing * 6);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 15,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 독서 기록 (블록)
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '독서 기록',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // 블록 그리드
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: gridWidth, // 고정된 너비 설정
                    ),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7, // 한 줄에 7개
                        crossAxisSpacing: spacing, // 가로 간격
                        mainAxisSpacing: spacing, // 세로 간격
                      ),
                      itemCount: daysInMonth,
                      itemBuilder: (context, index) {
                        final day = index + 1;
                        final isReadingDay = readingDays.contains(day);
                        return Container(
                          width: blockSize,
                          height: blockSize,
                          decoration: BoxDecoration(
                            color: isReadingDay
                                ? AppColors.pointColor
                                : Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 30),
            // 독서 시간
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '독서 시간',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    '1일 3시간 32분',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
