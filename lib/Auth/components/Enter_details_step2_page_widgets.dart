import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../Utilities/Constants.dart';
import '../../Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import '../../Home/elements/drawer/elements/components/ProfileWidgets.dart';

Widget enterDetialsText() {
  return Text(
    "Account Security",
    textAlign: TextAlign.center,
    style: GoogleFonts.ubuntu(
      fontWeight: FontWeight.w600,
      color: Colors.grey[800],
      fontSize: 25,
    ),
  );
}

Widget stepCounterWidget() {
  return Text(
    "Step 2 of 2",
    textAlign: TextAlign.center,
    style: GoogleFonts.ubuntu(
      fontWeight: FontWeight.w400,
      color: Colors.green[400],
      fontSize: 20,
    ),
  );
}

Widget requiredTextWidget() {
  return Text(
    "(these will be your login details)",
    textAlign: TextAlign.center,
    style: GoogleFonts.ubuntu(
      fontWeight: FontWeight.w200,
      color: Colors.black,
      fontSize: 15,
    ),
  );
}

Widget customAppBar(BuildContext context) {
  return Positioned(
    top: 0,
    child: Container(
      width: width(context),
      decoration: appBarDeco(),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          wGap(10),
          InkWell(
            onTap: () => goBack(context),
            child: const SizedBox(
              child: Icon(
                color: Colors.black,
                Icons.arrow_back,
                size: 40,
              ),
            ),
          ),
          const Spacer(),
          Text.rich(
            const TextSpan(text: "Create Account"),
            textAlign: TextAlign.left,
            style: GoogleFonts.ubuntu(
              color: const Color.fromARGB(255, 54, 54, 54),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          wGap(50),
        ],
      ),
    ),
  );
}

Widget floatingActionButtonWidgetStep2(onFinish) {
  return Consumer<AuthProviderFunctions>(
    builder: (context, value, child) {
      return FloatingActionButton.extended(
        onPressed: value.returnIsLoading() ? null : onFinish,
        backgroundColor: Colors.green,
        label: value.returnIsLoading()
            ? loadingIcon(context)
            : Text(
                "FINISH",
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
      );
    },
  );
}

Widget exampleNumberWidget() {
  return Padding(
    padding: const EdgeInsets.only(left: 20),
    child: Text(
      "Example: 977 980 371",
      textAlign: TextAlign.left,
      style: GoogleFonts.ubuntu(
        fontWeight: FontWeight.w300,
        color: Colors.green[600],
        fontSize: 15,
      ),
    ),
  );
}

Widget emailTextField(controller) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email Address*",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        hGap(10),
        TextField(
          cursorHeight: 24,
          cursorColor: iconColor,
          maxLines: 1,
          autocorrect: false,
          enableSuggestions: false,
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          textCapitalization: TextCapitalization.none,
          inputFormatters: [
            LengthLimitingTextInputFormatter(150),
            FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
          ],
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Email',
            isDense: true,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            hintStyle: GoogleFonts.ubuntu(
              fontSize: 24,
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget pinTextfield(controller) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "6 Digit PIN*",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        hGap(10),
        TextField(
          cursorHeight: 24,
          obscureText: true,
          cursorColor: Colors.grey[700],
          maxLines: 1,
          textCapitalization: TextCapitalization.words,
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(6),
            FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
            FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
          ],
          textAlign: TextAlign.left,
          style: GoogleFonts.ubuntu(
            fontSize: 24,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: "PIN",
            isDense: true,
            filled: true,
            fillColor: Colors.grey[200],
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            hintStyle: GoogleFonts.ubuntu(
              fontSize: 24,
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget confirmPinTextfield(controller) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Confirm 6 Digit PIN*",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        hGap(10),
        TextField(
          cursorHeight: 24,
          obscureText: true,
          cursorColor: Colors.grey[700],
          maxLines: 1,
          textCapitalization: TextCapitalization.words,
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            LengthLimitingTextInputFormatter(6),
            FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
            FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
          ],
          textAlign: TextAlign.left,
          style: GoogleFonts.ubuntu(
            fontSize: 24,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: "confirm PIN",
            isDense: true,
            filled: true,
            fillColor: Colors.grey[200],
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            hintStyle: GoogleFonts.ubuntu(
              fontSize: 24,
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget passwordTextField(controller) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password* (must be 9 characters or more)",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        hGap(10),
        TextField(
          cursorHeight: 24,
          cursorColor: iconColor,
          maxLines: 1,
          obscureText: false,
          textCapitalization: TextCapitalization.none,
          controller: controller,
          keyboardType: TextInputType.text,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1000),
            FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
          ],
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Password',
            isDense: true,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            hintStyle: GoogleFonts.ubuntu(
              fontSize: 24,
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget passwordConfirmTextField(controller) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Confirm Password* (must also be 9 characters or more)",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        hGap(10),
        TextField(
          cursorHeight: 24,
          cursorColor: iconColor,
          maxLines: 1,
          obscureText: true,
          textCapitalization: TextCapitalization.none,
          controller: controller,
          keyboardType: TextInputType.text,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1000),
            FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
          ],
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Password confirm',
            isDense: true,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            hintStyle: GoogleFonts.ubuntu(
              fontSize: 24,
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget whoReferedYouText(context) {
  return Container(
    width: width(context),
    padding: const EdgeInsets.only(left: 30),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Who referred you',
            style: GoogleFonts.ubuntu(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          TextSpan(
            text: '\nto Jayben?',
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.bold,
              color: Colors.green[400],
              fontSize: 22,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.left,
    ),
  );
}

Widget referralCodeTextfield(referralCodeController) {
  return Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Enter their Jayben Username (optional)",
          style: GoogleFonts.ubuntu(
              color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        hGap(10),
        TextField(
          cursorHeight: 24,
          cursorColor: Colors.grey[700],
          maxLines: 1,
          autocorrect: false,
          enableSuggestions: false,
          controller: referralCodeController,
          keyboardType: TextInputType.text,
          inputFormatters: [
            LengthLimitingTextInputFormatter(20),
          ],
          textAlign: TextAlign.left,
          style: GoogleFonts.ubuntu(
            fontSize: 24,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Example: Vanessa420',
            isDense: true,
            filled: true,
            fillColor: Colors.grey[200],
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            hintStyle: GoogleFonts.ubuntu(
              fontSize: 20,
              color: Colors.grey[500],
            ),
          ),
        ),
      ],
    ),
  );
}
