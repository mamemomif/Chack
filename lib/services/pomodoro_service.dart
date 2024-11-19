import 'dart:async';
import 'package:flutter/material.dart';

class TimerService with WidgetsBindingObserver {
  final int pomodoroDuration;
  final int breakDuration;
  late int duration;
  late int _remainingTime;
  int elapsedTime = 0;
  double progress;
  Timer? _timer;
  bool isRunning = false;
  bool isPomodoro = true;

  VoidCallback? onTick;
  VoidCallback? onComplete;

  TimerService({
    this.pomodoroDuration = 10,  // 기본 25분
    this.breakDuration = 5,      // 기본 5분
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
          elapsedTime++;
        }

        progress = _remainingTime / duration;
        onTick?.call();
      } else {
        stop();
        onComplete?.call();
        _switchTimer();
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
    elapsedTime = 0;
    onTick?.call();
  }

  String formatElapsedTime() {
    final duration = Duration(seconds: elapsedTime);
    return '${duration.inMinutes}분 ${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}초';
  }

  String formatTime() {
    final minutes = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingTime % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void dispose() {  // super.dispose() 제거
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }
}