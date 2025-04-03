// import '../../../../Utilities/provider_functions.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../../drawer/elements/contact_us.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter/material.dart';

// class TimeLtdTranxTile extends StatefulWidget {
//   const TimeLtdTranxTile({Key? key}) : super(key: key);

//   @override
//   _TimeLtdTranxTileState createState() => _TimeLtdTranxTileState();
// }

// class _TimeLtdTranxTileState extends State<TimeLtdTranxTile> {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<HomeProviderFunctions>(builder: (context, value, child) {
//       return value.returnHomeTimeLimitedTransactionsQS() != null
//           ? MediaQuery.removePadding(
//               removeTop: true,
//               context: context,
//               removeBottom: true,
//               child: ListView.builder(
//                 shrinkWrap: true,
//                 scrollDirection: Axis.vertical,
//                 padding: const EdgeInsets.only(top: 5),
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount:
//                     value.returnHomeTimeLimitedTransactionsQS()!.docs.length,
//                 itemBuilder: (context, index) {
//                   DocumentSnapshot ds =
//                       value.returnHomeTimeLimitedTransactionsQS()!.docs[index];
//                   double amount = double.parse(ds['Amount'].toString());
//                   return GestureDetector(
//                     onTap: () async => showDialogue(
//                         context,
//                         timeLtdTranxDetailsWidget(context, ds['TransactionID'],
//                             ds['NumberOfDaysLeft'])),
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(vertical: 5),
//                       color: const Color.fromARGB(255, 251, 246, 217),
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 10, horizontal: 20),
//                       width: width(context),
//                       child: Row(
//                         children: [
//                           Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(ds['SentReceived'] == "Sent"
//                                   ? "Wallet transfer"
//                                   : "Will be availble to you soon..."),
//                               const SizedBox(height: 5),
//                               Text(
//                                 "${ds["PhoneNumber"]}",
//                                 style: const TextStyle(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 5),
//                               Text(
//                                 ds["Status"] == "Pending"
//                                     ? "Waiting for Release Date"
//                                     : "Released",
//                                 style: GoogleFonts.ubuntu(
//                                   color: ds["Status"] == "Pending"
//                                       ? Colors.orange[700]
//                                       : (ds["Status"] == "Completed"
//                                           ? Colors.green
//                                           : Colors.red),
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const Spacer(),
//                           Image.asset("assets/lock.png", height: 20, width: 20),
//                           const SizedBox(width: 10),
//                           Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 ds["Method"] == "Points"
//                                     ? (ds["SentReceived"] == "Sent"
//                                         ? (amount > 1
//                                             ? "- ${amount.toStringAsFixed(0)} Points"
//                                             : "- ${amount.toStringAsFixed(0)} Point")
//                                         : (amount > 1
//                                             ? "+ ${amount.toStringAsFixed(0)} Points"
//                                             : "+ ${amount.toStringAsFixed(0)} Point"))
//                                     : (ds["Currency"] == "ZMW"
//                                         ? (ds['SentReceived'] == "Received"
//                                             ? "+ ZMW ${amount.toStringAsFixed(2)}"
//                                             : "- ZMW ${amount.toStringAsFixed(2)}")
//                                         : (ds['SentReceived'] == "Received"
//                                             ? "+ ${amount.toStringAsFixed(2)}, ${ds["Currency"]}"
//                                             : "- ${amount.toStringAsFixed(2)}, ${ds["Currency"]}")),
//                                 style: const TextStyle(
//                                   color: Colors.black,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 5),
//                               Row(
//                                 children: [
//                                   Text(
//                                     ds['NumberOfDaysLeft'] == 1
//                                         ? "${ds['NumberOfDaysLeft'].toString()} day Left"
//                                         : "${ds['NumberOfDaysLeft'].toString()} days Left",
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 5),
//                               Text(
//                                 ds['TransactionType'],
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.black,
//                                 ),
//                               )
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             )
//           : const SizedBox();
//     });
//   }
// }

// Widget timeLtdTranxDetailsWidget(
//     context, String transactionID, int numberOfDays) {
//   return AlertDialog(
//     shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(15))),
//     content: Stack(
//       children: [
//         Container(
//           padding: const EdgeInsets.only(top: 20),
//           width: width(context) * 0.8,
//           child: ListView(
//             physics: const BouncingScrollPhysics(),
//             shrinkWrap: true,
//             children: [
//               Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     numberOfDays == 1
//                         ? "This money will be released in $numberOfDays day"
//                         : "This money will be released in $numberOfDays days",
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.ubuntu(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 18,
//                         color: Colors.grey[900]),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     "Transaction ID: $transactionID",
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.ubuntu(
//                         fontSize: 18, color: Colors.grey[900]),
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                       style: ButtonStyle(
//                         backgroundColor:
//                             MaterialStateProperty.all(Colors.orange),
//                         shape:
//                             MaterialStateProperty.all<RoundedRectangleBorder>(
//                           RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(25.0),
//                           ),
//                         ),
//                       ),
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (builder) => const ContactUsPage()));
//                       },
//                       child: const Text("Report"))
//                 ],
//               ),
//             ],
//           ),
//         )
//       ],
//     ),
//   );
// }
