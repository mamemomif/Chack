import 'dart:async';
import 'dart:ui';

class TimerService {
  late int duration;
  late int _remainingTime;
  late double progress;
  Timer? _timer;
  bool isRunning = false;

  TimerService({required this.duration}) {
    _remainingTime = duration;
    progress = 1.0;
  }

  // 타이머 상태 변경 리스너
  VoidCallback? onTick;
  VoidCallback? onComplete;

  void start() {
    if (isRunning) return;
    isRunning = true;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        progress = _remainingTime / duration;
        onTick?.call(); // 타이머 업데이트를 알림
      } else {
        stop();
        onComplete?.call(); // 타이머 완료를 알림
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
    onTick?.call(); // 리셋 후 상태 업데이트
  }

  String formatTime() {
    final minutes = (_remainingTime ~/ 60).toString().padLeft(2, '0');
    final secs = (_remainingTime % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  void dispose() {
    _timer?.cancel();
  }
}
