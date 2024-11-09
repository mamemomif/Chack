import 'dart:async';
import 'package:flutter/material.dart';

class TimerService with WidgetsBindingObserver {
  int duration;
  late int _remainingTime;
  double progress;
  Timer? _timer;
  bool isRunning = false;
  DateTime? _backgroundTime; // 백그라운드 전환 시간 기록

  VoidCallback? onTick;
  VoidCallback? onComplete;

  TimerService({this.duration = 60}) : _remainingTime = duration, progress = 1.0 {
    WidgetsBinding.instance.addObserver(this); // 라이프사이클 옵저버 추가
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
        progress = _remainingTime / duration;
        onTick?.call();
      } else {
        stop();
        onComplete?.call();
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    isRunning = false;
  }

  void reset() {
    stop();
    _remainingTime = duration;
    progress = 1.0;
    onTick?.call();
  }

  String formatTime() {
    final minutes = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final secs = (_remainingTime % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  // 앱 라이프사이클 상태가 변경될 때 호출
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && isRunning) {
      _backgroundTime = DateTime.now(); // 백그라운드로 갈 때 시간 기록
      _timer?.cancel(); // 타이머 일시 정지
    } else if (state == AppLifecycleState.resumed && isRunning) {
      if (_backgroundTime != null) {
        final now = DateTime.now();
        final elapsedTime = now.difference(_backgroundTime!).inSeconds;
        _remainingTime = (_remainingTime - elapsedTime).clamp(0, duration); // 남은 시간 조정
        progress = _remainingTime / duration;

        if (_remainingTime > 0) {
          _startCountdown(); // 타이머 재시작
        } else {
          stop();
          onComplete?.call();
        }
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 옵저버 해제
    _timer?.cancel();
  }
}
