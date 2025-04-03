// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:jayben/Utilities/provider_functions.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import '../../../request_money/components/request_tile.dart';

// class RequestsTile extends StatefulWidget {
//   const RequestsTile({Key? key, required this.myRequests}) : super(key: key);

//   final QuerySnapshot<Object?>? myRequests;

//   @override
//   _RequestsTileState createState() => _RequestsTileState();
// }

// class _RequestsTileState extends State<RequestsTile> {
//   final _auth = FirebaseAuth.instance;
//   bool isApproving = false;
//   bool isRejecting = false;

//   @override
//   Widget build(BuildContext context) {
//     return widget.myRequests != null
//         ? MediaQuery.removePadding(
//             context: context,
//             removeTop: true,
//             removeBottom: true,
//             child: ListView.builder(
//                 padding: const EdgeInsets.only(bottom: 20, top: 10),
//                 shrinkWrap: true,
//                 scrollDirection: Axis.vertical,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: widget.myRequests!.docs.length,
//                 itemBuilder: (context, index) {
//                   DocumentSnapshot ds = widget.myRequests!.docs[index];
//                   var amount = double.parse(ds['Amount'].toString());
//                   return GestureDetector(
//                     onTap: () async {
//                       if (ds['RequesteeID'] == _auth.currentUser!.uid &&
//                           ds["Status"] == "Pending") {
//                         await showDialog(
//                             context: context,
//                             builder: (context) {
//                               return RequestTileWidget(
//                                 requestID: ds['RequestID'],
//                                 requesteeFullNames: ds['RequesteeFullNames'],
//                                 requesteeNotifToken: ds['RequesteeNotifToken'],
//                                 requesteeID: ds['RequesteeID'],
//                                 requesterID: ds['RequesterID'],
//                                 amount: ds['Amount'],
//                                 requesterFullNames: ds['RequesterFullNames'],
//                                 requesterNotifToken: ds['RequesterNotifToken'],
//                               );
//                             });
//                       }
//                     },
//                     child: Container(
//                         margin: const EdgeInsets.symmetric(vertical: 5),
//                         color: Colors.grey[100],
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 10, horizontal: 20),
//                         width: width(context),
//                         child: Row(
//                           children: [
//                             Column(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(ds['RequesterID'] == _auth.currentUser!.uid
//                                     ? "Sent To"
//                                     : "Sent From"),
//                                 const SizedBox(height: 5),
//                                 Text(
//                                     ds['RequesterID'] == _auth.currentUser!.uid
//                                         ? "${ds["RequesteeFullNames"]}"
//                                         : "${ds["RequesterFullNames"]}",
//                                     style: const TextStyle(
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold)),
//                                 const SizedBox(height: 5),
//                                 Text(ds["Status"],
//                                     style: GoogleFonts.ubuntu(
//                                         color: ds["Status"] == "Pending"
//                                             ? Colors.orange[700]
//                                             : (ds["Status"] == "Approved"
//                                                 ? Colors.green
//                                                 : Colors.red),
//                                         fontWeight: FontWeight.bold)),
//                               ],
//                             ),
//                             const Spacer(),
//                             Column(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text(
//                                     ds['RequesterID'] == _auth.currentUser!.uid
//                                         ? "+ ${ds["Currency"]} ${amount.toStringAsFixed(2)}"
//                                         : "- ${ds["Currency"]} ${amount.toStringAsFixed(2)}",
//                                     style: const TextStyle(
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold)),
//                                 const SizedBox(height: 5),
//                                 Row(
//                                   children: [
//                                     Text(
//                                       DateFormat.yMMMd()
//                                           .format(ds["DateCreated"].toDate()),
//                                     ),
//                                     // const SizedBox(width: 4),
//                                     Text(
//                                         " - ${DateFormat.Hm().format(ds["DateCreated"].toDate())}")
//                                   ],
//                                 ),
//                                 const SizedBox(height: 5),
//                                 Text(ds['RequestID'],
//                                     style: const TextStyle(
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.bold))
//                               ],
//                             ),
//                           ],
//                         )),
//                   );
//                 }),
//           )
//         : Container(
//             height: height(context) * 0.5,
//             width: width(context),
//             alignment: Alignment.center,
//             child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: const [
//                   CircularProgressIndicator(
//                       color: Colors.white, strokeWidth: 0.5)
//                 ]));
//   }
// }
