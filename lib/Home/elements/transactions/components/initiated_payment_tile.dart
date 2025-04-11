// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:jayben/Utilities/general_widgets.dart';
// import 'package:provider/provider.dart';
// import '../../drawer/elements/contact_us.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:jayben/Utilities/provider_functions.dart';

// class InitiatedPaymentTile extends StatelessWidget {
//   const InitiatedPaymentTile({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Builder(
//       builder: (_) {
//         return Consumer<HomeProviderFunctions>(
//           builder: (_, value, child) {
//             return StreamBuilder<QuerySnapshot<Object?>?>(
//               stream: value.returnInitiatedPaymentsStream(),
//               builder: (_, snapshot) {
//                 return snapshot.hasData
//                     ? MediaQuery.removePadding(
//                         removeTop: true,
//                         context: context,
//                         removeBottom: true,
//                         child: snapshot.data!.docs.isEmpty
//                             ? nothing()
//                             : ListView.builder(
//                                 shrinkWrap: true,
//                                 scrollDirection: Axis.vertical,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 padding: const EdgeInsets.only(top: 10),
//                                 itemCount: snapshot.data!.docs.length,
//                                 itemBuilder: (_, index) {
//                                   return tileBody(
//                                       context, snapshot.data!.docs[index]);
//                                 },
//                               ),
//                       )
//                     : nothing();
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }

