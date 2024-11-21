import 'dart:async';
import 'package:flutter/material.dart';
import 'package:chack_project/services/daily_reading_service.dart';

class TimerService with WidgetsBindingObserver {
  final DailyReadingService _dailyReadingService = DailyReadingService();
  final int pomodoroDuration;
  final int breakDuration;
  late int duration;
  late int _remainingTime;
  int elapsedTimeForFirestore = 0; // Firestore에 저장할 경과 시간
  int elapsedTimeForUI = 0;        // UI에 표시할 경과 시간
  double progress;
  Timer? _timer;
  bool isRunning = false;
  bool isPomodoro = true;

  VoidCallback? onTick;
  VoidCallback? onComplete;

  TimerService({
    this.pomodoroDuration = 10, // 기본 25분
    this.breakDuration = 5,     // 기본 5분
  })  : duration = pomodoroDuration,
        _remainingTime = pomodoroDuration,
        progress = 1.0 {
    WidgetsBinding.instance.addObserver(this);
  }

  void start() {
    if (isRunning) return;
    isRunning = true;
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        if (isPomodoro) {
          elapsedTimeForFirestore++; // Firestore용 경과 시간 증가
          elapsedTimeForUI++;        // UI용 경과 시간 증가
        }
        progress = _remainingTime / duration;
        onTick?.call();
      } else {
        stop();
        onComplete?.call();
        switchTimer();
        start();
      }
    });
  }

  void pause() {
    if (!isRunning) return;
    _timer?.cancel(); // 타이머 중단
    _timer = null;
    isRunning = false;
  }

  void switchTimer() {
    if (isPomodoro) {
      duration = breakDuration;
    } else {
      duration = pomodoroDuration;
    }
    _remainingTime = duration;
    progress = 1.0;
    isPomodoro = !isPomodoro;
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    isRunning = false;
  }

  void reset() {
    stop();
    elapsedTimeForFirestore = 0;
    elapsedTimeForUI = 0; // UI 시간도 초기화
    _remainingTime = duration;
    progress = 1.0;
    onTick?.call();
  }

  String formatElapsedTime(int elapsedSeconds) {
    final duration = Duration(seconds: elapsedSeconds);
    return '${duration.inMinutes}분 ${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}초';
  }

  String formatTime() {
    final minutes = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> updateDailyReadingTime({
    required String userId,
  }) async {
    if (elapsedTimeForFirestore > 0) {
      try {
        await _dailyReadingService.updateDailyReadingTime(
          userId: userId,
          seconds: elapsedTimeForFirestore,
          date: DateTime.now(),
        );
        elapsedTimeForFirestore = 0;  // 업데이트 후 초기화
      } catch (e) {
        print('Error updating daily reading time: $e');
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }
}
