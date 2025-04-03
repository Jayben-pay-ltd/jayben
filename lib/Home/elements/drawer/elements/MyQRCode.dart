import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/ProfileWidgets.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Utilities/provider_functions.dart';

class UserQRCodePage extends StatefulWidget {
  const UserQRCodePage({Key? key}) : super(key: key);

  @override
  _UserQRCodePageState createState() => _UserQRCodePageState();
}

class _UserQRCodePageState extends State<UserQRCodePage> {
  final screenshotController = ScreenshotController();
  bool isSavingImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Screenshot(
              controller: screenshotController,
              child: GestureDetector(
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: box("UserCode"),
                    ),
                  );

                  showSnackBar(context, "Payment Code Copied",
                      color: Colors.green);
                },
                child: Container(
                  width: width(context),
                  color: Colors.white,
                  height: height(context),
                  padding: const EdgeInsets.only(bottom: 35),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/logo.png",
                        color: Colors.green,
                        height: 130,
                        width: 130,
                      ),
                      Text(
                        isSavingImage
                            ? "Scan to PAY using Jayben"
                            : 'Ask Sender to Scan this QR',
                        style: GoogleFonts.ubuntu(
                          color: Colors.grey[700],
                          fontSize: 20,
                        ),
                      ),
                      hGap(20),
                      QrImageView(
                        version: QrVersions.auto,
                        data: box("UserCode"),
                        size: 300.0,
                      ),
                      hGap(20),
                      Text(
                        'Receiver Names',
                        style: GoogleFonts.ubuntu(
                          color: Colors.grey[700],
                          fontSize: 20,
                        ),
                      ),
                      hGap(10),
                      Text(
                        '${box("FirstName")} ${box("LastName")}',
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w900,
                          color: Colors.grey[800],
                          fontSize: 30,
                        ),
                      ),
                      hGap(10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 90),
                        child: Divider(
                          color: Colors.grey[500],
                          thickness: 0.5,
                        ),
                      ),
                      hGap(10),
                      Text(
                        'Payment Code',
                        style: GoogleFonts.ubuntu(
                          color: Colors.grey[700],
                          fontSize: 20,
                        ),
                      ),
                      hGap(20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: Text(
                          box("UserCode"),
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[800],
                            fontSize: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            qrCodeAppBar(context)
          ],
        ),
      ),
    );
  }

  Widget qrCodeAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      child: Container(
        width: width(context),
        decoration: appBarDeco(),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            wGap(10),
            InkWell(
              onTap: () => goBack(context),
              child: const SizedBox(
                child: Icon(
                  color: Colors.black,
                  Icons.arrow_back,
                  size: 40,
                ),
              ),
            ),
            const Spacer(),
            Text.rich(
              const TextSpan(text: "My QR Code"),
              textAlign: TextAlign.left,
              style: GoogleFonts.ubuntu(
                color: const Color.fromARGB(255, 54, 54, 54),
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const Spacer(),
            wGap(50),
          ],
        ),
      ),
    );
  }
}
