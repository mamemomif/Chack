import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 달력
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                titleTextFormatter: (date, locale) {
                  return '${date.year}년 ${date.month}월';
                },
                titleTextStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                formatButtonVisible: false,
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: const Color(0xFF5ED7C4),
                  borderRadius: BorderRadius.circular(10),
                ),
                defaultTextStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                weekendTextStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                weekendStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              selectedDayPredicate: (day) {
                return false;
              },
            ),
          ),
          const SizedBox(height: 30),
          // 그래프
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(30),
              child: SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: false,
                      horizontalInterval: 10,
                      getDrawingHorizontalLine: (value) {
                        if (value % 10 == 0 || value == 0) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.6),
                            strokeWidth: 1,
                          );
                        }
                        return FlLine(
                          color: Colors.transparent,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, _) {
                            if (value == 0 || value == 60) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 15,
                          getTitlesWidget: (value, _) {
                            if (value >= 0 && value <= 5) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 5,
                    minY: -1,
                    maxY: 61,
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(0, 10),
                          FlSpot(1, 30),
                          FlSpot(2, 40),
                          FlSpot(3, 20),
                          FlSpot(4, 50),
                          FlSpot(5, 10),
                        ],
                        isCurved: true,
                        color: const Color(0xFF5ED7C4),
                        barWidth: 4,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF5ED7C4).withOpacity(0.4),
                              const Color(0xFF5ED7C4).withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
