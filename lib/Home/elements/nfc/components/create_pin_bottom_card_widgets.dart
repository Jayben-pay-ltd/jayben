// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/nfc/tag_write.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

Widget createPinBody(BuildContext context, FocusNode focus_node) {
  return Scaffold(
    body: Consumer<NfcProviderFunctions>(
      builder: (_, value, child) {
        return SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: width(context),
                height: height(context) * 0.08,
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Step 1 of 2",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w300,
                        color: Colors.green,
                        fontSize: 18,
                      ),
                    ),
                    hGap(19),
                    Text(
                      "Create a 4 Digit PIN for card",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    hGap(5),
                  ],
                ),
              ),
              Container(
                width: width(context),
                alignment: Alignment.center,
                height: height(context) * 0.15,
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value.returnPinCodeString().isEmpty
                          ? "- - - -"
                          : value.returnPinCodeString().length == 1
                              ? "• - - -"
                              : value.returnPinCodeString().length == 2
                                  ? "• • - -"
                                  : value.returnPinCodeString().length == 3
                                      ? "• • • -"
                                      : "• • • •",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: googleStyle(
                        weight: FontWeight.w300,
                        color: Colors.black,
                        size: 60,
                      ),
                    ),
                    hGap(25),
                    Text(
                      "*Do not share 4 Digit PIN",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              hGap(15),
              numPadWidget(context),
              hGap(15),
              Container(
                width: width(context),
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    actionButtons(context, "Back"),
                    wGap(30),
                    actionButtons(context, "Next"),
                  ],
                ),
              )
            ],
          ),
        );
      },
    ),
  );
}

Widget actionButtons(BuildContext context, String text) {
  return Consumer<NfcProviderFunctions>(
    builder: (_, value, child) {
      return GestureDetector(
        onTap: () async {
          if (text == "Back") {
            goBack(context);
            return;
          }

          if (value.returnPinCodeString().isEmpty) {
            showSnackBar(context, "Create a 4 Digit PIN Code for the card");
            return;
          }

          if (text == "Next") {
            // goBack(context);
            showBottomCard(context, const WriteTageCard(),
                is_dismissble: false, enable_drag: false);

            return;
          }
        },
        child: Container(
          width: 150,
          height: 50,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.grey[200],
          ),
          child: value.returnIsLoading() && text == "Next"
              ? loadingIcon(context)
              : Text(
                  text,
                  style: GoogleFonts.ubuntu(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
        ),
      );
    },
  );
}

Widget buttonWidget(String text) {
  return Consumer<NfcProviderFunctions>(builder: (context, value, child) {
    return GestureDetector(
      onTap: () {
        if (value.returnIsLoading()) return;

        // makes device vibrate once
        Vibrate.feedback(FeedbackType.light);

        if (text == "clear") {
          value.removeCharacter(text);
        } else {
          value.addCharacter(text);
        }
      },
      onLongPressStart: (_) async => await value.startCharacterDeletion(text),
      onLongPressEnd: (_) => value.cancelDeleteCharTimer(),
      child: Container(
        width: width(context) / 3,
        color: Colors.transparent,
        alignment: Alignment.center,
        height: height(context) * 0.09,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: googleStyle(
            size: text == "clear" ? 15 : 30,
            weight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  });
}

Widget numPadWidget(BuildContext context) {
  return Container(
    width: width(context),
    alignment: Alignment.center,
    height: height(context) * 0.40,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buttonWidget("1"),
            buttonWidget("2"),
            buttonWidget("3"),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buttonWidget("4"),
            buttonWidget("5"),
            buttonWidget("6"),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buttonWidget("7"),
            buttonWidget("8"),
            buttonWidget("9"),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buttonWidget("."),
            buttonWidget("0"),
            buttonWidget("clear"),
          ],
        ),
      ],
    ),
  );
}
