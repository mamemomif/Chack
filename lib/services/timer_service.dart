import 'dart:async';
import 'package:flutter/material.dart';

class TimerService with WidgetsBindingObserver {
  final int pomodoroDuration; // 뽀모도로 지속 시간 (초 단위)
  final int breakDuration; // 휴식 지속 시간 (초 단위)
  late int duration; // 현재 타이머의 지속 시간
  late int _remainingTime; // 남은 시간
  int elapsedTime = 0; // 타이머가 진행된 누적 시간
  double progress;
  Timer? _timer;
  bool isRunning = false;
  bool isPomodoro = true; // 뽀모도로 타이머인지 여부

  VoidCallback? onTick;
  VoidCallback? onComplete;

  TimerService({this.pomodoroDuration = 20 * 1, this.breakDuration = 5 * 1})
      : duration = pomodoroDuration,
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
        elapsedTime++; // 진행된 시간 누적
        progress = _remainingTime / duration;
        onTick?.call();
      } else {
        stop();
        onComplete?.call();
        _switchTimer(); // 다음 타이머로 전환 후 시작
        start();
      }
    });
  }

  void _switchTimer() {
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
    duration = isPomodoro ? pomodoroDuration : breakDuration;
    _remainingTime = duration;
    progress = 1.0;
    onTick?.call();
  }

  String formatElapsedTime() {
    final hours = (elapsedTime ~/ 3600).toString();
    final minutes = ((elapsedTime % 3600) ~/ 60).toString();
    final seconds = (elapsedTime % 60).toString();

    return '$hours시간$minutes분$seconds초';

  }

  String formatTime() {
    final minutes = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final secs = (_remainingTime % 60).toString().padLeft(2, '0');

    return "$minutes:$secs";
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }
}
