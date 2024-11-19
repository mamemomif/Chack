import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/reading_time_service.dart';
import '../../components/timer/timer_select_book_button.dart';
import '../../constants/icons.dart';
import '../../services/pomodoro_service.dart';
import '../../constants/colors.dart';

class PomodoroPage extends StatefulWidget {
  final TimerService timerService;
  final String userId;

  const PomodoroPage({
    Key? key,
    required this.timerService,
    required this.userId,
  }) : super(key: key);

  @override
  _PomodoroPageState createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  final BookReadingTimeService _readingTimeService = BookReadingTimeService();
  String elapsedTimeText = '';
  Map<String, String>? selectedBook;
  StreamSubscription? _readingStatusSubscription;
  Duration _totalReadTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    widget.timerService.onTick = () {
      setState(() {
        elapsedTimeText = widget.timerService.formatElapsedTime();
      });
    };

    widget.timerService.onComplete = () async {
      if (selectedBook != null && widget.timerService.isPomodoro) {
        await _updateReadingTime();
      }

      if (!widget.timerService.isPomodoro && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('휴식 시간이 시작되었습니다. 잠시 쉬어가세요!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    };
  }

  Future<void> _updateReadingTime() async {
    if (selectedBook == null) return;
    
    final sessionTime = widget.timerService.elapsedTime;
    
    try {
      await _readingTimeService.updateReadingTime(
        userId: widget.userId,
        isbn: selectedBook!['isbn']!,
        elapsedSeconds: sessionTime,
      );
      
      final updatedTotalTime = await _readingTimeService.getBookReadingTime(
        userId: widget.userId,
        isbn: selectedBook!['isbn']!,
      );
      
      setState(() {
        _totalReadTime = updatedTotalTime;
      });
    } catch (e) {
      print('Failed to update reading time: $e');
    }
  }

  void _resetTimer() {
    if (widget.timerService.isRunning) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('타이머 초기화'),
          content: const Text('현재 진행 중인 타이머를 초기화하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (selectedBook != null && widget.timerService.isPomodoro) {
                  _updateReadingTime(); // 초기화 전 현재까지의 시간 저장
                }
                setState(() {
                  widget.timerService.reset();
                  elapsedTimeText = widget.timerService.formatElapsedTime();
                });
              },
              child: const Text('확인'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        widget.timerService.reset();
        elapsedTimeText = widget.timerService.formatElapsedTime();
      });
    }
  }

  void _toggleTimer() {
    setState(() {
      if (selectedBook == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("먼저 기록할 도서를 선택해주세요.")),
        );
        return;
      }

      if (widget.timerService.isRunning) {
        widget.timerService.stop();
        _updateReadingTime();
      } else {
        widget.timerService.start();
      }
      elapsedTimeText = widget.timerService.formatElapsedTime();
    });
  }

  Future<void> _onBookSelected(Map<String, String>? book) async {
    if (widget.timerService.isRunning) {
      final bool shouldSwitch = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('타이머 실행 중'),
          content: const Text('현재 실행 중인 타이머가 있습니다. 도서를 변경하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('확인'),
            ),
          ],
        ),
      ) ?? false;

      if (!shouldSwitch) return;

      await _updateReadingTime();
      widget.timerService.stop();
      widget.timerService.reset();
    }

    setState(() {
      selectedBook = book;
    });

    _readingStatusSubscription?.cancel();

    if (book != null) {
      final existingTime = await _readingTimeService.getBookReadingTime(
        userId: widget.userId,
        isbn: book['isbn']!,
      );

      setState(() {
        _totalReadTime = existingTime;
      });

      _readingStatusSubscription = _readingTimeService
          .watchBookReadingStatus(
            userId: widget.userId,
            isbn: book['isbn']!,
          )
          .listen((status) {
            setState(() {
              _totalReadTime = Duration(seconds: status['readTime'] as int);
            });
          });
    }
  }

  @override
  void dispose() {
    _readingStatusSubscription?.cancel();
    widget.timerService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '뽀모도로',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'SUITE',
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularPercentIndicator(
                    radius: 114.5,
                    lineWidth: 20.0,
                    percent: widget.timerService.progress,
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.timerService.formatTime(),
                          style: const TextStyle(
                            fontFamily: "SUITE",
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (!widget.timerService.isPomodoro)
                          const Text(
                            "휴식 시간",
                            style: TextStyle(
                              fontFamily: "SUITE",
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    progressColor: widget.timerService.isPomodoro 
                      ? AppColors.pointColor 
                      : Colors.green,
                    backgroundColor: Colors.grey[300]!,
                    circularStrokeCap: CircularStrokeCap.butt,
                    reverse: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: SvgPicture.asset(AppIcons.restartIcon),
                        iconSize: 30,
                        onPressed: _resetTimer,
                      ),
                      const Text(
                        "다시 시작",
                        style: TextStyle(
                          fontFamily: "SUITE",
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                  Column(
                    children: [
                      IconButton(
                        icon: SvgPicture.asset(
                          widget.timerService.isRunning
                              ? AppIcons.pauseIcon
                              : AppIcons.startIcon,
                        ),
                        iconSize: 30,
                        onPressed: _toggleTimer,
                      ),
                      Text(
                        widget.timerService.isRunning ? "정지" : "시작",
                        style: const TextStyle(
                          fontFamily: "SUITE",
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: BookSelectionWidget(
            elapsedTimeText: elapsedTimeText,
            onBookSelected: _onBookSelected,
            userId: widget.userId,
            timerService: widget.timerService,
          ),
        ),
      ],
    );
  }
}