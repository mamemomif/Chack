import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class BookReadingtimeCard extends StatelessWidget {
  final String startDate;
  final String endDate;
  final String duration;
  final String totalReadingTime;

  const BookReadingtimeCard({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.totalReadingTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 독서 시작, 완료, 소요 시간
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '독서 시작',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: "SUITE",
                        fontSize: 14,
                        color: AppColors.unreadColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      startDate,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFamily: "SUITE",
                        fontSize: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '독서 완료',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: "SUITE",
                        fontSize: 14,
                        color: AppColors.unreadColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      endDate,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFamily: "SUITE",
                        fontSize: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '소요 시간',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontFamily: "SUITE",
                        fontSize: 14,
                        color: AppColors.unreadColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      duration,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFamily: "SUITE",
                        fontSize: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 총 독서 시간
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '총 독서 시간 ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: "SUITE",
                    fontSize: 16,
                    color: AppColors.unreadColor,
                  ),
                ),
                Text(
                  totalReadingTime,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontFamily: "SUITE",
                    fontSize: 20,
                    color: AppColors.pointColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