// Widget tileBody(BuildContext context, DocumentSnapshot ds) {
//   double amount = double.parse(ds['Amount'].toString());
//   return GestureDetector(
//     onTap: () async => showDialog(
//         context: context,
//         builder: (context) {
//           return transactionDetailsDialogue(context, ds);
//         }),
//     child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 5),
//         color: Colors.white,
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//         width: width(context),
//         child: Row(
//           children: [
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Pay Request from merchant",
//                     style: GoogleFonts.ubuntu(
//                         fontWeight: FontWeight.w300,
//                         fontSize: 14,
//                         color: Colors.black)),
//                 hGap(5),
//                 Text("For ${box("currency")} ${amount.toStringAsFixed(2)}",
//                     style: GoogleFonts.ubuntu(
//                         color: Colors.black, fontWeight: FontWeight.w800)),
//                 hGap(5),
//                 SizedBox(
//                   width: width(context) * 0.5,
//                   child: Text("${ds["PhoneNumber"]}",
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: GoogleFonts.ubuntu(
//                           color: Colors.black87, fontWeight: FontWeight.w400)),
//                 ),
//               ],
//             ),
//             const Spacer(),
//             quantityButtons(context, ds),
//           ],
//         )),
//   );
// }

// Widget quantityButtons(BuildContext context, DocumentSnapshot ds) {
//   String currency = ds.get("Currency");
//   double transactionFeePercentMerchants =
//       box("transaction_fee_percentage_to_merchants");
//   double transactionFee =
//       ds.get("Amount") * (transactionFeePercentMerchants / 100);
//   double amountBeforeFee = double.parse(ds.get("Amount").toString());
//   double amountPlusFee = amountBeforeFee + transactionFee;
//   double myWalletBal = double.parse(box("balance").toString());
//   return Consumer<PaymentProviderFunctions>(builder: (_, value, child) {
//     return value.returnPaymentRequestsLoading().contains(ds.id)
//         ? Container(
//             width: 80,
//             alignment: Alignment.center,
//             child: loadingIcon(
//               context,
//               color: Colors.grey[500]!,
//             ),
//           )
//         : Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               GestureDetector(
//                 onTap: () async {
//                   if (value.returnIsLoading()) return;

//                   if (myWalletBal < amountPlusFee) {
//                     showSnackBar(
//                         context,
//                         "Your Wallet balance not enough.\n\n"
//                         "Please account for the $currency ${transactionFee.toStringAsFixed(2)} transaction fee.\n\n"
//                         "You will be charged $currency ${amountPlusFee.toStringAsFixed(2)} in total.",
//                         duration: 10);

//                     return;
//                   }

//                   value.updatePaymentRequestList(ds.id);

//                   await approveInitiatedPayment({
//                     ...ds.data() as Map<String, dynamic>,
//                     "AmountPlusFee": amountPlusFee,
//                     "TransactionFeeInKwacha": transactionFee,
//                     "TransactionFeePercent":
//                         transactionFeePercentMerchants.toStringAsFixed(0),
//                   });

//                   value.updatePaymentRequestList(ds.id);
//                 },
//                 child: Container(
//                     width: 80,
//                     height: 50,
//                     alignment: Alignment.center,
//                     decoration: actionbuttonDeco("Approve"),
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: Text("Approve",
//                         style: GoogleFonts.ubuntu(color: Colors.green[600]))),
//               ),
//               const SizedBox(width: 3),
//               GestureDetector(
//                 onTap: () async {
//                   value.updatePaymentRequestList(ds.id);

//                   await rejectInitiatedPayment(
//                       ds.data() as Map<String, dynamic>);

//                   value.updatePaymentRequestList(ds.id);
//                 },
//                 child: Container(
//                     width: 80,
//                     height: 50,
//                     alignment: Alignment.center,
//                     decoration: actionbuttonDeco("Decline"),
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: Text("Decline",
//                         style: GoogleFonts.ubuntu(color: Colors.red[600]))),
//               )
//             ],
//           );
//   });
// }

// Decoration actionbuttonDeco(String type) {
//   return BoxDecoration(
//       color: Colors.grey[200],
//       borderRadius: type == "Approve"
//           ? const BorderRadius.only(
//               topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))
//           : const BorderRadius.only(
//               topRight: Radius.circular(20), bottomRight: Radius.circular(20)));
// }

// Widget loadingWidget(BuildContext context) {
//   return SizedBox(
//       height: height(context) * 0.15,
//       width: width(context),
//       child: Center(
//         child: CircularProgressIndicator(
//           color: Colors.grey[700],
//           strokeWidth: 2,
//         ),
//       ));
// }

// Widget transactionDetailsDialogue(context, DocumentSnapshot ds) {
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
//                 children: [
//                   Text(
//                     "If you approve this payment request, ${ds.get("Merchant")['MerchantName']}\n"
//                     "will receive ${ds.get("Currency")} ${ds.get("Amount").toStringAsFixed(2)} from your account.",
//                     textAlign: TextAlign.center,
//                     style: GoogleFonts.ubuntu(
//                         fontSize: 14, color: Colors.grey[600]),
//                   ),
//                   hGap(10),
//                   Text(
//                     "Transaction ID:\n${ds.get("TransactionID")}",
//                     textAlign: TextAlign.center,
//                     style:
//                         GoogleFonts.ubuntu(fontSize: 14, color: Colors.black),
//                   ),
//                   hGap(10),
//                   ElevatedButton(
//                       style: ButtonStyle(
//                           backgroundColor:
//                               MaterialStateProperty.all(Colors.orange),
//                           shape:
//                               MaterialStateProperty.all<RoundedRectangleBorder>(
//                                   RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(25.0),
//                           ))),
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

// FirebaseFirestore _fire = FirebaseFirestore.instance;

// Future<void> approveInitiatedPayment(Map paymentInfo) async {
//     var merchantDoc = await _fire
//         .collection("Merchants")
//         .doc(paymentInfo['Merchant']['MerchantUID'])
//         .get();

//     // 1). Marks the initiated payment complete for user
//     // 2). Creates a payment record for the users
//     // 3). Credits the merchants account and updates metrics
//     // 4). Marks the payment complete for merchant
//     // 5). Debits the user's account balance
//     await Future.wait([
//       _fire
//           .collection("Initiated Payments")
//           .doc(paymentInfo['TransactionID'])
//           .update({
//         "Status": "Completed",
//       }),
//       _fire.collection("Transactions").doc(paymentInfo['TransactionID']).set({
//         "Comment": "",
//         "UserID": box("user_id"),
//         "AttendedTo": false,
//         "Status": "Completed",
//         "SentReceived": 'Sent',
//         "TransactionType": "Payment",
//         "DateCreated": Timestamp.now(),
//         "Method": "Payment to merchant",
//         "Amount": paymentInfo['Amount'],
//         "Reference": paymentInfo['Reference'],
//         "FullNames": paymentInfo['FullNames'],
//         "TransactionID": paymentInfo['TransactionID'],
//         "Merchant": {
//           "MerchantUID": merchantDoc.get("AccountID"),
//           "MerchantName": merchantDoc.get("CompanyName"),
//           "MerchantCode": merchantDoc.get("MerchantCode"),
//           "MerchantLogoUrl": merchantDoc.get("ProfileLogoUrl"),
//         },
//         "AmountPlusFee": paymentInfo['AmountPlusFee'],
//         "Currency": box("currency"),
//         "PhoneNumber": 'To ${merchantDoc.get("CompanyName")}',
//         "TransactionFeePercent": paymentInfo['TransactionFeePercent'],
//         "TransactionFeeInKwacha": paymentInfo['TransactionFeeInKwacha'],
//       }),
//       _fire
//           .collection("Merchants")
//           .doc(paymentInfo['Merchant']['MerchantUID'])
//           .update({
//         "AmountReceivedTodaySoFar": FieldValue.increment(paymentInfo['Amount']),
//         "TotalAmountReceived": FieldValue.increment(paymentInfo['Amount']),
//         "NumberOfTransactionsThisMonthSoFar": FieldValue.increment(1),
//         "Balance": FieldValue.increment(paymentInfo['Amount']),
//         "NumberOfTransactionsToday": FieldValue.increment(1),
//         "BalanceAtLastDeposit": merchantDoc.get("Balance"),
//         "NumberOfTransactions": FieldValue.increment(1),
//         "AmountReceivedThisMonthSoFar":
//             FieldValue.increment(paymentInfo['Amount']),
//       }),
//       _fire
//           .collection("Merchants")
//           .doc(paymentInfo['Merchant']['MerchantUID'])
//           .collection("Transactions")
//           .doc(paymentInfo['TransactionID'])
//           .update({
//         "Status": "Completed",
//       }),
//       _fire.collection("Users").doc(box("user_id")).update(
//           {"Balance": FieldValue.increment(-paymentInfo['AmountPlusFee'])}),
//       // sendTransactionNotifications(paymentInfo, ""),
//       // callWebhook(
//       //     double.parse(paymentInfo['Amount'].toString()),
//       //     paymentInfo['Merchant']['MerchantUID'],
//       //     paymentInfo['TransactionID'],
//       //     paymentInfo['Reference'])
//     ]);
//   }

//   Future<void> rejectInitiatedPayment(Map paymentInfo) async {
//     // 1). Marks the payment rejected for user
//     // 2). Marks the payment rejected for merchant
//     await Future.wait([
//       _fire
//           .collection("Initiated Payments")
//           .doc(paymentInfo['TransactionID'])
//           .update({
//         "Status": "Rejected",
//       }),
//       _fire
//           .collection("Merchants")
//           .doc(paymentInfo['Merchant']['MerchantUID'])
//           .collection("Transactions")
//           .doc(paymentInfo['TransactionID'])
//           .update({
//         "Status": "Rejected",
//       }),
//     ]);
//   }
