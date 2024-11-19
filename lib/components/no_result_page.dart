import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoResultsFound extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;
  final String buttonText;

  const NoResultsFound({
    Key? key,
    required this.onRetry,
    this.message = '검색 결과가 없습니다.',
    this.buttonText = '다시 검색하기',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SVG 아이콘 (회색으로 색상 변경)
          SvgPicture.asset(
            AppIcons.chackIcon,
            width: 80,
            height: 80,
            colorFilter: const ColorFilter.mode(
              Color(0xFFBDBDBD), // Grey #BDBDBD
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 24),
          // 메시지 텍스트
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'SUITE',
              fontSize: 18,
              color: Color(0xFF757575), // Grey #757575
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // 부가 설명
          const Text(
            '다른 검색어로 다시 시도해보세요',
            style: TextStyle(
              fontFamily: 'SUITE',
              fontSize: 14,
              color: Color(0xFF9E9E9E), // Grey #9E9E9E
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // 재시도 버튼
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pointColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontFamily: 'SUITE',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}