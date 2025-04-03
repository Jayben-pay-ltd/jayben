import 'package:flutter/material.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

Widget referenceTextField(BuildContext context, controller) {
  return Padding(
    padding: const EdgeInsets.only(left: 0, right: 0),
    child: TextField(
      minLines: 1,
      maxLines: 5,
      cursorHeight: 24,
      controller: controller,
      textAlign: TextAlign.left,
      style: GoogleFonts.ubuntu(
        fontSize: 24,
        color: Colors.grey[600],
        fontWeight: FontWeight.w300,
      ),
      cursorColor: Colors.grey[700],
      keyboardType: TextInputType.text,
      inputFormatters: [
        LengthLimitingTextInputFormatter(200),
      ],
      decoration: InputDecoration(
        filled: true,
        isDense: false,
        hintStyle: GoogleFonts.ubuntu(
          fontSize: 18,
          color: Colors.grey[500],
        ),
        border: InputBorder.none,
        focusColor: Colors.white,
        hintText: 'Enter a Reference here',
        fillColor: Colors.grey[200],
        errorBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        contentPadding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
        labelStyle: const TextStyle(
            color: Colors.black87, fontSize: 18, fontFamily: 'AvenirLight'),
      ),
    ),
  );
}
