import 'package:flutter/material.dart';
import '../services/timer_service.dart';
import '../services/stopwatch_service.dart';
import '../components/timer/timer_pomodoro.dart';
import '../components/timer/timer_select_book_button.dart';
import '../components/timer/timer_stopwatch.dart';
import '../components/timer/timer_page_indicator.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

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
    return Column(
      children: [
        const SizedBox(height: 40),
        PageIndicator(currentPageIndex: _currentPageIndex),
        Container(
          height: 480,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPageIndex = index),
            children: [
              PomodoroPage(timerService: _timerService),
              StopwatchPage(stopwatchService: _stopwatchService),
            ],
          ),
        ),
        const SelectBookButton(),
        const SizedBox(height: 20),
      ],
    );
  }
}
