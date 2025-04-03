// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:jayben/Utilities/constants.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../../../../../Utilities/general_widgets.dart';
// import 'package:jayben/Utilities/provider_functions.dart';
// import 'package:jayben/Home/elements/admin/elements/view_firebase_transaction.dart';

// class FirebaseAdminTransactionsListBuilder extends StatelessWidget {
//   const FirebaseAdminTransactionsListBuilder({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AdminProviderFunctions>(builder: (_, value, child) {
//       return value.returnPendingTransactionsFirebase() != null
//           ? value.returnPendingTransactionsFirebase()!.docs.isEmpty
//               ? Center(
//                   child: Text(
//                     "No pending firebase withdrawals",
//                     style: googleStyle(
//                       weight: FontWeight.w400,
//                       color: Colors.green,
//                       size: 15,
//                     ),
//                   ),
//                 )
//               : RefreshIndicator(
//                   displacement: 150,
//                   onRefresh: () async {
//                     value.toggleIsLoading();

//                     // plays refresh sound
//                     await playSound('refresh.mp3');

//                     await Future.wait([
//                       value.getPendingWithdrawalsFirebase(),
//                       value.getAdminMetricsDocument(),
//                       value.getPendingWithdrawals(),
//                       value.getCountableMetrics(),
//                     ]);

//                     value.toggleIsLoading();
//                   },
//                   child: MediaQuery.removePadding(
//                     removeTop: true,
//                     context: context,
//                     removeBottom: true,
//                     child: ListView.builder(
//                         scrollDirection: Axis.vertical,
//                         physics: const BouncingScrollPhysics(),
//                         itemCount: value
//                             .returnPendingTransactionsFirebase()!
//                             .docs
//                             .length,
//                         padding: const EdgeInsets.only(bottom: 20, top: 100),
//                         itemBuilder: (_, index) {
//                           // DocumentSnapshot ds = value
//                           //     .returnPendingTransactionsFirebase()!
//                           //     .docs[index];
//                           var amount = double.parse(ds['Amount'].toString());
//                           return GestureDetector(
//                             onTap: () async => changePage(
//                                 context,
//                                 ViewFirebaseTransactionPage(
//                                     transaction_doc: ds)),
//                             child: Container(
//                                 margin: const EdgeInsets.symmetric(vertical: 5),
//                                 color: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: 10, horizontal: 20),
//                                 width: width(context),
//                                 child: Row(
//                                   children: [
//                                     Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(ds["Method"]),
//                                         const SizedBox(height: 5),
//                                         SizedBox(
//                                           width: width(context) * 0.5,
//                                           child: Text("${ds["PhoneNumber"]}",
//                                               maxLines: 2,
//                                               overflow: TextOverflow.ellipsis,
//                                               style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontWeight: FontWeight.bold)),
//                                         ),
//                                         const SizedBox(height: 5),
//                                         Text(ds["Status"],
//                                             style: GoogleFonts.ubuntu(
//                                                 color: ds["Status"] == "Pending"
//                                                     ? Colors.orange[700]
//                                                     : (ds["Status"] ==
//                                                             "Completed"
//                                                         ? Colors.green
//                                                         : Colors.red),
//                                                 fontWeight: FontWeight.w400)),
//                                       ],
//                                     ),
//                                     const Spacer(),
//                                     Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       children: [
//                                         Text(
//                                             ds["Method"] == "Points"
//                                                 ? (ds["SentReceived"] == "Sent"
//                                                     ? (amount > 1
//                                                         ? "- ${amount.toStringAsFixed(0)} Points"
//                                                         : "- ${amount.toStringAsFixed(0)} Point")
//                                                     : (amount > 1
//                                                         ? "+ ${amount.toStringAsFixed(0)} Points"
//                                                         : "+ ${amount.toStringAsFixed(0)} Point"))
//                                                 : (ds["Currency"] == "ZMW"
//                                                     ? (ds['SentReceived'] ==
//                                                             "Received"
//                                                         ? "+ ZMW ${amount.toStringAsFixed(2)}"
//                                                         : "- ZMW ${amount.toStringAsFixed(2)}")
//                                                     : (ds['SentReceived'] ==
//                                                             "Received"
//                                                         ? "+ ${amount.toStringAsFixed(2)}, ${ds["Currency"]}"
//                                                         : "- ${amount.toStringAsFixed(2)}, ${ds["Currency"]}")),
//                                             style: const TextStyle(
//                                                 color: Colors.black,
//                                                 fontWeight: FontWeight.bold)),
//                                         const SizedBox(height: 5),
//                                         Row(
//                                           children: [
//                                             Text(
//                                               DateFormat.yMMMd().format(
//                                                   ds["DateCreated"].toDate()),
//                                             ),
//                                             Text(
//                                                 " - ${DateFormat.Hm().format(ds["DateCreated"].toDate())}")
//                                           ],
//                                         ),
//                                         const SizedBox(height: 5),
//                                         Text(ds['TransactionType'],
//                                             style: const TextStyle(
//                                                 color: Colors.black,
//                                                 fontWeight: FontWeight.bold))
//                                       ],
//                                     ),
//                                   ],
//                                 )),
//                           );
//                         }),
//                   ),
//                 )
//           : Center(child: loadingIcon(context));
//     });
//   }
// }
