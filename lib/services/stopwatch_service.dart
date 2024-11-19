import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/pomodoro_service.dart';

class StopwatchService extends TimerService {
  int _elapsedSeconds = 0;
  Timer? _timer;
  DateTime? _startTime;
  DateTime? _backgroundTime;

  StopwatchService() : super(pomodoroDuration: 0, breakDuration: 0) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void start() {
    if (isRunning) return;
    isRunning = true;
    _startTime = DateTime.now().subtract(Duration(seconds: _elapsedSeconds));
    _startStopwatch();
  }

  void _startStopwatch() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        final now = DateTime.now();
        _elapsedSeconds = now.difference(_startTime!).inSeconds;
        elapsedTime = _elapsedSeconds; // TimerService의 elapsedTime 업데이트
        progress = 1.0; // 스톱워치는 항상 progress가 1
        onTick?.call();
      }
    });
  }

  @override
  void stop() {
    if (isRunning) {
      final now = DateTime.now();
      _elapsedSeconds = now.difference(_startTime!).inSeconds;
      elapsedTime = _elapsedSeconds;
      isRunning = false;
      _timer?.cancel();
      _startTime = null;
    }
  }

  @override
  void reset() {
    stop();
    _elapsedSeconds = 0;
    elapsedTime = 0;
    progress = 1.0;
    onTick?.call();
  }

  @override
  String formatTime() {
    final hours = (_elapsedSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_elapsedSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    
    // 시간이 0인 경우 분:초만 표시
    if (hours == '00') {
      return '$minutes:$seconds';
    }
    // 시간이 있는 경우 시:분:초 표시
    return '$hours:$minutes:$seconds';
  }

  // TimerService와의 호환성을 위한 오버라이드
  @override
  String formatElapsedTime() {
    return formatTime();
  }

  // 앱 라이프사이클 상태가 변경될 때 호출
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && isRunning) {
      _backgroundTime = DateTime.now();
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed && isRunning) {
      if (_backgroundTime != null) {
        final now = DateTime.now();
        _elapsedSeconds += now.difference(_backgroundTime!).inSeconds;
        _startTime = now.subtract(Duration(seconds: _elapsedSeconds));
        _backgroundTime = null;
        _startStopwatch();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}