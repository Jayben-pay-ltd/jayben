import 'constants.dart';
import 'provider_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget loadingIcon(context, {Color color = Colors.white, double size = 20}) {
  return SizedBox(
    height: size,
    width: size,
    child: Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color,
      ),
    ),
  );
}

Widget backButton(BuildContext context) {
  return Positioned(
    top: 82.5,
    left: 20,
    child: GestureDetector(
      onTap: () => goBack(context),
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey[200],
        child: Icon(
          Icons.arrow_back,
          color: iconColor,
          size: 40,
        ),
      ),
    ),
  );
}

Widget linearLoadingWidget(BuildContext context) {
  return Positioned(
    top: 0,
    child: SizedBox(
      width: width(context),
      child: const LinearProgressIndicator(
        backgroundColor: Colors.transparent,
        color: Colors.green,
        minHeight: 4,
      ),
    ),
  );
}

Widget loadingScreenDontExit(BuildContext context) {
  return Container(
    color: Colors.white,
    height: height(context),
    width: width(context),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 40,
          width: 40,
          child: CircularProgressIndicator(
            color: Colors.green,
            strokeWidth: 1.5,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          "Don't exit, may take upto 10 seconds.",
          style: GoogleFonts.ubuntu(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        )
      ],
    ),
  );
}

Widget loadingScreenPlain(BuildContext context) {
  return Stack(
    children: [
      Container(
        width: width(context),
        color: Colors.white,
        height: height(context),
        alignment: Alignment.center,
        child: SizedBox(
          height: 40,
          width: 40,
          child: Image.asset(
            "assets/loading.gif",
            height: 20,
          ),
          // CircularProgressIndicator(
          //   color: Colors.green,
          //   strokeWidth: 2,
          // ),
        ),
      ),
      backButton(context)
    ],
  );
}

Widget loadingScreenPlainNoBackButton(BuildContext context) {
  return Container(
    width: width(context),
    color: Colors.white,
    height: height(context),
    alignment: Alignment.center,
    child: SizedBox(
      height: 40,
      width: 40,
      child: Image.asset(
        "assets/loading.gif",
        height: 20,
      ),
    ),
  );
}
