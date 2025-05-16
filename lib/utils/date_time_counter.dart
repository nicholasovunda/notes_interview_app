import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app_interview/utils/current_time.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'date_time_counter.g.dart';

@riverpod
DateTimeSetter dateTimeProvider(Ref ref) {
  final now = ref.watch(currentTimeProvider);

  return DateTimeSetter(
    date: DateFormat.E().format(now),
    time: DateFormat.d().format(now),
  );
}

class DateTimeSetter {
  final String date;
  final String time;

  DateTimeSetter({required this.date, required this.time});
}
