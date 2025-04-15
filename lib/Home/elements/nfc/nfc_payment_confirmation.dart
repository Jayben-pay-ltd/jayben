import 'package:jayben/Home/elements/attach_media/components/attach_media_widgets.dart';
import 'package:jayben/Home/elements/send_money/send_money_receipt_post.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import '../../../../Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../send_money/components/send_money_widgets.dart';

class PaymentConfirmationNFC extends StatefulWidget {
  const PaymentConfirmationNFC({Key? key, required this.paymentInfo})
      : super(key: key);

  final Map paymentInfo;

  @override
  _PaymentConfirmationNFCState createState() => _PaymentConfirmationNFCState();
}

class _PaymentConfirmationNFCState extends State<PaymentConfirmationNFC> {
  @override
  void initState() {
    if (box("default_transaction_visibility") == "Public") {
      setState(() {
        postToFeed = true;
      });
    } else if (box("default_transaction_visibility") == "Private") {
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
    String receiverFullNames = "${widget.paymentInfo["full_names"]}";
    return Consumer<NfcProviderFunctions>(
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
                    widget.paymentInfo["payment_means"] != "NFC") {
                  showSnackBar(context, "Enter a comment");
                  return;
                }

                showSnackBar(context, "Payment is being sent...");

                value.toggleIsLoading();

                // sends money to receiver
                await value.initateNFCPayment({
                  "amount_plus_transaction_fee":
                      widget.paymentInfo["amount_plus_transaction_fee"],
                  "payment_means": widget.paymentInfo["payment_means"],
                  "account_type": widget.paymentInfo["account_type"],
                  "full_names": widget.paymentInfo["full_names"],
                  "privacy": postToFeed ? "Public" : "Private",
                  "user_code": widget.paymentInfo["user_code"],
                  "amount": widget.paymentInfo["amount"],
                  "comment": _commentController.text,
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
                                    text: widget.paymentInfo["account_type"] ==
                                            "Personal Account"
                                        ? "+ ${box("currency")} 0.00 transaction fee"
                                        : "+ ${box("currency")} ${(double.parse(box("merchant_commission_per_transaction").toString())).toStringAsFixed(2)} transaction fee",
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
}
