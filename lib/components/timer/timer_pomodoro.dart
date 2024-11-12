import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/icons.dart';
import '../../services/timer_service.dart';
import '../../constants/colors.dart';

class PomodoroPage extends StatefulWidget {
  final TimerService timerService;

  const PomodoroPage({
    Key? key,
    required this.timerService,
  }) : super(key: key);

  @override
  _PomodoroPageState createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  @override
  void initState() {
    super.initState();
    widget.timerService.onTick = () {
      setState(() {}); // 타이머 업데이트 시 화면 갱신
    };
    widget.timerService.onComplete = () {
      setState(() {}); // 타이머 완료 시 화면 갱신
    };
  }

  @override
  void dispose() {
    widget.timerService.stop(); // 화면이 종료되면 타이머도 종료
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 1),
            child: Text(
              '뽀모도로',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                fontFamily: 'SUITE',
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                radius: 114.5,
                lineWidth: 20.0,
                percent: widget.timerService.progress,
                center: Text(
                  widget.timerService.formatTime(),
                  style: const TextStyle(fontFamily: "SUITE", fontSize: 44, fontWeight: FontWeight.w800),
                ),
                progressColor: AppColors.pointColor,
                backgroundColor: Colors.grey[300]!,
                circularStrokeCap: CircularStrokeCap.butt,
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
                            widget.timerService.reset();
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
                  const SizedBox(width: 40),
                  Column(
                    children: [
                      IconButton(
                        icon: SvgPicture.asset(
                          widget.timerService.isRunning ? AppIcons.pauseIcon : AppIcons.startIcon,
                        ),
                        iconSize: 30,
                        onPressed: () {
                          setState(() {
                            if (widget.timerService.isRunning) {
                              widget.timerService.stop();
                            } else {
                              widget.timerService.start();
                            }
                          });
                        },
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
      ],
    );
  }
}
