// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import '../../../../Utilities/general_widgets.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/send_money/elements/select_receiver_page.dart';
import 'package:jayben/Home/elements/attach_media/components/attach_media_widgets.dart';

Widget sendMoneyFloatingButton(
    BuildContext context, amountController, usernameController) {
  return Consumer<PaymentProviderFunctions>(
    builder: (_, value, child) {
      return FloatingActionButton.extended(
        onPressed: () async {},
        backgroundColor: Colors.green,
        label: value.returnIsLoading()
            ? loadingIcon(context)
            : Row(
                children: [
                  Image.asset(
                    color: Colors.white,
                    'assets/send.png',
                    height: 20,
                    width: 20,
                  ),
                  wGap(10),
                  const Text("Send Money"),
                ],
              ),
      );
    },
  );
}

Widget commentTextField(BuildContext context, Map body_info) {
  return Padding(
    padding: const EdgeInsets.only(left: 0, right: 0),
    child: TextField(
      cursorHeight: 24,
      cursorColor: Colors.grey[700],
      minLines: 1,
      maxLines: 10,
      controller: body_info["comment_controller"],
      keyboardType: TextInputType.text,
      inputFormatters: [
        LengthLimitingTextInputFormatter(300),
      ],
      textAlign: TextAlign.left,
      style: GoogleFonts.ubuntu(
        fontSize: 24,
        color: Colors.grey[600],
        fontWeight: FontWeight.w300,
      ),
      decoration: InputDecoration(
        suffixIcon: GestureDetector(
          onTap: () => showBottomCard(
            context,
            selectMediaCard(
              context,
              {
                "transaction_type": "p2p transfer",
                ...body_info,
              },
            ),
          ),
          child: Icon(
            color: Colors.grey[500],
            Icons.camera_alt_rounded,
            size: 20,
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
        filled: true,
        fillColor: Colors.grey[200],
        focusColor: Colors.white,
        isDense: false,
        alignLabelWithHint: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelStyle: const TextStyle(
            color: Colors.black87, fontSize: 18, fontFamily: 'AvenirLight'),
        hintText: body_info["payment_info"]["payment_means"] == "Username"
            ? 'Write a Comment for ${body_info["payment_info"]["receiver_map"]["first_name"]} to see...'
            : 'Comment (Optional)',
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hintStyle: GoogleFonts.ubuntu(
          color: Colors.grey[500],
          fontSize: 15,
        ),
      ),
    ),
  );
}

Widget sendMoneyUsernameBody(BuildContext context) {
  return Consumer<PaymentProviderFunctions>(builder: (_, value, child) {
    return Container(
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
                  "Step 1 of 2",
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
                  "Amount To Send To Friend",
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
            child: Text(
              value.returnAmountString().isEmpty
                  ? "${box("currency_symbol") != "Zambia" ? box("currency_symbol") : box("currency")}0"
                  : "${box("currency_symbol") != "Zambia" ? box("currency_symbol") : box("currency")}${value.returnAmountString()}",
              maxLines: 3,
              textAlign: TextAlign.center,
              style: googleStyle(
                weight: FontWeight.w600,
                color: Colors.white,
                size: 60,
              ),
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
                actionButtons(context, "Back"),
                wGap(30),
                actionButtons(context, "Next"),
              ],
            ),
          )
        ],
      ),
    );
  });
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
                "Wallet bal: ${box("currency_symbol")}${double.parse(box("balance").toString()).toStringAsFixed(2)}",
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

Widget actionButtons(BuildContext context, String text) {
  return Consumer<PaymentProviderFunctions>(
    builder: (_, value, child) {
      return GestureDetector(
        onTap: () async {
          if (text == "Back") {
            goBack(context);
            return;
          }

          if (value.returnAmountString().isEmpty) {
            showSnackBar(context, "Enter an amount to send");
            return;
          }

          if (value.returnIsLoading()) return;

          value.toggleIsLoading();

          // gets the user's current balance
          double walletBal = await getUserBalance();

          value.toggleIsLoading();

          double amount = double.parse(value.returnAmountString());

          // if user's waller bal isn't enough
          if (walletBal < amount) {
            showSnackBar(context, 'Your Wallet balance is not enough.');

            return;
          }

          changePage(
            context,
            const SeelctReceiverPage(),
          );
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

Widget buttonWidget(String text) {
  return Consumer<PaymentProviderFunctions>(builder: (context, value, child) {
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
