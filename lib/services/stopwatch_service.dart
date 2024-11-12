import 'dart:async';
import 'package:flutter/material.dart';

class StopwatchService with WidgetsBindingObserver {
  int _elapsedTime = 0; // 누적된 경과 시간 (밀리초 단위)
  Timer? _timer;
  bool isRunning = false;
  DateTime? _startTime;
  DateTime? _backgroundTime; // 백그라운드로 들어간 시간 기록

  VoidCallback? onTick;

  StopwatchService() {
    WidgetsBinding.instance.addObserver(this); // 라이프사이클 옵저버 추가
  }

  void start() {
    if (isRunning) return;
    isRunning = true;
    _startTime = DateTime.now(); // 시작 시간을 현재 시간으로 설정
    _startStopwatch();
  }

  void _startStopwatch() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { // 1초 단위로 업데이트
      if (_startTime != null) {
        final now = DateTime.now();
        _elapsedTime = now.difference(_startTime!).inMilliseconds;
        onTick?.call(); // UI 업데이트
      }
    });
  }

  void stop() {
    if (isRunning) {
      final now = DateTime.now();
      _elapsedTime = now.difference(_startTime!).inMilliseconds; // 총 경과 시간을 누적
      isRunning = false;
      _timer?.cancel();
      _startTime = null;
    }
  }

  void reset() {
    stop();
    _elapsedTime = 0;
    onTick?.call();
  }

  String formatTime() {
    final minutes = (_elapsedTime ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((_elapsedTime ~/ 1000) % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
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
        _elapsedTime += now.difference(_backgroundTime!).inMilliseconds; // 백그라운드 시간 누적
        _startTime = now.subtract(Duration(milliseconds: _elapsedTime)); // 경과 시간 유지
        _backgroundTime = null;
        _startStopwatch();
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 옵저버 해제
    _timer?.cancel();
  }
}
