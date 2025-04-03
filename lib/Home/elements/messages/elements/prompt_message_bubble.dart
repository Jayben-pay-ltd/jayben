import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PromptMessageBubble extends StatelessWidget {
  const PromptMessageBubble({Key? key, required this.message})
      : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    DateTime dateYesterday = DateTime.now().subtract(const Duration(days: 1));
    String dateTodayFormatted = DateFormat.yMMMMd().format(DateTime.now());
    String dateYesterdayFormatted = DateFormat.yMMMMd().format(dateYesterday);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 10,
      ),
      child: Text(
        message != dateTodayFormatted
            ? message == dateYesterdayFormatted
                ? "Yesterday"
                : message
            : "Today",
        textAlign: TextAlign.center,
        style: GoogleFonts.ubuntu(
          fontWeight: FontWeight.w500,
          color: Colors.grey[800],
          fontSize: 17,
        ),
      ),
    );
  }
}
