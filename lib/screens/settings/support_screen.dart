import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/colors.dart';
import '../../components/custom_alert_banner.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  Future<void> _sendEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'moejihong@gmail.com',
      queryParameters: {
        'subject': '[채크] 문의사항',
        'body': '문의 내용을 작성해주세요.\n\n'
            '-------------------------------\n'
            '앱 버전: 1.0.0\n'
            '기기: ${Theme.of(context).platform}\n'
      },
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw '이메일을 보낼 수 없습니다.';
      }
    } catch (e) {
      if (context.mounted) {
        CustomAlertBanner.show(
          context,
          message: '이메일 앱을 실행할 수 없습니다.',
          iconColor: AppColors.errorColor,
        );
      }
    }
  }

  Future<void> _openGitHubIssues(BuildContext context) async {
    final Uri url = Uri.parse('https://github.com/ChackTeam/Chack/issues');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw '웹페이지를 열 수 없습니다.';
      }
    } catch (e) {
      if (context.mounted) {
        CustomAlertBanner.show(
          context,
          message: 'GitHub 페이지를 열 수 없습니다.',
          iconColor: AppColors.errorColor,
        );
      }
    }
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
    required IconData icon,
  }) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.pointColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.pointColor,
              size: 24,
            ),
          ),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildContactButton({
    required String title,
    required String description,
    required IconData icon,
    required void Function(BuildContext) onTap,
  }) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () => onTap(context),
        child: Container(
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.pointColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppColors.pointColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '도움말',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '자주 묻는 질문',
              [
                _buildFAQItem(
                  question: '독서 타이머는 어떻게 사용하나요?',
                  answer: '독서 타이머는 책을 읽는 시간을 자동으로 기록하여 일일 독서 통계에 반영합니다. '
                      '타이머 버튼을 눌러 시작하고, 휴식이 필요할 때는 일시 정지 버튼을 눌러주세요. ',
                  icon: Icons.timer,
                ),
                _buildFAQItem(
                  question: '책을 검색할 수 없어요.',
                  answer: '책에 대한 정보를 정확히 입력했는지 확인해주세요. '
                      '인터넷 연결을 확인해주세요. '
                      '검색이 계속 되지 않으면 [프로필] > [도움말] > [고객지원]으로 문의해 주세요.',
                  icon: Icons.search,
                ),
                _buildFAQItem(
                  question: '독서 기록이 사라졌어요.',
                  answer: '독서 기록은 자동으로 저장되니 안심하세요. '
                      '기록이 보이지 않을 때는 인터넷 연결 상태를 확인해 보시고, '
                      '문제가 지속되면 [프로필] > [도움말] > [고객지원]으로 문의해 주세요.',
                  icon: Icons.history,
                ),
                _buildFAQItem(
                  question: '알림이 오지 않아요.',
                  answer: '[프로필] > [알림 설정]에서 알림이 활성화되어 있는지 확인해주세요. '
                      '[프로필] > [알림 설정]에서 알림이 활성화되어 있는지 확인해주세요.',
                  icon: Icons.notifications,
                ),
              ],
            ),
            _buildSection(
              '고객 지원',
              [
                _buildContactButton(
                  title: '이메일 문의',
                  description: '평일 09:00-18:00 응답',
                  icon: Icons.email,
                  onTap: _sendEmail,
                ),
                const SizedBox(height: 12),
                _buildContactButton(
                  title: '버그 리포트',
                  description: 'GitHub Issues에서 문제를 제보해 주세요',
                  icon: Icons.bug_report,
                  onTap: _openGitHubIssues,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}