import 'package:chack_project/components/timer/timer_select_book_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chack_project/constants/colors.dart';
import '../../services/timer_service.dart';

class BookSelectionWidget extends StatefulWidget {
  final String elapsedTimeText;

  const BookSelectionWidget({Key? key, required this.elapsedTimeText}) : super(key: key);

  @override
  _BookSelectionWidgetState createState() => _BookSelectionWidgetState();
}

class _BookSelectionWidgetState extends State<BookSelectionWidget> {
  Map<String, String>? selectedBook;
  late TimerService timerService;

  @override
  void initState() {
    super.initState();
    timerService = TimerService();
  }

  void _showBookSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => BookSelectionModal(
        onBookSelected: (book) {
          setState(() {
            selectedBook = book;
          });
          Navigator.pop(context);
          timerService.start();
        },
        onResetSelection: _resetSelection,
      ),
    );
  }

  void _resetSelection() {
    setState(() {
      selectedBook = null;
    });
    timerService.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showBookSelectionModal(context);
        },
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
                    const Text(
                      '현재 기록 중인 도서',
                      style: TextStyle(
                        fontFamily: 'SUITE',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
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
              if (selectedBook != null)
                Text(
                  widget.elapsedTimeText,
                  style: TextStyle(
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
