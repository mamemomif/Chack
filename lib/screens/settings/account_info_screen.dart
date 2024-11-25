// account_info_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/colors.dart';

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '계정 정보',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data?.data() as Map<String, dynamic>?;
          final createdAt = userData?['createdAt'] as Timestamp?;
          final formattedDate = createdAt != null
              ? '${createdAt.toDate().year}년 ${createdAt.toDate().month}월 ${createdAt.toDate().day}일'
              : '정보 없음';

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(
                  title: '이메일',
                  content: user?.email ?? '정보 없음',
                  isEmail: true,
                ),
                const SizedBox(height: 24),
                _buildInfoSection(
                  title: '가입일',
                  content: formattedDate,
                ),
                const SizedBox(height: 24),
                _buildInfoSection(
                  title: '인증 상태',
                  content: user?.emailVerified ?? false ? '인증됨' : '인증 필요',
                  verified: user?.emailVerified ?? false,
                ),
                if (!(user?.emailVerified ?? false)) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          await user?.sendEmailVerification();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('인증 이메일이 발송되었습니다. 이메일을 확인해주세요.'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('이메일 발송 중 오류가 발생했습니다.'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pointColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('이메일 인증하기'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
    bool isEmail = false,
    bool? verified,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (verified != null)
                Icon(
                  verified ? Icons.verified : Icons.error_outline,
                  color: verified ? Colors.green : Colors.orange,
                ),
            ],
          ),
        ),
      ],
    );
  }
}