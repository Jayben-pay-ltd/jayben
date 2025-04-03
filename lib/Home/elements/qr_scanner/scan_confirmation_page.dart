// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jayben/Home/home_page.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/send_money/send_money_confirmation_qr.dart';

class SendMoneyByQRCode extends StatefulWidget {
  const SendMoneyByQRCode({Key? key, required this.paymentInfo})
      : super(key: key);

  final Map paymentInfo;

  @override
  _SendMoneyByQRCodeState createState() => _SendMoneyByQRCodeState();
}

class _SendMoneyByQRCodeState extends State<SendMoneyByQRCode> {
  @override
  void initState() {
    context.read<QRScannerProviderFunctions>().clearAllVariables();
    super.initState();
  }

  final amountToSendController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.green[700],
        body: qrCodeScannerBody(context),
      ),
    );
  }

  Widget qrCodeScannerBody(BuildContext context) {
    return Consumer<QRScannerProviderFunctions>(builder: (_, value, child) {
      return WillPopScope(
        onWillPop: () async {
          changePage(context, const HomePage(), type: "pr");
          return Future.value(false);
        },
        child: Container(
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
                      "Amount To Pay",
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
                      "Name: ${widget.paymentInfo['receiverDoc'].get("FirstName")} "
                      "${widget.paymentInfo['receiverDoc'].get("LastName")}",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 20,
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
                    actionButtons(
                      context,
                      "Back",
                    ),
                    wGap(30),
                    actionButtons(context, "Pay"),
                  ],
                ),
              )
            ],
          ),
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
                  color: Colors.green[800],
                ),
                child: Text(
                  "Wallet bal: ${box("CurrencySymbol")}"
                  "${double.parse(box("Balance").toString()).toStringAsFixed(2)}",
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
    return Consumer<QRScannerProviderFunctions>(
      builder: (_, value, child) {
        return GestureDetector(
          onTap: () async {
            if (text == "Back") {
              if (widget.paymentInfo["scan_type"] == "NFC") {
                changePage(context, const HomePage(), type: "pr");
                return;
              } else {
                goBack(context);
              }
              return;
            }

            if (value.returnAmountString().isEmpty) {
              showSnackBar(context, "Enter an amount to pay");
              return;
            }

            double amount = double.parse(value.returnAmountString());

            double amount_plus_merchant_fee = double.parse(
                    box("MerchantCommissionPerTransaction").toString()) +
                amount;

            value.toggleIsLoading();

            // gets the user's current balance
            double walletBal = await getUserBalance();

            value.toggleIsLoading();

            if (walletBal < amount_plus_merchant_fee) {
              showSnackBar(
                  context,
                  'Your Wallet balance is not enough. Please account for the ${box("Currency")} '
                  '${(double.parse(box("MerchantCommissionPerTransaction").toString())).toStringAsFixed(2)} fee');

              return;
            }

            changePage(
              context,
              PaymentConfirmationQr(
                paymentInfo: {
                  "amount_plus_merchant_fee": amount_plus_merchant_fee,
                  "payment_means": "QR",
                  ...widget.paymentInfo,
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
}
