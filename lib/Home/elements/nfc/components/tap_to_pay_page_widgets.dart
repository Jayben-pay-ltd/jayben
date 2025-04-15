// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Home/elements/nfc/nfc_payment_confirmation.dart';
import 'package:jayben/Home/home_page.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/provider_functions.dart';

Widget balanceWidget() {
  return Consumer<WithdrawProviderFunctions>(
    builder: (_, value, child) {
      return value.returnCurrentPageIndex() == 1
          ? nothing()
          : Container(
              width: 300,
              height: 40,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.green[800],
              ),
              child: Text(
                "Wallet bal: ${box("currency_symbol")}"
                "${double.parse(box("balance").toString()).toStringAsFixed(2)}",
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            );
    },
  );
}

Widget actionButtons(BuildContext context, String text, Map paymentInfo) {
  String account_type = paymentInfo["receiver_map"]["type_of_receiver_account"];
  return Consumer<QRScannerProviderFunctions>(
    builder: (_, value, child) {
      return GestureDetector(
        onTap: () async {
          if (text == "Back") {
            changePage(context, const HomePage(), type: "pr");
            return;
          }

          if (value.returnAmountString().isEmpty) {
            showSnackBar(context, "Enter an amount to pay");

            return;
          }

          double amount = double.parse(value.returnAmountString());

          double? amount_plus_transaction_fee;

          if (account_type == "Merchant Account") {
            amount_plus_transaction_fee = double.parse(
                    box("merchant_commission_per_transaction").toString()) +
                amount;
          } else {
            amount_plus_transaction_fee = amount;
          }

          value.toggleIsLoading();

          // gets the user's current balance
          double walletBal = await getUserBalance();

          value.toggleIsLoading();

          if (walletBal < amount_plus_transaction_fee) {
            if (account_type == "Merchant Account") {
              showSnackBar(
                  context,
                  'Your Wallet balance is not enough. Please account for the ${box("currency")} '
                  '${(double.parse(box("merchant_commission_per_transaction").toString())).toStringAsFixed(2)} fee');
              return;
            }

            showSnackBar(context,
                'Your Wallet balance is not enough. Please top up your wallet to continue');

            return;
          }

          changePage(
            context,
            PaymentConfirmationNFC(
              paymentInfo: {
                "full_names": "${paymentInfo["receiver_map"]["full_names"]}",
                "amount_plus_transaction_fee": amount_plus_transaction_fee,
                "user_code": paymentInfo["receiver_map"]["user_code"],
                "account_type": account_type,
                "payment_means": "NFC",
                "amount": amount,
              },
            ),
          );
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
          child: value.returnIsLoading() && text != "Back"
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
  return Consumer<QRScannerProviderFunctions>(
    builder: (context, value, child) {
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
    },
  );
}
