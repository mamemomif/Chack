import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';
import '../constants/text_styles.dart';
import '../constants/bookcover_styles.dart';

class BookshelfScreen extends StatelessWidget {
  const BookshelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 15),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '서재',
              style: AppTextStyles.titleStyle,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.builder(
          itemCount: 10,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio:
                (BookCoverStyles.small.width / BookCoverStyles.small.height) *
                    0.9,
            crossAxisSpacing: 14,
            mainAxisSpacing: 20,
          ),
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Stack(
                  clipBehavior: Clip.none, // Stack의 자식이 그리드 경계를 넘어도 잘리지 않도록 설정
                  children: [
                    const BookCover(style: BookCoverStyles.small),
                    Positioned(
                      top: -6, // 살짝 위로 벗어나도록 설정
                      right: -6, // 살짝 오른쪽으로 벗어나도록 설정
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            AppIcons.chackIcon,
                            height: 10,
                            width: 10,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Flexible(
                  child: Text(
                    '책 제목',
                    style: AppTextStyles.titleLabelStyle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '저자',
                  style: AppTextStyles.authorLabelStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
