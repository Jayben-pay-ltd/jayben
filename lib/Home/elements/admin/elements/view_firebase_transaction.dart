// // ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:provider/provider.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:jayben/Utilities/constants.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:jayben/Utilities/general_widgets.dart';
// import 'package:jayben/Utilities/provider_functions.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class ViewFirebaseTransactionPage extends StatefulWidget {
//   const ViewFirebaseTransactionPage({super.key, required this.transaction_doc});

//   final DocumentSnapshot transaction_doc;

//   @override
//   State<ViewFirebaseTransactionPage> createState() =>
//       _ViewFirebaseTransactionPageState();
// }

// class _ViewFirebaseTransactionPageState
//     extends State<ViewFirebaseTransactionPage> {
//   @override
//   void initState() {
//     if (widget.transaction_doc["Status"] == "Cancelled") {
//       setState(() => isRejected = true);
//     } else if (widget.transaction_doc["Status"] == "Completed") {
//       setState(() => isCompleted = true);
//     } else if (widget.transaction_doc["Status"] == "Refunded") {
//       setState(() => isReversed = true);
//     }
//     super.initState();
//   }

//   bool isReversed = false;
//   bool isRejected = false;
//   bool isCompleted = false;
//   final amountController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AdminProviderFunctions>(builder: (_, value, child) {
//       return Scaffold(
//         backgroundColor: Colors.white,
//         body: value.returnIsLoading()
//             ? loadingScreenPlainNoBackButton(context)
//             : SafeArea(
//                 child: Stack(
//                   children: [
//                     Container(
//                       width: width(context),
//                       height: height(context),
//                       padding: const EdgeInsets.only(
//                           top: 85, bottom: 0, left: 20, right: 20),
//                       child: SingleChildScrollView(
//                         physics: const BouncingScrollPhysics(),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "Tranx ID",
//                                   textAlign: TextAlign.center,
//                                   style: googleStyle(
//                                       color: Colors.green,
//                                       weight: FontWeight.w700,
//                                       size: 25),
//                                 ),
//                                 Text(
//                                   "${widget.transaction_doc["TransactionID"]}",
//                                   textAlign: TextAlign.center,
//                                   style: googleStyle(
//                                       color: Colors.black87,
//                                       weight: FontWeight.w300,
//                                       size: 13),
//                                 )
//                               ],
//                             ),
//                             const SizedBox(height: 20),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "Mark as Completed",
//                                   style: googleStyle(
//                                       color: Colors.black,
//                                       weight: FontWeight.w300),
//                                 ),
//                                 CupertinoSwitch(
//                                   value: isCompleted,
//                                   onChanged: isRejected ||
//                                           isReversed ||
//                                           isCompleted
//                                       ? null
//                                       : (bool state) async {
//                                           setState(() => isCompleted = state);

//                                           value.toggleIsLoading();

//                                           if (state) {
//                                             await value
//                                                 .markTransactionCompleteFirebase(
//                                                     widget.transaction_doc);
//                                           } else {
//                                             await value
//                                                 .markTransactionCompleteFirebase(
//                                                     widget.transaction_doc);
//                                           }

//                                           await Future.wait([
//                                             value.getPendingWithdrawals(),
//                                             value.getAdminMetricsDocument(),
//                                             value
//                                                 .getPendingWithdrawalsFirebase(),
//                                           ]);

//                                           value.toggleIsLoading();

//                                           goBack(context);
//                                         },
//                                 )
//                               ],
//                             ),
//                             const SizedBox(height: 20),
//                             const Padding(
//                               padding: EdgeInsets.symmetric(vertical: 15),
//                               child:
//                                   Divider(color: Colors.black, thickness: 0.2),
//                             ),
//                             Text(
//                               "Customer Details",
//                               textAlign: TextAlign.center,
//                               style: googleStyle(
//                                   color: Colors.green,
//                                   weight: FontWeight.w700,
//                                   size: 25),
//                             ),
//                             const SizedBox(height: 20),
//                             customerDetailTile("Full names",
//                                 widget.transaction_doc["FullNames"]),
//                             const SizedBox(height: 10),
//                             customerDetailTile("Phone number",
//                                 widget.transaction_doc["PhoneNumber"]),
//                           ],
//                         ),
//                       ),
//                     ),
//                     orderAppBarTitle(context),
//                   ],
//                 ),
//               ),
//       );
//     });
//   }

//   Widget orderAppBarTitle(BuildContext context) {
//     return Consumer<AdminProviderFunctions>(
//       builder: (_, value, child) {
//         return Positioned(
//           top: 0,
//           child: Container(
//             decoration: appBarDeco(),
//             alignment: Alignment.centerLeft,
//             width: MediaQuery.of(context).size.width,
//             padding: const EdgeInsets.only(left: 10, right: 20, bottom: 15),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 InkWell(
//                     onTap: () => Navigator.of(context).pop(),
//                     child: SizedBox(
//                         child: Icon(Icons.arrow_back,
//                             size: 40, color: iconColor))),
//                 const SizedBox(width: 10),
//                 Text.rich(
//                   const TextSpan(text: "Transaction"),
//                   textAlign: TextAlign.left,
//                   style: GoogleFonts.ubuntu(
//                     textStyle: const TextStyle(
//                       fontSize: 30,
//                       fontWeight: FontWeight.w800,
//                       color: Color.fromARGB(255, 54, 54, 54),
//                     ),
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   decoration: BoxDecoration(
//                       color: isCompleted
//                           ? Colors.green
//                           : (isRejected ? Colors.red : Colors.orange),
//                       borderRadius: BorderRadius.circular(10)),
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                   child: Text(
//                     isCompleted
//                         ? "Completed"
//                         : (isRejected ? "Rejected" : "Pending"),
//                     style: googleStyle(
//                       weight: FontWeight.w400,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// Widget customerDetailTile(String tileName, String tileDetail) {
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: [
//       Text(tileName,
//           style: googleStyle(
//               color: Colors.grey[700]!, size: 18, weight: FontWeight.w400)),
//       Text(tileDetail,
//           style: googleStyle(
//               color: Colors.grey[900]!, size: 18, weight: FontWeight.w400)),
//     ],
//   );
// }

// // ======================= styling widgets

// Decoration appBarDeco() {
//   return BoxDecoration(
//       color: Colors.white,
//       border: Border(
//         bottom: BorderSide(
//           color: Colors.grey[200]!,
//           width: 0.5,
//         ),
//       ));
// }
