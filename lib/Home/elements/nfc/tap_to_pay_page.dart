// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jayben/Home/elements/nfc/components/tap_to_pay_page_widgets.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Home/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class TapToPayPage extends StatefulWidget {
  const TapToPayPage({Key? key, required this.paymentInfo})
      : super(key: key);

  final Map paymentInfo;

  @override
  _TapToPayPageState createState() => _TapToPayPageState();
}

class _TapToPayPageState extends State<TapToPayPage> {
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
                      "Name: ${widget.paymentInfo['receiver_map']["full_names"]}",
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
                          ? "${box("currency_symbol") != "ZMW" ? box("currency_symbol") : box("currency")}0"
                          : "${box("currency_symbol") != "ZMW" ? box("currency_symbol") : box("currency")}${value.returnAmountString()}",
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
                      widget.paymentInfo
                    ),
                    wGap(30),
                    actionButtons(context, "Pay", widget.paymentInfo),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    });
  }  
}
