// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/agent_deposits/agent_deposits.dart';

Widget body(BuildContext context) {
  return Consumer<DepositProviderFunctions>(builder: (_, value, child) {
    return Container(
      width: width(context),
      height: height(context),
      color: Colors.green[700],
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: width(context),
            height: height(context) * 0.12,
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.current_page_index == 0 ? "Step 1 of 2" : "Step 2 of 2",
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w300,
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                hGap(10),
                Text(
                  value.current_page_index == 0
                      ? "Amount To Deposit"
                      : "Mobile Money Phone Number",
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
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
            height: height(context) * 0.20,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.current_page_index == 0
                      ? value.returnAmountString().isEmpty
                          ? "${box("CurrencySymbol") != "Zambia" ? box("CurrencySymbol") : box("Currency")}0"
                          : "${box("CurrencySymbol") != "Zambia" ? box("CurrencySymbol") : box("Currency")}${value.returnAmountString()}"
                      : value.returnPhoneNumberString().isEmpty
                          ? "0"
                          : value.returnPhoneNumberString(),
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: googleStyle(
                    weight: FontWeight.w600,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                hGap(10),
                Text(
                  value.current_page_index == 0
                      ? "*Minimum deposit amount is ${box("CurrencySymbol") != "Zambia" ? box("CurrencySymbol") : box("Currency")}1"
                      : "*Airtel, MTN & Zamtel Money Supported",
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          hGap(20),
          depositMethodWidget(context),
          hGap(20),
          numPadWidget(context),
          hGap(20),
          Container(
            width: width(context),
            alignment: Alignment.center,
            margin: const EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                actionButtons(context, "Back"),
                wGap(30),
                actionButtons(context,
                    value.current_page_index == 1 ? "Deposit" : "Next"),
              ],
            ),
          )
        ],
      ),
    );
  });
}

Widget depositMethodWidget(BuildContext context) {
  List<String> deposit_options = [];

  if (box("EnableInstantDeposits")) {
    deposit_options = [
      "Via Mobile Money",
      // "Via Jayben Agent",
    ];
  } else {
    // deposit_options.add("Via Jayben Agent");
  }

  if (box("EnableCreditDebitCardDeposits")) {
    deposit_options.add("Via Credit/Debit Card");
  }

  deposit_options.add("Via Mobile Money");
  deposit_options.add("Via Credit/Debit Card");

  return Consumer<DepositProviderFunctions>(
    builder: (_, value, child) {
      return value.returnCurrentPageIndex() == 1
          ? nothing()
          : Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 50,
                  width: width(context) * 0.7,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40.0),
                    color: Colors.green[800],
                  ),
                  child: Text(
                    value.returnSelectedDepositMethod(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ubuntu(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ), //height
                Positioned(
                  right: 50,
                  child: DropdownButton<String>(
                    underline: const SizedBox(),
                    dropdownColor: Colors.white,
                    iconEnabledColor: Colors.white,
                    iconDisabledColor: Colors.white,
                    items: deposit_options.map(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child:
                              Text(value, style: const TextStyle(fontSize: 18)),
                        );
                      },
                    ).toList(),
                    onChanged: (String? text) => value.ChooseMethod(text!),
                  ),
                )
              ],
            );
    },
  );
}

Widget actionButtons(BuildContext context, String text) {
  return Consumer<DepositProviderFunctions>(
    builder: (_, value, child) {
      return GestureDetector(
        onTap: () async {
          if (text == "Back" && value.returnCurrentPageIndex() == 0) {
            goBack(context);
            return;
          } else if (text == "Back" && value.returnCurrentPageIndex() == 1) {
            value.changePageIndex(0);
            return;
          }

          if (value.returnAmountString().isEmpty) {
            showSnackBar(context, "Enter an amount to deposit");
            return;
          }

          double amount = double.parse(value.returnAmountString());

          if (amount < 1) {
            showSnackBar(context,
                'Minimum deposit amount is ${box("CurrencySymbol") != "Zambia" ? box("CurrencySymbol") : box("Currency")}1');

            return;
          }

          if (text == "Next" &&
              value.returnSelectedDepositMethod() == "Via Credit/Debit Card" &&
              value.returnCurrentPageIndex() == 0) {
            // gets checkout link and opens webview page
            await value.prepareCardDeposit(context);
            return;
          }

          if (text == "Next" &&
              value.returnSelectedDepositMethod() == "Via Mobile Money" &&
              value.returnCurrentPageIndex() == 0) {
            // asks user to enter mobile money number
            value.changePageIndex(1);
            return;
          }

          if (text == "Next" &&
              value.returnSelectedDepositMethod() == "Via Jayben Agent" &&
              value.returnCurrentPageIndex() == 0) {
            // routes user to the agent deposits page
            changePage(context, AgentDepositsPage(amount: amount));
            return;
          }

          await value.prepareDeposit(context);
        },
        child: Container(
          width: 150,
          height: 50,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.green[800],
          ),
          child: value.returnIsLoading() && text == "Next"
              ? loadingIcon(context)
              : Text(
                  text,
                  style: GoogleFonts.ubuntu(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
        ),
      );
    },
  );
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

Widget buttonWidget(String text) {
  return Consumer<DepositProviderFunctions>(builder: (context, value, child) {
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
      onLongPressStart: (details) async =>
          await value.startCharacterDeletion(text),
      onLongPressEnd: (details) => value.cancelDeleteCharTimer(),
      child: Container(
        width: width(context) / 3,
        color: Colors.transparent,
        alignment: Alignment.center,
        height: height(context) * 0.1,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: googleStyle(
            size: text == "clear" ? 15 : 30,
            weight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  });
}
