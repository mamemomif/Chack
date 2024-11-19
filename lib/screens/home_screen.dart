import 'package:chack_project/screens/timer_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import '../components/annual_goal_card.dart';
import '../components/monthly_reading_card.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../components/custom_search_bar.dart';
import '../components/book_recommendation/book_recommendation_list.dart';
import '../components/recent_book_popup.dart';
import '../services/authentication_service.dart';
import '../services/recent_book_service.dart';
import '../constants/icons.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../screens/profile_screen.dart';
import '../screens/bookshelf_screen.dart';
import '../screens/search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Logger _logger = Logger();
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final AuthService _authService = AuthService();
  final RecentBookService _recentBookService = RecentBookService();
  StreamSubscription<({String? imageUrl, String? title})>? _bookSubscription;

  String? _userId;
  String? _age;
  bool _isPopupVisible = true;
  String? _recentBookImageUrl;
  String? _recentBookTitle;
  
  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    await _getUserAge(user.uid);
    _setupRecentBookListener(user.uid);
  }

  void _setupRecentBookListener(String userId) {
    _bookSubscription?.cancel();
    _bookSubscription = _recentBookService
        .watchRecentBook(userId)
        .listen((bookData) {
          if (!mounted) return;
          
          if (bookData.imageUrl != null && bookData.title != null) {
            setState(() {
              _recentBookImageUrl = bookData.imageUrl;
              _recentBookTitle = bookData.title;
              _isPopupVisible = true;
            });
            _logger.i('Recent book updated: ${bookData.title}');
          }
        }, onError: (error) {
          _logger.e('Error in recent book stream: $error');
        });
  }

  Future<void> _getUserAge(String uid) async {
    try {
      _logger.i('HomeScreen: 사용자 정보 로드 시작 - UID: $uid');
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && userData['age'] != null) {
          setState(() {
            _userId = uid;
            _age = userData['age'].toString();
          });
          _logger.i('HomeScreen: 사용자 나이 그룹 로드 완료: $_age');
        } else {
          _logger.w('HomeScreen: 사용자 문서에 age 필드가 없음');
        }
      } else {
        _logger.w('HomeScreen: 사용자 문서가 존재하지 않음');
      }
    } catch (e) {
      _logger.e('HomeScreen: 사용자 정보 로드 중 오류 발생: $e');
    }
  }

  void _handleNavigateToTimer() {
    if (_recentBookTitle != null) {
      Navigator.pushNamed(
        context,
        '/timer',
        arguments: {
          'title': _recentBookTitle,
          'imageUrl': _recentBookImageUrl,
        },
      );
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          _pageController.jumpToPage(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  CustomSearchBar(
                    onTap: () {
                      if (_userId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('로그인이 필요한 서비스입니다.')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(
                            userId: _userId!,
                          ),
                        ),
                      );
                    },
                    onProfileTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      children: [
                        _HomeTab(
                          userId: _userId,
                          age: _age,
                        ),
                        const BookshelfScreen(),
                        const _TimerTab(),
                        const _StatisticsTab(),
                      ],
                    ),
                  ),
                ],
              ),
              if (_recentBookImageUrl != null && _recentBookTitle != null)
                RecentBookPopup(
                  isVisible: _isPopupVisible,
                  onClose: () {
                    setState(() {
                      _isPopupVisible = false;
                    });
                  },
                  onTap: _handleNavigateToTimer,
                  imageUrl: _recentBookImageUrl!,
                  title: _recentBookTitle!,
                ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
            _pageController.jumpToPage(index);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bookSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }
}


class _HomeTab extends StatelessWidget {
  final String? userId;
  final String? age;

  const _HomeTab({
    required this.userId,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return ColoredBox(
      color: AppColors.backgroundColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userId != null && age != null)
                SizedBox(
                  height: 170,
                  child: BookRecommendationList(
                    userId: userId!,
                    age: age!,
                  ),
                ),
              const Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '홈',
                        style: AppTextStyles.titleStyle,
                      ),
                    ),
                  ],
                ),
              ),
              const AnnualGoalCard(
                progress: 0.5,
                remainingBooks: 9,
              ),
              const SizedBox(height: 30),
              const MonthlyReadingCard(
                daysInMonth: 30,
                readingDays: [1, 2, 4, 5, 6, 10, 11, 12, 13, 14, 15, 16, 17, 20, 21, 22],
              ),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerTab extends StatelessWidget {
  const _TimerTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: TimerScreen(),
    );
  }
}

class _StatisticsTab extends StatelessWidget {
  const _StatisticsTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      child: const Center(
        child: Text(
          '통계',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'SUITE',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}