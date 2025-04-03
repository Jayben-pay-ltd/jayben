// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Home/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

Widget donateToSharedNasAccBody(BuildContext context, Map map) {
  return Consumer<SavingsProviderFunctions>(
    builder: (_, value, child) {
      return Column(
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
                  map["account_name"].toUpperCase(),
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
                  "Amount To Donate",
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
            height: height(context) * 0.20,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.returnAmountString().isEmpty
                      ? "${box("CurrencySymbol") != "Zambia" ? box("CurrencySymbol") : box("Currency")}0"
                      : "${box("CurrencySymbol") != "Zambia" ? box("CurrencySymbol") : box("Currency")}${value.returnAmountString()}",
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
                  "*Minimum amount to save is ${box("CurrencySymbol") != "Zambia" ? box("CurrencySymbol") : box("Currency")}1",
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
                actionButtons(context, {...map, "text": "Back"}),
                wGap(30),
                actionButtons(context, {...map, "text": "Save"}),
              ],
            ),
          )
        ],
      );
    },
  );
}

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
                color: Colors.grey[800],
              ),
              child: Text(
                "Wallet bal: ${box("CurrencySymbol")}${double.parse(box("Balance").toString()).toStringAsFixed(2)}",
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

Widget actionButtons(BuildContext context, Map map) {
  return Consumer<SavingsProviderFunctions>(
    builder: (_, value, child) {
      return GestureDetector(
        onTap: () async {
          if (map["text"] == "Back") {
            goBack(context);
            return;
          }

          if (value.returnAmountString().isEmpty) {
            showSnackBar(context, "Enter an amount to save");
            return;
          }

          double amountToSave = double.parse(value.returnAmountString());

          if (value.returnIsLoading()) return;

          value.toggleIsLoading();

          // gets the user's current balance
          double walletBal = await getUserBalance();

          value.toggleIsLoading();

          // min amount that can be saved
          double minSavingsDeposit = double.parse(box('MinimumSavingsDeposit'));

          if (walletBal < amountToSave) {
            showSnackBar(context, 'Wallet balance not enough.');

            return;
          }

          if (minSavingsDeposit > amountToSave) {
            showSnackBar(context,
                'Minimum transfer amount that can be saved is ${box("Currency")} ${box("MinimumSavingsDeposit")}');

            return;
          }

          value.toggleIsLoading();

          // adds money to a shared nas account
          bool is_donated = await value.donateToSharedNasAccount({
            "account_id": map["account_id"],
            "amount": amountToSave,
          });

          value.toggleIsLoading();

          if (is_donated) {
            showSnackBar(context,
                'You have donated ${box("Currency")} $amountToSave! 💰',
                color: Colors.green[700]!);

            changePage(context, const HomePage(), type: "pr");
          } else {
            showSnackBar(context, 'Donation failed. Please try again.', color: Colors.red);
          }
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
          child: value.returnIsLoading() && map["text"] == "Save"
              ? loadingIcon(context)
              : Text(
                  map["text"],
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

Widget buttonWidget(String text) {
  return Consumer<SavingsProviderFunctions>(builder: (context, value, child) {
    return GestureDetector(
      onTap: () {
        if (value.returnIsLoading()) return;

        if (text == "<") {
          value.removeCharacter(text);
        } else {
          value.addCharacter(text);
        }

        // makes device vibrate once
        Vibrate.feedback(FeedbackType.heavy);
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
            weight: FontWeight.w500,
            color: Colors.white,
            size: 30,
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
            buttonWidget("<"),
          ],
        ),
      ],
    ),
  );
}
