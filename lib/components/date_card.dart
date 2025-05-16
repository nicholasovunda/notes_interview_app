import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class DateCard extends ConsumerWidget {
  final bool isFilled;
  final String day;
  final String date;
  final VoidCallback? onPressed;

  const DateCard({
    super.key,
    this.isFilled = false,
    this.onPressed,
    required this.day,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColor = isFilled ? Colors.black : Colors.white;
    final textColor = isFilled ? Colors.white : Colors.black;
    final borderColor = isFilled ? Colors.transparent : Colors.grey.shade400;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              day,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w300,
                fontSize: 12.sp,
              ),
            ),
            Gap(8),
            Text(date, style: TextStyle(color: textColor, fontSize: 16.sp)),
          ],
        ),
      ),
    );
  }
}
