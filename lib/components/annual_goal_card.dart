import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/icons.dart';
import '../constants/colors.dart';

class AnnualGoalCard extends StatelessWidget {
  final String userId;

  const AnnualGoalCard({
    super.key,
    required this.userId,
  });

  Future<void> _updateReadBooks(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('userShelf')
          .doc(userId)
          .collection('books')
          .where('status', isEqualTo: '다 읽음')
          .get();

      final readBooks = snapshot.docs.length;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'readBooks': readBooks,
      });
    } catch (e) {
      print('Error updating read books: $e');
    }
  }

  Future<void> _showGoalEditDialog(BuildContext context) async {
    final TextEditingController goalController = TextEditingController();
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('연간 독서 목표 설정'),
              content: TextField(
                controller: goalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '목표 권수를 입력하세요',
                  errorText: errorText,
                  border: const OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () async {
                    final input = goalController.text;
                    final goal = int.tryParse(input);

                    if (goal == null || goal <= 0) {
                      setState(() => errorText = '올바른 숫자를 입력해주세요.');
                      return;
                    }

                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .update({
                        'annualGoal': goal,
                      });

                      await _updateReadBooks(userId);

                      if (context.mounted) Navigator.of(context).pop();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('목표 설정 중 오류가 발생했습니다.')),
                        );
                      }
                    }
                  },
                  child: const Text('설정'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('오류가 발생했습니다.');
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final annualGoal = data?['annualGoal'] as int? ?? 0;
        final readBooks = data?['readBooks'] as int? ?? 0;

        final remainingBooks = annualGoal - readBooks;
        final progress = annualGoal > 0 ? readBooks / annualGoal : 0.0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 첫 번째 Row: 텍스트와 아이콘
                Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.chackIcon,
                      width: 30,
                    ),
                    const SizedBox(width: 25),
                    Expanded(
                      child: Text(
                        annualGoal > 0
                            ? '연간 목표 달성까지\n$remainingBooks권 남았어요.'
                            : '연간 독서 목표를\n설정해주세요!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // 두 번째 Row: 진행률과 읽은 책/목표 책 표시
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 읽은 책 수와 목표 책 수
                    RichText(
                      text: TextSpan(
                        text: '$readBooks',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF58BFAE),
                          fontFamily: 'SUITE',
                        ),
                        children: [
                          TextSpan(
                            text: '/$annualGoal권',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontFamily: 'SUITE',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // 편집 아이콘
                    GestureDetector(
                      onTap: () => _showGoalEditDialog(context),
                      child: Icon(
                        Icons.edit,
                        color: Colors.black.withOpacity(0.15),
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // 진행률 바
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
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.pointColor,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
