import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/icons.dart';
import '../constants/colors.dart';

class AnnualGoalCard extends StatelessWidget {
  final double progress; // 진행률
  final int remainingBooks; // 남은 책 수

  const AnnualGoalCard({
    super.key,
    required this.progress,
    required this.remainingBooks,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  AppIcons.chackIcon,
                  width: 30,
                ),
                const SizedBox(
                  width: 25,
                ),
                Text(
                  '연간 목표 달성까지\n$remainingBooks권 남았어요.',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.edit,
                  color: Colors.black.withOpacity(0.15),
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                // 진행률 배경 바
                Container(
                  width: double.infinity,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // 진행률 바
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 11,
                    decoration: BoxDecoration(
                      color: AppColors.pointColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}
