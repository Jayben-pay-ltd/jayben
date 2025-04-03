// ignore_for_file: non_constant_identifier_names
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

Color goldColor = const Color(0xFFC6AD23);

Color themeColor = Colors.grey[400]!;

Color iconColor = Colors.grey[700]!;

String chat_wallpaper = "assets/wp-wallpaper.png";

Color? chatroom_app_bar_color = Color.fromARGB(255, 28, 28, 28);

Color? chatroom_message_textfield_color = Color.fromARGB(255, 42, 42, 42);

Color? senderMessageBubbleColor = const Color(0xFF273443);
// const Color.fromARGB(255, 38, 101, 49);

Color? receiverMessageBubbleColor = const Color(0xFF444444);

TextStyle googleStyle(
    {FontWeight weight = FontWeight.w300,
    Color color = Colors.black,
    double size = 20}) {
  return GoogleFonts.ubuntu(
    fontSize: size,
    color: color,
    fontWeight: weight,
  );
}
