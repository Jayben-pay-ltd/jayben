import 'package:jayben/Home/elements/send_money/send_money_receipt_post.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import '../../../../Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/send_money_widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentConfirmationQr extends StatefulWidget {
  const PaymentConfirmationQr({Key? key, required this.paymentInfo})
      : super(key: key);

  final Map paymentInfo;

  @override
  _PaymentConfirmationQrState createState() => _PaymentConfirmationQrState();
}

class _PaymentConfirmationQrState extends State<PaymentConfirmationQr> {
  @override
  void initState() {
    if (box("DefaultTransactionPrivacy") == "Public") {
      setState(() {
        postToFeed = true;
      });
    } else if (box("DefaultTransactionPrivacy") == "Private") {
      setState(() {
        postToFeed = false;
      });
    }
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      statusBarColor: Colors.transparent,
    ));
    super.initState();
  }

  bool isLoading = false;
  bool postToFeed = true;
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String receiverFullNames =
        "${widget.paymentInfo["receiverDoc"].get("FirstName")} "
        "${widget.paymentInfo["receiverDoc"].get("LastName")}";
    return Consumer<QRScannerProviderFunctions>(
      builder: (_, value, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                if (value.returnIsLoading()) return;

                hideKeyboard();

                // makes comments mandatory for p2p transfers via username
                if (_commentController.text.isEmpty &&
                    widget.paymentInfo["payment_means"] != "QR") {
                  showSnackBar(context, "Enter a comment");
                  return;
                }

                showSnackBar(context, "Payment is being sent...");

                value.toggleIsLoading();

                // sends money to receiver
                await value.initateMerchantPayment({
                  "privacy": postToFeed ? "Public" : "Private",
                  "comment": _commentController.text,
                  ...widget.paymentInfo,
                });

                // plays cash sounds after sending money
                await playSound('cash.mp3');

                value.toggleIsLoading();

                // routes user to the receipt page
                changePage(
                  context,
                  SendMoneyReceiptPage(
                    amount: widget.paymentInfo["amount"],
                    receiver_names: receiverFullNames,
                  ),
                  type: "pr",
                );
              },
              backgroundColor: Colors.green,
              label: value.returnIsLoading()
                  ? loadingIcon(context)
                  : Row(
                      children: [
                        Image.asset(
                          'assets/send.png',
                          color: Colors.white,
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(width: 10),
                        const Text("Pay Now"),
                      ],
                    ),
            ),
            body: WillPopScope(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: width(context),
                          color: Colors.white,
                          height: height(context),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 30, bottom: 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(left: 20),
                                width: width(context),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            'Send \n${box("currency")} ${widget.paymentInfo["amount"]} to',
                                        style: GoogleFonts.ubuntu(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                          fontSize: 30,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '\n$receiverFullNames?',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 28,
                                        ),
                                      )
                                    ],
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, top: 10),
                                child: Text.rich(
                                  TextSpan(
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                    text:
                                        "+ ${box("currency")} ${(double.parse(box("merchant_commission_per_transaction").toString())).toStringAsFixed(2)} transaction fee",
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              const SizedBox(height: 10),
                              commentTextField(context, {
                                "comment_controller": _commentController,
                                "payment_info": widget.paymentInfo,
                              }),
                              const SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  "Example: Pizza 🍕 or I love you 😘 ",
                                  style: GoogleFonts.ubuntu(
                                    color: Colors.grey[500],
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  backButton(context)
                ],
              ),
              onWillPop: () async {
                Navigator.pop(context);
                return true;
              },
            ),
          ),
        );
      },
    );
  }
}
