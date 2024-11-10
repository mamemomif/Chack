import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/colors.dart';
import '../constants/icons.dart';

class SearchInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const SearchInputBar({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 로고
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SvgPicture.asset(
            AppIcons.chackIcon,
            width: 24,
          ),
        ),
        const SizedBox(width: 5),

        // 검색 인풋 필드와 돋보기 아이콘 포함 컨테이너
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      fillColor: Colors.transparent,
                      hintText: '읽고 싶은 책을 알려주세요',
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.4),
                        fontSize: 16,
                        fontFamily: 'SUITE',
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onSearch,
                  child: Icon(
                    Icons.search,
                    color: Colors.black.withOpacity(0.4),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
