import 'package:chack_project/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/icons.dart';
import '../services/timer_service.dart';

class CircularCountdownTimer extends StatefulWidget {
  final int duration; // 타이머의 총 시간 (초)

  const CircularCountdownTimer({Key? key, required this.duration}) : super(key: key);

  @override
  _CircularCountdownTimerState createState() => _CircularCountdownTimerState();
}

class _CircularCountdownTimerState extends State<CircularCountdownTimer> {
  late TimerService _timerService;

  @override
  void initState() {
    super.initState();
    _timerService = TimerService(duration: widget.duration)
      ..onTick = () {
        setState(() {}); // 타이머 업데이트 시 UI 갱신
      }
      ..onComplete = () {
        setState(() {
          _timerService.isRunning = false;
        });
      };
  }

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularPercentIndicator(
          radius: 114.5,
          lineWidth: 20.0,
          percent: _timerService.progress, // 시간이 지남에 따라 줄어드는 비율
          center: Text(
            _timerService.formatTime(),
            style: const TextStyle(fontFamily: "SUITE", fontSize: 44, fontWeight: FontWeight.w800),
          ),
          progressColor: AppColors.pointColor,
          backgroundColor: Colors.grey[300]!,
          circularStrokeCap: CircularStrokeCap.round,
          reverse: true,
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
                  onPressed: () {
                    setState(() {
                      _timerService.reset();
                    });
                  },
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
            const SizedBox(width: 70),
            Column(
              children: [
                IconButton(
                  icon: SvgPicture.asset(_timerService.isRunning ? AppIcons.pauseIcon : AppIcons.startIcon),
                  iconSize: 30,
                  onPressed: () {
                    setState(() {
                      if (_timerService.isRunning) {
                        _timerService.stop();
                      } else {
                        _timerService.start();
                      }
                    });
                  },
                ),
                Text(
                  _timerService.isRunning ? "정지" : "시작",
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
    );
  }
}
