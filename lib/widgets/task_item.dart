import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskItem extends StatelessWidget {
  const TaskItem({
    super.key,
    required this.taskTitle,
    required this.taskColor,
    required this.onTap,
  });

  final String taskTitle;
  final Color taskColor;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(
          bottom: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF000002),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: taskColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF791EC6),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Text(
                taskTitle,
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: 3,
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: 14,
                  decorationColor: Colors.white,
                  decorationThickness: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
