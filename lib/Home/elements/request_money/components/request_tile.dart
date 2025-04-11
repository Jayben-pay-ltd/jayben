import 'package:flutter/material.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

import '../../../../Utilities/legacy_functions.dart';
import '../../../home_page.dart';

class RequestTileWidget extends StatefulWidget {
  const RequestTileWidget(
      {Key? key,
      required this.requestID,
      required this.amount,
      required this.requesteeFullNames,
      required this.requesterNotifToken,
      required this.requesterFullNames,
      required this.requesteeNotifToken,
      required this.requesterID,
      required this.requesteeID})
      : super(key: key);

  final String requestID;
  final double amount;
  final String requesteeFullNames;
  final String requesterNotifToken;
  final String requesterFullNames;
  final String requesteeNotifToken;
  final String requesterID;
  final String requesteeID;

  @override
  State<RequestTileWidget> createState() => _RequestTileWidgetState();
}

class _RequestTileWidgetState extends State<RequestTileWidget> {
  bool isRejecting = false;
  bool isApproving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
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
                    Text(
                      "Request ID - ${widget.requestID}",
                      style: GoogleFonts.ubuntu(
                          fontSize: 18, color: Colors.grey[900]),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ))),
                            onPressed: () async {
                              var walletBalance = double.parse(
                                  box("balance"));

                              var requestAmount =
                                  double.parse(widget.amount.toString());

                              if (walletBalance >= requestAmount) {
                                setState(() {
                                  isApproving = true;
                                });

                                // await RequestFunctions().approveOrRejectRequest(
                                //     widget.requestID,
                                //     "Approved",
                                //     widget.requesteeFullNames,
                                //     widget.requesteeNotifToken,
                                //     widget.requesteeID,
                                //     widget.requesterID,
                                //     widget.amount,
                                //     widget.requesterFullNames,
                                //     widget.requesterNotifToken);

                                setState(() {
                                  isApproving = false;
                                });

                                ScaffoldMessenger.of(this.context)
                                    .showSnackBar(SnackBar(
                                        duration: const Duration(seconds: 4),
                                        content: Text(
                                          'Request has been approved.',
                                          style: GoogleFonts.ubuntu(
                                              fontSize: 13,
                                              color: Colors.white),
                                        ),
                                        backgroundColor: Colors.green));

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            const HomePage()));
                              } else if (walletBalance < requestAmount) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        duration: Duration(seconds: 2),
                                        backgroundColor: Colors.red,
                                        content:
                                            Text("Wallet Balance not enough")));
                              }
                            },
                            child: isApproving
                                ? Container(
                                    height: 20,
                                    width: 20,
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 1.5))
                                : const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Text("Approve"),
                                  )),
                        ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                ))),
                            onPressed: () async {
                              setState(() {
                                isApproving = true;
                              });

                              // await RequestFunctions().approveOrRejectRequest(
                              //     widget.requestID,
                              //     "Rejected",
                              //     widget.requesteeFullNames,
                              //     widget.requesteeNotifToken,
                              //     widget.requesteeID,
                              //     widget.requesterID,
                              //     widget.amount,
                              //     widget.requesterFullNames,
                              //     widget.requesterNotifToken);

                              setState(() {
                                isRejecting = false;
                              });

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => const HomePage()));

                              ScaffoldMessenger.of(this.context)
                                  .showSnackBar(SnackBar(
                                      duration: const Duration(seconds: 4),
                                      content: Text(
                                        'Request has been Rejected.',
                                        style: GoogleFonts.ubuntu(
                                            fontSize: 13, color: Colors.white),
                                      ),
                                      backgroundColor: Colors.green));
                            },
                            child: isRejecting
                                ? Container(
                                    height: 20,
                                    width: 20,
                                    alignment: Alignment.center,
                                    child: const CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 1.5))
                                : const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Text("Reject"),
                                  ))
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
