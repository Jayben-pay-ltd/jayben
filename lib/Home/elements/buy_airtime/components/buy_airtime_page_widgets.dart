import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

Widget airtimeBody(BuildContext context) {
  return Consumer<AirtimeProviderFunctions>(
    builder: (_, value, child) {
      return SizedBox(
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
                    value.current_page_index == 0
                        ? "Step 1 of 2"
                        : "Step 2 of 2",
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
                        ? "Amount of Airtime To Buy"
                        : "Phone Number To Buy For",
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
                        ? "*Minimum purchase amount is ${box("CurrencySymbol") != "Zambia" ? box("CurrencySymbol") : box("Currency")}${box("AirtimePurchaseMinimum")}"
                        : "*Airtel, MTN & Zamtel Only",
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
            // hGap(20),
            // depositMethodWidget(context),
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
                  actionButtons(
                      context, value.current_page_index == 1 ? "Buy" : "Next"),
                ],
              ),
            )
          ],
        ),
      );
    },
  );
}

Widget depositMethodWidget(BuildContext context) {
  return Consumer<AirtimeProviderFunctions>(
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
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                  child: Text(
                    value.returnPaymentMethod(),
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
                    items: <String>['Pay With Wallet', "Pay With Points"].map(
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
  return Consumer<AirtimeProviderFunctions>(
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
            showSnackBar(context, "Enter an amount to buy");
            return;
          }

          double amount = double.parse(value.returnAmountString());

          double minAirtimeAmount =
              double.parse("${box("AirtimePurchaseMinimum")}");

          if (amount < minAirtimeAmount) {
            showSnackBar(context,
                'Minimum airtime amount is ${box("Currency")} $minAirtimeAmount');

            return;
          }

          // checks if points are enough
          if (value.returnPaymentMethod() == "Pay With Points") {
            var myPoints = double.parse("${box("Points")}");

            var valuePerPoint = double.parse("${box("ValuePerPointKwacha")}");

            var pointNeededToPay = amount / valuePerPoint;

            // if the number of points are not enough
            if (myPoints < pointNeededToPay) {
              showSnackBar(
                  context,
                  'Points not enough. You need ${pointNeededToPay.toStringAsFixed(0)}'
                  ' Points to cover ${box("Currency")} ${amount.toStringAsFixed(2)} airtime');

              return;
            }
          } else {
            value.toggleIsLoading();

            // gets the user's current balance
            double walletBal = await getUserBalance();

            value.toggleIsLoading();

            // if wallet balance isn't enough
            if (walletBal < amount) {
              showSnackBar(context, "Your Wallet Balance is not enough.");
              return;
            }
          }

          if (text == "Next" && value.returnCurrentPageIndex() == 0) {
            value.changePageIndex(1);
            return;
          }

          if (text == "Next" &&
              value.returnPaymentMethod() == "Pay With Points" &&
              value.returnCurrentPageIndex() == 1) {
            await value.payWithPoints(context);
            return;
          }

          await value.payWithWallet(context);
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
                fontWeight: FontWeight.w400,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          );
  });
}

Widget buttonWidget(String text) {
  return Consumer<AirtimeProviderFunctions>(builder: (context, value, child) {
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
