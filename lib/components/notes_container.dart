import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class NotesContainer extends ConsumerStatefulWidget {
  const NotesContainer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotesContainerState();
}

class _NotesContainerState extends ConsumerState<NotesContainer> {
  bool isPinned = false;
  String? title;
  String? text;
  Color? color;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: color ?? cat, // TODO: add color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title ?? "",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 10.sp,
                  ),
                ),
                Visibility(
                  visible: isPinned,
                  child: Icon(Icons.push_pin, color: Colors.white),
                ),
              ],
            ),
            Gap(10),
            Text(text ?? "", textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
