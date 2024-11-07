// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/colors.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2초 후 로그인 화면으로 이동
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 화면 크기 가져오기
    final Size screenSize = MediaQuery.of(context).size;
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // 상단 여백을 위한 Spacer 추가
              const Spacer(),
              // 로고 크기를 화면 크기에 비례하게 설정
              SvgPicture.asset(
                'assets/images/chack_icon.svg',
                width: screenSize.width * 0.2,  // 화면 너비의 20%
                height: screenSize.width * 0.2,  // 화면 너비의 20%
                colorFilter: ColorFilter.mode(
                  AppColors.pointColor,
                  BlendMode.srcIn,
                ),
              ),
              const Spacer(),
              // 하단 텍스트
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  '채크',
                  style: TextStyle(
                    fontFamily: 'SUITE',
                    fontSize: 25,
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}