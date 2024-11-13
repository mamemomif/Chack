import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/icons.dart';
import '../../services/stopwatch_service.dart';

class StopwatchPage extends StatefulWidget {
  final StopwatchService stopwatchService;

  const StopwatchPage({
    Key? key,
    required this.stopwatchService,
  }) : super(key: key);

  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  @override
  void initState() {
    super.initState();
    widget.stopwatchService.onTick = () {
      setState(() {}); // 스톱워치가 진행될 때 화면 갱신
    };
  }

  @override
  void dispose() {
    widget.stopwatchService.stop(); // 화면이 종료되면 스톱워치도 정지
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
              '스탑워치',
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
        Text(
          widget.stopwatchService.formatTime(),
          style: const TextStyle(fontFamily: "SUITE", fontSize: 44, fontWeight: FontWeight.w800),
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
                      widget.stopwatchService.reset();
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
                    widget.stopwatchService.isRunning ? AppIcons.pauseIcon : AppIcons.startIcon,
                  ),
                  iconSize: 30,
                  onPressed: () {
                    setState(() {
                      if (widget.stopwatchService.isRunning) {
                        widget.stopwatchService.stop();
                      } else {
                        widget.stopwatchService.start();
                      }
                    });
                  },
                ),
                Text(
                  widget.stopwatchService.isRunning ? "정지" : "시작",
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
