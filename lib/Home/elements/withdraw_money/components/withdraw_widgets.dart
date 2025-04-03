// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:jayben/Utilities/provider_functions.dart';

Widget withdrawBody(BuildContext context) {
  return Consumer<WithdrawProviderFunctions>(builder: (_, value, child) {
    return Container(
      width: width(context),
      height: height(context),
      color: Colors.grey[900],
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
                      ? "Amount To Withdraw"
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
          hGap(10),
          balanceWidget(),
          Container(
            width: width(context),
            alignment: Alignment.center,
            height: height(context) * 0.25,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.current_page_index == 0
                      ? value.returnAmountString().isEmpty
                          ? "${box("CurrencySymbol")}0"
                          : "${box("CurrencySymbol")}${value.returnAmountString()}"
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
                      ? "*Minimum withdraw amount is ${box("CurrencySymbol")}2"
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
                    value.current_page_index == 1 ? "Withdraw" : "Next"),
              ],
            ),
          )
        ],
      ),
    );
  });
}

Widget actionButtons(BuildContext context, String text) {
  return Consumer<WithdrawProviderFunctions>(
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
            showSnackBar(context, "Enter an amount to withdraw");

            return;
          }

          double amount = double.parse(value.returnAmountString());

          double withdrawFeeCapAmount =
              double.parse("${box("WithdrawFeeCapAmount")}");

          double WithdrawFeeCapThresholdAmountKwacha =
              double.parse("${box("WithdrawFeeCapThresholdAmountKwacha")}");

          double withdrawFeePercent =
              double.parse("${box("WithdrawFeePercent")}");

          double amountPlusFee = 0.0;

          double feeAmount = 0.0;

          // if amount is greater than when the cap is enforced
          if (amount >= WithdrawFeeCapThresholdAmountKwacha) {
            amountPlusFee = amount + withdrawFeeCapAmount;
            feeAmount = withdrawFeeCapAmount;
          } else {
            amountPlusFee = amount + (amount * (withdrawFeePercent / 100));
            feeAmount = amount * (withdrawFeePercent / 100);
          }

          // if amount is out of withdraw limits
          if (amount < 2) {
            showSnackBar(context,
                "Minimum withdraw amount is ${box("CurrencySymbol")} 2");

            return;
          }

          if (text == "Next") {
            value.toggleIsLoading();

            // gets the user's current balance
            double walletBal = await getUserBalance();

            value.toggleIsLoading();

            if (walletBal < amountPlusFee) {
              showSnackBar(
                  context,
                  "Your Wallet balance is not enough. Please account for the "
                  "${box("CurrencySymbol")} ${(feeAmount).toStringAsFixed(2)} "
                  "withdraw fee");

              return;
            }
          }

          if (text == "Next" && value.returnCurrentPageIndex() == 0) {
            value.changePageIndex(1);
            return;
          }

          await value.prepareWithdrawal(context, {
            "amountPlusFee": amountPlusFee,
            "amountBeforeFee": amount,
            "feeAmount": feeAmount,
          });
        },
        child: Container(
          width: 150,
          height: 50,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.grey[800],
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

Widget balanceWidget() {
  return Consumer<WithdrawProviderFunctions>(builder: (_, value, child) {
    return value.returnCurrentPageIndex() == 1
        ? nothing()
        : Container(
            width: 300,
            height: 40,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.grey[800],
            ),
            child: Text(
              "Wallet bal: ${box("CurrencySymbol")}${double.parse(box("Balance").toString()).toStringAsFixed(2)}",
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 15,
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

Widget buttonWidget(String text) {
  return Consumer<WithdrawProviderFunctions>(builder: (context, value, child) {
    return GestureDetector(
      onTap: () {
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
