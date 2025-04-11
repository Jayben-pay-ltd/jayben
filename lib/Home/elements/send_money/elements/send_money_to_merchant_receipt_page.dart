import 'package:flutter/material.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../../home_page.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';

class SendMoneyToMerchantReceiptPage extends StatefulWidget {
  const SendMoneyToMerchantReceiptPage({Key? key, required this.paymentInfo})
      : super(key: key);

  final Map<String, dynamic> paymentInfo;

  @override
  _SendMoneyToMerchantReceiptPageState createState() =>
      _SendMoneyToMerchantReceiptPageState();
}

class _SendMoneyToMerchantReceiptPageState
    extends State<SendMoneyToMerchantReceiptPage> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent));
    super.initState();
  }

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
                            "You have sent",
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
                              TextSpan(text: "${box("currency")} ", children: [
                                TextSpan(
                                    text: "\n${widget.paymentInfo['amount']}",
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
                              TextSpan(text: "to \n", children: [
                                TextSpan(
                                    text: widget.paymentInfo['merchantName'],
                                    style: GoogleFonts.ubuntu(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                        color: Colors.grey[700]))
                              ]),
                              textAlign: TextAlign.left,
                              style: GoogleFonts.ubuntu(
                                  fontSize: 30, color: Colors.grey[500])),
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
                top: 62.5,
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
