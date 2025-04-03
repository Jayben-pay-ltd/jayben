// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'scan_confirmation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'components/scan_page_widgets.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../../../../Utilities/general_widgets.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  @override
  void initState() {
    var prov = context.read<QRScannerProviderFunctions>();

    if (!prov.returnHasScannedQRCode()) return;

    if (Platform.isIOS) {
      NfcProviderFunctions nfc_prov = context.read<NfcProviderFunctions>();

      NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        try {
          // if the app is in "read nfc tag" mode
          if (nfc_prov.returnCurrentNfcListenerState() == "read") {
            // reads the NFC tag
            await nfc_prov.onNFCTagRead(context, tag);
          } else {
            // write the NFC tag
            await nfc_prov.onNFCTagWrite(context, tag);
          }
        } on Exception catch (e) {
          showSnackBar(context, e.toString());
        }

        // NfcManager.instance.stopSession();
      });
    }

    // resets the tracker
    prov.toggleHasScannedQRCode();

    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();

    if (Platform.isAndroid) {
      qr_controller!.pauseCamera();
    } else if (Platform.isIOS) {
      qr_controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    qr_controller?.dispose();
    controller.dispose();
    super.dispose();
  }

  int number_of_scans_made = 0;
  QRViewController? qr_controller;
  final qrKey = GlobalKey(debugLabel: 'QR');
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<QRScannerProviderFunctions>(
      builder: (_, value, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: SizedBox(
              height: height(context),
              width: width(context),
              child: Stack(
                children: [
                  PageView(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          QRView(
                            key: qrKey,
                            onQRViewCreated: _onQRViewCreated,
                          ),
                          Positioned(child: scannerYellowBox(context)),
                        ],
                      )
                    ],
                  ),
                  flashButton(qr_controller),
                  closeButton(context),
                  Positioned(
                    bottom: 0,
                    child: RepaintBoundary(
                      child: GestureDetector(
                        onTap: () => hideKeyboard(),
                        child: Container(
                          width: width(context),
                          decoration: boxDeco(),
                          alignment: Alignment.center,
                          height: height(context) * 0.235,
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: value.returnIsLoading()
                              ? loadingIcon(context, color: Colors.black)
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    payViaVendorCodeInstead(context),
                                    hGap(25),
                                    vendorCodeTextField(context, controller),
                                    hGap(25),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onQRViewCreated(QRViewController qrViewController) async {
    qrViewController.scannedDataStream.listen((Barcode? scanData) async {
      if (number_of_scans_made != 0) return;

      setState(() => number_of_scans_made++);

      var prov = context.read<QRScannerProviderFunctions>();

      if (scanData == null) return;

      if (prov.returnHasScannedQRCode()) return;

      // gets the receiver's user details from user code imbedded in the QR Code
      List<dynamic> details =
          await prov.getReceiverDetailsFromVendorCode(scanData.code!);
      // returns a boolean validity value - element [0]
      // returns a user document - element [1]

      // makes device vibrate once
      Vibrate.feedback(FeedbackType.heavy);

      // makes sure this function only gets called once
      prov.toggleHasScannedQRCode();
      // it enables the tracker

      if (details[1].get("UserID") == box("user_id")) {
        showSnackBar(context, "You can't pay yourself. Scan another QR Code.");

        return;
      }

      // TODO add code to detect account type
      // whether merchant or personal...

      changePage(
        context,
        SendMoneyByQRCode(
            paymentInfo: {"receiverDoc": details[1], "scan_type": "QR"}),
        type: "pr",
      );
    });
  }
}
