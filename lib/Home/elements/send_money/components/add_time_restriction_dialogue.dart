import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../send_money_receipt_post.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class AddTimeRestrictionDialogue extends StatefulWidget {
  const AddTimeRestrictionDialogue({
    Key? key,
    required this.postToFeed,
    required this.paymentInfo,
    required this.commentController,
  }) : super(key: key);

  final bool postToFeed;
  final Map<String, dynamic> paymentInfo;
  final TextEditingController commentController;

  @override
  State<AddTimeRestrictionDialogue> createState() =>
      _AddTimeRestrictionDialogueState();
}

class _AddTimeRestrictionDialogueState
    extends State<AddTimeRestrictionDialogue> {
  bool isSendings = false;
  bool noDaysEntered = false;
  final numberOfDaysController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProviderFunctions>(
      builder: (context, value, child) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(40))),
          content: Stack(
            children: [
              SizedBox(
                width: width(context) * 0.8,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/lock.png", height: 40, width: 40),
                        const SizedBox(height: 20),
                        Text(
                          "Set a release date",
                          style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey[900]),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "How many days after sending "
                          "the money, \nshould it be released to the receiver?",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ubuntu(
                              color: noDaysEntered
                                  ? Colors.red
                                  : Colors.grey[600]),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: width(context) * 0.9,
                          child: TextField(
                            cursorColor: Colors.grey[700],
                            cursorHeight: 20,
                            minLines: 1,
                            maxLines: 2,
                            controller: numberOfDaysController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(3),
                            ],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.ubuntu(
                              fontSize: 20,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w300,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              focusColor: Colors.white,
                              hintText: 'Number of Days',
                              isDense: true,
                              border: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              enabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              disabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              hintStyle: GoogleFonts.ubuntu(
                                fontSize: 20,
                                color: noDaysEntered
                                    ? Colors.red
                                    : Colors.grey[800],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () async {
                            if (numberOfDaysController.text != "") {
                              changePage(
                                  context,
                                  SendMoneyReceiptPage(
                                    receiver_names:
                                        "${widget.paymentInfo['receiverDoc'].get("FirstName")} "
                                        "${widget.paymentInfo['receiverDoc'].get("LastName")}",
                                    amount: widget.paymentInfo["amount"],
                                  ),
                                  type: "pr");

                              // plays cash sounds after sending money
                              await playSound('cash.mp3');

                              // sends money with a time release
                              // await value.sendMoneyByUsernameWithTimeLimit(
                              //   {
                              //     "comment": widget.commentController.text,
                              //     "numOfDays":
                              //         int.parse(numberOfDaysController.text),
                              //     "privacy":
                              //         widget.postToFeed ? "Public" : "Private",
                              //     ...widget.paymentInfo
                              //   },
                              // );
                            } else if (numberOfDaysController.text == "") {
                              setState(() => noDaysEntered = true);
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: height(context) * 0.06,
                            margin: const EdgeInsets.symmetric(horizontal: 80),
                            decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30))),
                            child: isSendings
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 1.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        'assets/send.png',
                                        color: Colors.white,
                                        height: 20,
                                        width: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        "Pay Now",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.ubuntu(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => isSendings = false);
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.grey[600],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
