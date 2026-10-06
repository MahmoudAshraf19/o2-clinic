import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class O2CalendarWidget extends StatefulWidget {
  const O2CalendarWidget({super.key});

  @override
  State<O2CalendarWidget> createState() => _O2CalendarWidgetState();
}

class _O2CalendarWidgetState extends State<O2CalendarWidget> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;

  // Example events (replace with API later)
  final Set<DateTime> _eventDays = {
    DateTime.now().add(const Duration(days: 2)),
    DateTime.now().add(const Duration(days: 5)),
    DateTime.now().subtract(const Duration(days: 1)),
  };

  List<DateTime> _buildCalendarDays(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);

    final startWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0
    final daysInMonth = lastDayOfMonth.day;

    final prevMonthLastDay = DateTime(month.year, month.month, 0).day;

    List<DateTime> days = [];

    // Previous month filler
    for (int i = startWeekday - 1; i >= 0; i--) {
      days.add(DateTime(month.year, month.month - 1, prevMonthLastDay - i));
    }

    // Current month
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    // Next month filler (to fill grid 6 rows = 42 cells)
    while (days.length % 7 != 0 || days.length < 42) {
      days.add(
        DateTime(
          month.year,
          month.month + 1,
          days.length - (startWeekday + daysInMonth) + 1,
        ),
      );
    }

    return days;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _hasEvent(DateTime date) {
    return _eventDays.any((e) => _isSameDay(e, date));
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildCalendarDays(_focusedMonth);
    final today = DateTime.now();

    return Center(
      child: Container(
        width: 360,
        decoration: BoxDecoration(
          color: const Color(0xFFF6FAF8),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(blurRadius: 30, color: Colors.black12)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ================= HEADER =================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00685F), Color(0xFF008379)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.MMMM().format(_focusedMonth),
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${_focusedMonth.year}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _focusedMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month - 1,
                            );
                          });
                        },
                        icon: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _focusedMonth = DateTime(
                              _focusedMonth.year,
                              _focusedMonth.month + 1,
                            );
                          });
                        },
                        icon: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ================= WEEK DAYS =================
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Su"),
                  Text("Mo"),
                  Text("Tu"),
                  Text("We"),
                  Text("Th"),
                  Text("Fr"),
                  Text("Sa"),
                ],
              ),
            ),

            // ================= DAYS GRID =================
            Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: days.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  final date = days[index];

                  final isToday = _isSameDay(date, today);
                  final isSelected =
                      _selectedDate != null && _isSameDay(date, _selectedDate!);
                  final isCurrentMonth = date.month == _focusedMonth.month;

                  final hasEvent = _hasEvent(date);

                  Color textColor;
                  BoxDecoration? decoration;

                  if (isSelected) {
                    decoration = const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00685F), Color(0xFF008379)],
                      ),
                      shape: BoxShape.circle,
                    );
                    textColor = Colors.white;
                  } else if (isToday) {
                    decoration = BoxDecoration(
                      border: Border.all(color: const Color(0xFF00685F)),
                      shape: BoxShape.circle,
                    );
                    textColor = const Color(0xFF00685F);
                  } else {
                    textColor = isCurrentMonth ? Colors.black87 : Colors.grey;
                  }

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    child: Container(
                      decoration: decoration,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            "${date.day}",
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          if (hasEvent)
                            const Positioned(
                              bottom: 6,
                              child: CircleAvatar(
                                radius: 2,
                                backgroundColor: Color(0xFF03458F),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ================= FOOTER =================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Selected Date"),
                      Text(
                        _selectedDate == null
                            ? "None"
                            : DateFormat("MMM dd, yyyy").format(_selectedDate!),
                        style: const TextStyle(
                          color: Color(0xFF00685F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00685F),
                    ),
                    onPressed: () {},
                    child: const Text("Continue"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
