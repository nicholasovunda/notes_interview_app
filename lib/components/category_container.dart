import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryContainer extends ConsumerWidget {
  final bool isFilled;
  final String category;
  final VoidCallback? onPressed;
  const CategoryContainer({
    this.isFilled = false,
    required this.category,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgColor = isFilled ? Colors.black : Colors.white;
    final textColor = isFilled ? Colors.white : Colors.black;
    final borderColor = isFilled ? Colors.transparent : Colors.grey.shade400;
    return GestureDetector(
      onTap: onPressed,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            category,
            style: TextStyle(color: textColor, fontSize: 6.sp),
          ),
        ),
      ),
    );
  }
}
