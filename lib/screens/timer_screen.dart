import 'package:flutter/material.dart';
import '../services/pomodoro_service.dart';
import '../services/stopwatch_service.dart';
import '../components/timer/timer_pomodoro.dart';
import '../components/timer/timer_stopwatch.dart';
import '../components/timer/timer_page_indicator.dart';

class TimerScreen extends StatefulWidget {
  final String userId;

  const TimerScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late TimerService _timerService;
  late StopwatchService _stopwatchService;
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _timerService = TimerService()..onTick = () => setState(() {});
    _stopwatchService = StopwatchService()..onTick = () => setState(() {});
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _timerService.dispose();
    _stopwatchService.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // 키보드가 올라올 때 레이아웃 조정
      body: Column(
        children: [
          const SizedBox(height: 40),
          // 페이지 인디케이터
          PageIndicator(currentPageIndex: _currentPageIndex),
          // 페이지 뷰 영역 (확장 가능)
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPageIndex = index),
              children: [
                PomodoroPage(
                  timerService: _timerService,
                  userId: widget.userId,
                ),
                StopwatchPage(
                  stopwatchService: _stopwatchService,
                  userId: widget.userId,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
