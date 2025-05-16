import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notes_app_interview/features/notes/data/notes_database.dart';

class CalendarStrip extends ConsumerStatefulWidget {
  final Function(DateTime)? onDateSelected;
  final DateTime selectedDate;

  const CalendarStrip({
    super.key,
    required this.selectedDate,
    this.onDateSelected,
  });

  @override
  ConsumerState<CalendarStrip> createState() => _CalendarStripState();
}

class _CalendarStripState extends ConsumerState<CalendarStrip> {
  late DateTime startDate;
  List<DateTime> dateList = [];

  @override
  void initState() {
    super.initState();
    startDate = _calculateStartOfWeek(widget.selectedDate);
    _generateDateList();
  }

  DateTime _calculateStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  void _generateDateList() {
    dateList = List.generate(7, (index) {
      return startDate.add(Duration(days: index));
    });
  }

  void _selectDate(DateTime date) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DateTime>>(
      future: ref.read(notesProvider.notifier).getUniqueDateTIme(),
      builder: (context, snapshot) {
        final uniqueDates = snapshot.data ?? [];

        return SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (context, index) {
              final day = dateList[index];
              final isSelected = _isSameDay(day, widget.selectedDate);
              final hasNotes = uniqueDates.any((d) => _isSameDay(d, day));

              return GestureDetector(
                onTap: () => _selectDate(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        hasNotes && !isSelected
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.E().format(day),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.d().format(day),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      if (hasNotes)
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.white : Colors.blue,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
