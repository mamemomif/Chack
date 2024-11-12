import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SelectBookButton extends StatelessWidget {
  const SelectBookButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print('기록할 도서 선택하기 버튼이 눌렸습니다.');
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 330),
          padding: const EdgeInsets.symmetric(vertical: 23, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/images/chack_icon.svg', width: 24, height: 18),
              const SizedBox(width: 16),
              const Text(
                '기록할 도서 선택하기',
                style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
