import 'package:hive/hive.dart';
import 'post_transfer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class TransferConfirmation extends StatefulWidget {
  const TransferConfirmation(
      {Key? key,
      required this.savingsAccName,
      required this.savingsAccID,
      required this.amount,
      required this.backendType})
      : super(key: key);

  final String amount;
  final String backendType;
  final String savingsAccID;
  final String savingsAccName;

  @override
  _TransferConfirmationState createState() => _TransferConfirmationState();
}

class _TransferConfirmationState extends State<TransferConfirmation> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProviderFunctions>(
      builder: (_, value, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: value.returnIsLoading()
              ? loadingScreenPlainNoBackButton(context)
              : Scaffold(
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: () async {
                      if (value.returnIsLoading()) return;

                      value.toggleIsLoading();

                      double amount =
                          double.parse(widget.amount.replaceAll("-", ""));

                      bool is_sent = await value.addMoneyToNasAccount(
                          amount, widget.savingsAccID);

                      value.toggleIsLoading();

                      changePage(
                          context,
                          PostTransfer(
                            amount: amount,
                            savingsAccName: widget.savingsAccName,
                          ),
                          type: "pr");
                    },
                    backgroundColor: Colors.green,
                    label: Row(
                      children: [
                        Image.asset(
                          'assets/send.png',
                          color: Colors.white,
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(width: 10),
                        const Text("Transfer now"),
                      ],
                    ),
                  ),
                  backgroundColor: Colors.white,
                  body: WillPopScope(
                    child: Stack(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 30, bottom: 0),
                          color: Colors.white,
                          height: height(context),
                          width: width(context),
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
                                            'Transfer \n${box("currency")} ${widget.amount} to',
                                        style: GoogleFonts.ubuntu(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[600],
                                          fontSize: 26,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '\n${widget.savingsAccName}?',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 26,
                                        ),
                                      )
                                    ],
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              hGap(10),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  "*Press TRANSFER NOW to confirm transfer.",
                                  style: GoogleFonts.ubuntu(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Positioned(
                          top: 40,
                          left: 10,
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back, size: 40),
                          ),
                        )
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
