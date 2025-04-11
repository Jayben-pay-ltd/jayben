// ignore_for_file: non_constant_identifier_names

import 'package:jayben/Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../home_page.dart';

class SendMoneyReceiptPage extends StatefulWidget {
  const SendMoneyReceiptPage(
      {Key? key, required this.receiver_names, required this.amount})
      : super(key: key);

  final String receiver_names;
  final double amount;

  @override
  _SendMoneyReceiptPageState createState() => _SendMoneyReceiptPageState();
}

class _SendMoneyReceiptPageState extends State<SendMoneyReceiptPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async {
          changePage(context, const HomePage(), type: "pr");
          return false;
        },
        child: Stack(
          children: [
            Container(
              width: width(context),
              alignment: Alignment.center,
              height: height(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Image.asset("assets/checked.png",
                        height: 40, width: 40),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      "You have sent",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        fontSize: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF32ba7c),
                          Color(0xFF147752),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 50),
                    width: width(context),
                    child: Text.rich(
                      TextSpan(
                        text: "${box("currency")}\n",
                        children: [
                          TextSpan(
                            text: widget.amount.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 50,
                            ),
                          )
                        ],
                      ),
                      textAlign: TextAlign.left,
                      style: GoogleFonts.ubuntu(
                        fontSize: 30,
                        color: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text.rich(
                      TextSpan(
                        text: "to\n\n",
                        children: [
                          TextSpan(
                            text: widget.receiver_names,
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                              fontSize: 30,
                            ),
                          )
                        ],
                      ),
                      textAlign: TextAlign.left,
                      style: GoogleFonts.ubuntu(
                        color: Colors.grey[500],
                        fontSize: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text.rich(
                      TextSpan(
                          text:
                              "${DateFormat.yMMMd().format(DateTime.now())} - ${DateFormat.Hm().format(DateTime.now())}"),
                      textAlign: TextAlign.left,
                      style: GoogleFonts.ubuntu(
                        color: Colors.grey[500],
                        fontSize: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 60,
              right: 30,
              child: IconButton(
                onPressed: () =>
                    changePage(context, const HomePage(), type: "pr"),
                icon: const Icon(
                  Icons.close,
                  size: 40,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
