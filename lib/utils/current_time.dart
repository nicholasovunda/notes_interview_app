import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_time.g.dart';

@riverpod
DateTime currentTime(Ref ref) {
  return DateTime.now();
}
