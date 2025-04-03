// ignore_for_file: non_constant_identifier_names

import 'package:jayben/Home/elements/qr_scanner/scan_confirmation_page.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../scan_page.dart';

Widget flashButton(QRViewController? qr_controller) {
  return Consumer<QRScannerProviderFunctions>(
    builder: (_, value, child) {
      return Positioned(
        top: 60,
        right: 40,
        child: SizedBox(
          height: 50,
          width: 50,
          child: GestureDetector(
            onTap: () async {
              value.toggleFlashLight();
              
              await qr_controller!.toggleFlash();
            },
            child: value.returnIsFlashActive()
                ? const Icon(Icons.flash_off, color: Colors.white, size: 40)
                : const Icon(Icons.flash_on, color: Colors.white, size: 40),
          ),
        ),
      );
    },
  );
}

Widget closeButton(BuildContext context) {
  return Positioned(
    top: 60,
    left: 40,
    child: GestureDetector(
      onTap: () => goBack(context),
      child: const SizedBox(
        height: 60,
        width: 60,
        child: Icon(
          Icons.close,
          color: Colors.white,
          size: 40,
        ),
      ),
    ),
  );
}

Widget payNowButton(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: Colors.green,
      borderRadius: BorderRadius.all(
        Radius.circular(20),
      ),
    ),
    height: 40,
    width: 200,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/send.png',
          height: 20,
          width: 20,
          color: Colors.white,
        ),
        wGap(10),
        const Text(
          "Pay Now",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget qrCard(BuildContext context) {
  return SizedBox(
    width: width(context),
    height: height(context) * 0.6,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25, bottom: 31.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: FittedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Ask sender to scan this QR',
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontSize: 15,
                ),
              ),
              GestureDetector(
                onTap: () => changePage(context, const QRScannerPage()),
                child: QrImageView(
                  version: QrVersions.auto,
                  data: box("user_id"),
                  size: 200,
                ),
              ),
              hGap(10),
              GestureDetector(
                onTap: () => changePage(context, const QRScannerPage()),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 23,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 30,
                      ),
                    ),
                    wGap(10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pay via QR code",
                          style: GoogleFonts.ubuntu(
                            color: const Color(0xFF616161),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        hGap(2),
                        Text(
                          "Press here to scan a QR code",
                          style: GoogleFonts.ubuntu(
                            color: const Color(0xFF616161),
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget scannerYellowBox(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SizedBox(
        width: width(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner_rounded,
                size: 30, color: Colors.white),
            wGap(10),
            Text(
              'Scan QR to PAY',
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      hGap(20),
      Container(
        width: width(context) * 0.7,
        height: height(context) * 0.37,
        margin: const EdgeInsets.all(15.0),
        padding: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(border: Border.all(color: Colors.yellow)),
      ),
      Container(
        alignment: Alignment.center,
        width: width(context),
        child: Text(
          'OR',
          style: GoogleFonts.ubuntu(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      )
    ],
  );
}

Widget payViaVendorCodeInstead(BuildContext context) {
  return Container(
    width: width(context),
    alignment: Alignment.center,
    child: Text(
      'Pay Using A Payment Code?',
      textAlign: TextAlign.center,
      style: GoogleFonts.ubuntu(
        fontWeight: FontWeight.w700,
        color: Colors.green,
        fontSize: 20,
      ),
    ),
  );
}

Widget vendorCodeTextField(
    BuildContext context, TextEditingController controller) {
  return Consumer<QRScannerProviderFunctions>(builder: (_, value, child) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Enter Payment Code",
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w300,
              color: Colors.black87,
              fontSize: 15,
            ),
          ),
          hGap(10),
          TextField(
            cursorHeight: 24,
            cursorColor: Colors.grey[700],
            maxLines: 1,
            onChanged: (String? text) async {
              value.toggleVendorCodeTextFieldStatus(text!);

              if (text.length != 6) return;

              hideKeyboard();

              if (box("UserCode") == controller.text) {
                showSnackBar(context,
                    "You cannot pay yourself. Use another Payment Code");
                return;
              }

              if (controller.text.length != 6) {
                showSnackBar(context,
                    'Please enter a valid Vendor Code or Scan a QR Code.',
                    color: Colors.grey[700]!);
                return;
              }

              value.toggleIsLoading();

              // checks for the validity of vendor code
              List<dynamic> userDetails =
                  await value.getReceiverDetailsFromVendorCode(
                      controller.text.toLowerCase());
              // userDetails[0] is a boolean if validity of vendor code
              // userDetails[1] is the vendor's firebase document

              value.toggleIsLoading();

              if (!userDetails[0]) {
                showSnackBar(context, 'Payment code is invalid.');

                return;
              }

              changePage(
                context,
                SendMoneyByQRCode(
                  paymentInfo: {"receiverDoc": userDetails[1]},
                ),
              );
            },
            controller: controller,
            keyboardType: TextInputType.text,
            inputFormatters: [
              LengthLimitingTextInputFormatter(6),
              FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
            ],
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(
              color: Colors.black,
              fontSize: 24,
            ),
            decoration: InputDecoration(
              hintText: 'Example: 69ab420',
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
                fontSize: 20,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  });
}

// ================ styling widgets

BoxDecoration boxDeco() {
  return const BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(40),
      topLeft: Radius.circular(40),
    ),
  );
}
