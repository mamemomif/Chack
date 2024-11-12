import 'dart:async';
import 'package:flutter/material.dart';

class TimerService with WidgetsBindingObserver {
  final int pomodoroDuration; // 뽀모도로 지속 시간 (초 단위)
  final int breakDuration; // 휴식 지속 시간 (초 단위)
  late int duration; // 현재 타이머의 지속 시간
  late int _remainingTime; // 남은 시간
  double progress;
  Timer? _timer;
  bool isRunning = false;
  bool isPomodoro = true; // 뽀모도로 타이머인지 여부

  VoidCallback? onTick;
  VoidCallback? onComplete;

  TimerService({this.pomodoroDuration = 20 * 1, this.breakDuration = 5 * 1}) //사이클 구현 테스크를 위해서 값 임시 조정했습니다.
      : duration = pomodoroDuration,
        _remainingTime = pomodoroDuration,
        progress = 1.0 {
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
        _switchTimer(); // 다음 타이머로 전환 후 시작
        start();
      }
    });
  }

  void _switchTimer() {
    // 타이머 종료 후 자동 전환
    if (isPomodoro) {
      duration = breakDuration; // 휴식 시간 설정
    } else {
      duration = pomodoroDuration; // 뽀모도로 시간 설정
    }
    _remainingTime = duration;
    progress = 1.0;
    isPomodoro = !isPomodoro; // 타이머 상태 전환
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    isRunning = false;
  }

  void reset() {
    stop();
    duration = isPomodoro ? pomodoroDuration : breakDuration; // 현재 타이머에 따라 초기화
    _remainingTime = duration;
    progress = 1.0;
    onTick?.call();
  }

  String formatTime() {
    final minutes = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final secs = (_remainingTime % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 옵저버 해제
    _timer?.cancel();
  }
}
