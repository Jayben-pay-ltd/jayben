// // ignore_for_file: non_constant_identifier_names
// import 'package:jayben/Utilities/provider_functions.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../add_money_to_savings.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';

// class NoAccessSavAccTileFirebase extends StatelessWidget {
//   const NoAccessSavAccTileFirebase({Key? key, required this.account_info})
//       : super(key: key);

//   final DocumentSnapshot account_info;

//   @override
//   Widget build(BuildContext context) {
//     double amount = double.parse(account_info.get("Balance").toString());
//     return Container(
//         width: width(context) * 0.8,
//         alignment: Alignment.center,
//         margin: const EdgeInsets.only(top: 30),
//         decoration: BoxDecoration(
//             color: Colors.grey[100],
//             borderRadius: const BorderRadius.all(Radius.circular(15))),
//         padding:
//             const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Image.asset("assets/lock.png",
//                     height: 15, color: Colors.grey[600]),
//                 const SizedBox(width: 10),
//                 Text(
//                   "No Access Savings Account",
//                   style: GoogleFonts.ubuntu(
//                     color: Colors.grey[600],
//                     fontSize: 15,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Text(
//               account_info.get("AccountName"),
//               maxLines: 3,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               style: GoogleFonts.ubuntu(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green[900],
//                 fontSize: 30,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: const BorderRadius.all(
//                   Radius.circular(20),
//                 ),
//               ),
//               child: Text.rich(
//                 TextSpan(
//                   text: "${Hive.box('userInfo').get("Currency")} ",
//                   children: [
//                     TextSpan(
//                       text: amount.toStringAsFixed(2),
//                       style: GoogleFonts.ubuntu(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 26,
//                         color: Colors.grey[700],
//                       ),
//                     )
//                   ],
//                 ),
//                 style: GoogleFonts.ubuntu(
//                   fontSize: 20,
//                   color: Colors.grey[700],
//                 ),
//               ),
//             ),
//             hGap(10),
//             Text.rich(
//               TextSpan(
//                 text: account_info.get("DaysLeft").toString(),
//                 children: [
//                   TextSpan(
//                     text: account_info.get("DaysLeft") == 1
//                         ? "  day left 🥂"
//                         : "  days left",
//                     style: GoogleFonts.ubuntu(
//                       fontSize: 15,
//                       color: Colors.grey[500],
//                     ),
//                   )
//                 ],
//               ),
//               style: GoogleFonts.ubuntu(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[700],
//               ),
//             ),
//             const SizedBox(height: 15),
//             GestureDetector(
//               onTap: () => changePage(
//                 context,
//                 TransferToSavingsPage(
//                   accountName: account_info["AccountName"],
//                   accountID: account_info["AccountID"],
//                   backendType: "Firebase",
//                   accountType: "Personal",
//                 ),
//               ),
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Container(
//                     alignment: Alignment.center,
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 10, horizontal: 20),
//                     decoration: BoxDecoration(
//                         color: Colors.green[300],
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(20))),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.add, color: Colors.white),
//                         wGap(5),
//                         Text("add money",
//                             style: GoogleFonts.ubuntu(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 20,
//                                 color: Colors.white)),
//                       ],
//                     ),
//                   ),
//                   // Icon(
//                   //   Icons.block,
//                   //   color: Colors.red[900],
//                   // )
//                 ],
//               ),
//             ),
//           ],
//         ));
//   }
// }
