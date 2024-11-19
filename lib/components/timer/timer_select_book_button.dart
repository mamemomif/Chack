import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/icons.dart';
import '../../constants/colors.dart';
import '../../services/pomodoro_service.dart';
import '../../services/reading_time_service.dart';
import 'timer_select_book_menu.dart';

class BookSelectionWidget extends StatefulWidget {
  final String elapsedTimeText;
  final Function(Map<String, String>?) onBookSelected;
  final String userId;
  final TimerService timerService;

  const BookSelectionWidget({
    Key? key,
    required this.elapsedTimeText,
    required this.onBookSelected,
    required this.userId,
    required this.timerService,
  }) : super(key: key);

  @override
  State<BookSelectionWidget> createState() => _BookSelectionWidgetState();
}

class _BookSelectionWidgetState extends State<BookSelectionWidget> {
  Map<String, String>? selectedBook;
  final BookReadingTimeService _readingTimeService = BookReadingTimeService();
  StreamSubscription? _readingStatusSubscription;
  Duration _totalReadTime = Duration.zero;

  @override
  void dispose() {
    _readingStatusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _showBookSelectionModal(BuildContext context) async {
    if (widget.timerService.isRunning) {
      final bool shouldSwitch = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('타이머 실행 중'),
          content: const Text('현재 실행 중인 타이머가 있습니다. 도서를 변경하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('확인'),
            ),
          ],
        ),
      ) ?? false;

      if (!shouldSwitch) return;

      widget.timerService.stop();
      widget.timerService.reset();
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => BookSelectionModal(
        onBookSelected: (book) async {
          setState(() {
            selectedBook = book;
          });

          if (book != null) {
            final existingTime = await _readingTimeService.getBookReadingTime(
              userId: widget.userId,
              isbn: book['isbn']!,
            );

            setState(() {
              _totalReadTime = existingTime;
            });

            _readingStatusSubscription?.cancel();
            _readingStatusSubscription = _readingTimeService
                .watchBookReadingStatus(
                  userId: widget.userId,
                  isbn: book['isbn']!,
                )
                .listen((status) {
                  setState(() {
                    _totalReadTime = Duration(seconds: status['readTime'] as int);
                  });
                });

            widget.onBookSelected(book);
          }
          Navigator.pop(context);
        },
        onResetSelection: () {
          setState(() {
            selectedBook = null;
            _totalReadTime = Duration.zero;
          });
          widget.onBookSelected(null);
          _readingStatusSubscription?.cancel();
        },
        userId: widget.userId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showBookSelectionModal(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 330),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              SvgPicture.asset('assets/images/chack_icon.svg', width: 24, height: 18),
              const SizedBox(width: 16),
              Expanded(
                child: selectedBook == null
                    ? const Center(
                        child: Text(
                          '기록할 도서 선택하기',
                          style: TextStyle(
                            fontFamily: 'SUITE',
                            color: AppColors.textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                '현재 기록 중인 도서',
                                style: TextStyle(
                                  fontFamily: 'SUITE',
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_readingTimeService.formatReadingTime(_totalReadTime)}',
                                style: const TextStyle(
                                  fontFamily: 'SUITE',
                                  fontSize: 12,
                                  color: AppColors.pointColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${selectedBook!["title"]!} / ${selectedBook!["author"]!}',
                            style: const TextStyle(
                              fontFamily: 'SUITE',
                              color: AppColors.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 16),
              if (selectedBook != null && widget.timerService.isRunning)
                Text(
                  widget.elapsedTimeText,
                  style: const TextStyle(
                    fontFamily: 'SUITE',
                    fontSize: 20,
                    color: AppColors.pointColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}