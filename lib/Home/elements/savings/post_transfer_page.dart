import 'package:flutter/material.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

import '../../home_page.dart';

class PostTransfer extends StatefulWidget {
  const PostTransfer(
      {Key? key, required this.amount, required this.savingsAccName})
      : super(key: key);

  final double amount;
  final String savingsAccName;

  @override
  _PostTransferState createState() => _PostTransferState();
}

class _PostTransferState extends State<PostTransfer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (builder) => const HomePage()));
          return false;
        },
        child: Stack(
          children: [
            Container(
                height: height(context),
                width: width(context),
                alignment: Alignment.center,
                child: FittedBox(
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
                            "You have transfered",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.ubuntu(
                                color: Colors.grey[700],
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Color(0xFF32ba7c),
                              Color(0xFF147752),
                            ]),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 50),
                          width: width(context),
                          child: Text.rich(
                              TextSpan(
                                  text:
                                      "${Hive.box('userInfo').get("Currency")} ",
                                  children: [
                                    TextSpan(
                                        text: "\n${widget.amount}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 50,
                                            color: Colors.white))
                                  ]),
                              textAlign: TextAlign.left,
                              style: GoogleFonts.ubuntu(
                                  fontSize: 30, color: Colors.grey[100])),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text.rich(
                              TextSpan(
                                  text: "to savings account named\n",
                                  children: [
                                    TextSpan(
                                        text: widget.savingsAccName,
                                        style: GoogleFonts.ubuntu(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30,
                                            color: Colors.grey[700]))
                                  ]),
                              textAlign: TextAlign.left,
                              style: GoogleFonts.ubuntu(
                                  fontSize: 24, color: Colors.grey[500])),
                        ),
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text.rich(
                              TextSpan(
                                  text:
                                      "${DateFormat.yMMMd().format(DateTime.now())} - ${DateFormat.Hm().format(DateTime.now())}"),
                              textAlign: TextAlign.left,
                              style: GoogleFonts.ubuntu(
                                  fontSize: 20, color: Colors.grey[500])),
                        ),
                      ]),
                )),
            Positioned(
                top: 40,
                right: 30,
                child: IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => const HomePage()));
                    },
                    icon: const Icon(Icons.close, size: 40)))
          ],
        ),
      ),
    );
  }
}
