// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

Widget floatingButton(BuildContext context, Map bodyInfo) {
  return Consumer<AdminProviderFunctions>(
    builder: (_, value, child) {
      return FloatingActionButton.extended(
        onPressed: () async {
          if (value.returnIsLoading()) return;

          if (bodyInfo["number_controller"].text.isEmpty) {
            showSnackBar(context, "Enter a phone number");
            return;
          }

          if (bodyInfo["number_controller"].text ==
              value.returnCurrenWIthdrawalReceiverNumber()) {
            showSnackBar(context, "No changes made");
            return;
          }

          hideKeyboard();

          value.toggleIsLoading();

          await value.updateCurrentWithdrawalReceiverNumber(
              bodyInfo["number_controller"].text);

          await value.getCurrentWithdrawalReceiverNumber();

          value.toggleIsLoading();

          // tells user notification has sent
          showSnackBar(context, 'The withdrawal sms receiver has been updated',
              color: Colors.green);

          // routes user back to home page
          goBack(context);
        },
        backgroundColor: Colors.green,
        label: value.returnIsLoading()
            ? loadingIcon(context)
            : Text(
                "SAVE",
                style: GoogleFonts.ubuntu(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                ),
              ),
      );
    },
  );
}

Widget updateWithdrawalSMSReceiverBody(BuildContext context, Map bodyInfo) {
  return Stack(
    children: [
      GestureDetector(
        onTap: () => hideKeyboard(),
        child: Container(
          width: width(context),
          height: height(context),
          alignment: Alignment.center,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 150, bottom: 50),
            children: [
              Text(
                "Update Withdrawal SMS Receiver",
                textAlign: TextAlign.center,
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "This is the number smses will be sent to",
                textAlign: TextAlign.center,
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w300,
                  color: Colors.orange[600],
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),
              textField({
                "hintText": "Number",
                "context": context,
                "labelText": "Phone Number (Example: 0977980371)",
                "controller": bodyInfo['number_controller'],
              }),
            ],
          ),
        ),
      ),
      backButton(context)
    ],
  );
}

Widget textField(Map textfieldInfo) {
  return Container(
    alignment: Alignment.center,
    width: width(textfieldInfo['context']),
    padding: const EdgeInsets.symmetric(horizontal: 30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          textfieldInfo['labelText'],
          style: GoogleFonts.ubuntu(
              color: Colors.black, fontSize: 15, fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 10),
        TextField(
          minLines: 1,
          cursorHeight: 24,
          textAlign: TextAlign.left,
          style: GoogleFonts.ubuntu(
            color: Colors.black,
            fontSize: 24,
          ),
          cursorColor: Colors.grey[400],
          keyboardType: TextInputType.text,
          controller: textfieldInfo['controller'],
          inputFormatters: [
            LengthLimitingTextInputFormatter(
                textfieldInfo['labelText'] == "Title" ? 30 : 200),
          ],
          maxLines: textfieldInfo['labelText'] == "Title" ? 2 : 10,
          decoration: InputDecoration(
            hintText: textfieldInfo['hintText'],
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
              color: Colors.black38,
              fontSize: 24,
            ),
          ),
        ),
      ],
    ),
  );
}
