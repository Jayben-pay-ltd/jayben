import 'package:jayben/Home/elements/timeline_privacy_settings/timeline_privacy_settings.dart';
import 'package:jayben/Home/elements/send_money/components/send_money_widgets.dart';
import 'package:jayben/Home/elements/send_money/send_money_receipt_post.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import '../../../Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentConfirmationUsernamePage extends StatefulWidget {
  const PaymentConfirmationUsernamePage({Key? key, required this.paymentInfo})
      : super(key: key);

  final Map paymentInfo;

  @override
  _PaymentConfirmationUsernamePageState createState() =>
      _PaymentConfirmationUsernamePageState();
}

class _PaymentConfirmationUsernamePageState
    extends State<PaymentConfirmationUsernamePage> {
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
    String receiverFullNames =
        "${widget.paymentInfo["receiver_map"]["first_name"]} "
        "${widget.paymentInfo["receiver_map"]["last_name"]}";
    return Consumer<PaymentProviderFunctions>(
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

                bool is_sent = await value.sendMoneyP2P({
                  "receiver_user_id": widget.paymentInfo["receiver_map"]
                      ["user_id"],
                  "amount": widget.paymentInfo["amount"],
                  "comment": _commentController.text,
                  "privacy": postToFeed,
                });

                value.toggleIsLoading();

                if (!is_sent) {
                  showSnackBar(
                    context,
                    "Payment failed! Please try again later.",
                    color: Colors.red,
                  );
                  return;
                }

                // plays cash sounds after sending money
                await playSound('cash.mp3');

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
                        GestureDetector(
                          onTap: () => hideKeyboard(),
                          child: Container(
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
                                hGap(10),
                                commentTextField(context, {
                                  "comment_controller": _commentController,
                                  "payment_info": widget.paymentInfo
                                }),
                                hGap(10),
                                commentExplainWidget(context)
                                // checkBoxWidget(context),
                              ],
                            ),
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

  Widget commentExplainWidget(BuildContext context) {
    return Container(
      width: width(context),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "Example: Pizza 🍕 or I love you 😘",
        style: GoogleFonts.ubuntu(
          color: Colors.grey[400],
          fontSize: 15,
        ),
      ),
    );
  }

  Widget checkBoxWidget(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => postToFeed = !postToFeed),
      child: Container(
        width: width(context),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: postToFeed ? Colors.green[300] : Colors.white,
                border: Border.all(
                  color: postToFeed ? Colors.green[300]! : Colors.grey[300]!,
                ),
                shape: BoxShape.circle,
              ),
              height: 25.0,
              width: 25.0,
              child: postToFeed
                  ? const Center(
                      child: Icon(
                        color: Colors.white,
                        Icons.check,
                        size: 15,
                      ),
                    )
                  : nothing(),
            ),
            wGap(10),
            Text(
              "Share to timeline",
              style: GoogleFonts.ubuntu(
                color: Colors.grey[500],
                fontSize: 15,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () =>
                  changePage(context, const TimelinePrivacySettingsPage()),
              child: SizedBox(
                child: Text(
                  "Timeline Privacy",
                  style: GoogleFonts.ubuntu(
                    decoration: TextDecoration.underline,
                    color: Colors.grey[500],
                    fontSize: 13,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
