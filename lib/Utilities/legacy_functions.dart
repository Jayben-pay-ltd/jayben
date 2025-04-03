// // ignore_for_file: file_names, avoid_print, non_constant_identifier_names
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:jayben/Utilities/provider_functions.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:intl/intl.dart';
// import 'package:hive/hive.dart';
// import 'package:uuid/uuid.dart';
// import 'dart:convert';

// final binding = WidgetsFlutterBinding.ensureInitialized();
// final firebaseMessaging = FirebaseMessaging.instance;
// // final _authUser = FirebaseAuth.instance.currentUser;
// // final _fire = FirebaseFirestore.instance;
// // final _auth = FirebaseAuth.instance;
// const id = Uuid();

// class FeedFunctions {
//   getFeed() async {
//     // var qs = await _fire
//     //     .collection("Users")
//     //     .doc(box("user_id"))
//     //     .collection("Timeline")
//     //     .where("Privacy", isEqualTo: "Public")
//     //     .get();

//     return [
//       // _fire
//       //     .collection("Users")
//       //     .doc(box("user_id"))
//       //     .collection("Timeline")
//       //     .where("Privacy", isEqualTo: "Public")
//       //     .orderBy("DateCreated", descending: true)
//       //     .snapshots(),
//       // qs.docs.isNotEmpty ? qs.docs.length : 0
//     ];
//     // if has no feed posts, return 0 as the number of posts
//     // add pagination for better performance
//     // convert to cloud function
//   }

//   addToTimeline(receiverNames, receiverUID, comment, privacy) async {
//     // if (box("TransactionPrivacy") == "Public") {
//     // if timelines privacy is public
//     var postID = id.v4();

//     // await _fire
//     //     .collection("Users")
//     //     .doc(box("user_id"))
//     //     .collection("Timeline")
//     //     .doc(postID)
//     //     .set({
//     //   "DateCreated": Timestamp.now(),
//     //   "SenderNames": "${box("FirstName")} ${box("LastName")}",
//     //   "ReceiverNames": receiverNames,
//     //   "Comment": comment,
//     //   "Privacy": privacy,
//     //   "SenderUID": box("user_id"),
//     //   "ReceiverUID": receiverUID,
//     //   "PostID": postID,
//     //   "Likes": 0,
//     //   "isLiked": false,
//     //   "hasSeen": false,
//     //   // this is to keep track of like status
//     //   "Comments": 0,
//     //   "Views": 0,
//     //   "SenderIconUrl": box("profile_image_url")
//     // });
//     // }
//     // posts transaction to timeline
//   }

//   // likePost(postID, postOwnerID) async {
//   //   await _fire
//   //       .collection("Users")
//   //       .doc(box("user_id"))
//   //       .collection("Timeline")
//   //       .doc(postID)
//   //       .update({
//   //     "Likes": FieldValue.increment(1),
//   //     "isLiked": true,
//   //     "hasSeen": true,
//   //   });
//   // increases like count on main post

//   // if (postOwnerID != box("user_id")) {
//   //   await _fire
//   //       .collection("Users")
//   //       .doc(postOwnerID)
//   //       .collection("Timeline")
//   //       .doc(postID)
//   //       .update({
//   //     "Likes": FieldValue.increment(1),
//   //   });
//   // }
//   // // increases like count on main post

//   // var notifToken = await _fire.collection("Users").doc(postOwnerID).get();

//   // await _fire
//   //     .collection("Users")
//   //     .doc(postOwnerID)
//   //     .collection("Timeline")
//   //     .doc(postID)
//   //     .collection("Likes")
//   //     .doc(box("user_id"))
//   //     .set({
//   //   "PostID": postID,
//   //   "UserID": box("user_id"),
//   //   "PostOwnerUID": postOwnerID,
//   //   "DateCreated": Timestamp.now(),
//   //   "FullNames": "${box("FirstName")} ${box("LastName")}",
//   //   "PostOwnerNotifToken": notifToken.get("NotificationToken")
//   // });
//   // records who liked the post & used to send notification
// }

// markAsSeen(postOwnerID, postID) async {
//   await _fire
//       .collection("Users")
//       .doc(box("user_id"))
//       .collection("Timeline")
//       .doc(postID)
//       .update({"hasSeen": true});
//   // marks post as seen

//   if (postOwnerID != box("user_id")) {
//     var notifToken = await _fire.collection("Users").doc(postOwnerID).get();

//     await _fire
//         .collection("Users")
//         .doc(postOwnerID)
//         .collection("Timeline")
//         .doc(postID)
//         .update({"Views": FieldValue.increment(1)});
//     // increases view count for owner

//     await _fire
//         .collection("Users")
//         .doc(postOwnerID)
//         .collection("Timeline")
//         .doc(postID)
//         .collection("Views")
//         .doc(box("user_id"))
//         .set({
//       "PostID": postID,
//       "UserID": box("user_id"),
//       "PostOwnerUID": postOwnerID,
//       "DateCreated": Timestamp.now(),
//       "FullNames": "${box("FirstName")} ${box("LastName")}",
//       "PostOwnerNotifToken": notifToken.get("NotificationToken")
//     });
//   }
//   // records who liked the post & used to send notification
// }

// commentOnPost(postID, postOwnerID, comment) async {
//   await _fire
//       .collection("Users")
//       .doc(box("user_id"))
//       .collection("Timeline")
//       .doc(postID)
//       .update({
//     "Comments": FieldValue.increment(1),
//     "hasSeen": true,
//   });
//   // increases like count on main post

//   await _fire
//       .collection("Users")
//       .doc(postOwnerID)
//       .collection("Timeline")
//       .doc(postID)
//       .update({
//     "Comments": FieldValue.increment(1),
//   });
//   // increases like count on main post

//   var notifToken = await _fire.collection("Users").doc(postOwnerID).get();

//   await _fire
//       .collection("Users")
//       .doc(postOwnerID)
//       .collection("Timeline")
//       .doc(postID)
//       .collection("Comments")
//       .doc(box("user_id"))
//       .set({
//     "PostID": postID,
//     "UserID": box("user_id"),
//     "PostOwnerUID": postOwnerID,
//     "DateCreated": Timestamp.now(),
//     "Comment": comment,
//     "isLiked": false,
//     "Likes": 0,
//     "FullNames": "${box("FirstName")} ${box("LastName")}",
//     "PostOwnerNotifToken": notifToken.get("NotificationToken")
//   });
//   // records who liked the post & used to send notification
// }

// getComments(postID, postOwnerID) async {
//   var comments = await _fire
//       .collection("Users")
//       .doc(postOwnerID)
//       .collection("Timeline")
//       .doc(postID)
//       .collection("Comments")
//       .orderBy("DateCreated", descending: true)
//       .get();

//   return comments;
// }

// class GroupFunctions {
//   getGroupsRooms() async {
//     return _fire
//         .collection("Savings Groups")
//         .where("GroupActive", isEqualTo: true)
//         .where("GroupMembers", arrayContains: box("user_id"))
//         .orderBy("GroupLastMessageDateSent", descending: true)
//         .snapshots();
//   }

//   createSavingsGroup(String groupName) async {
//     var groupID = id.v4();

//     var res = await http.post(
//         Uri.parse(
//             "https://us-central1-jayben-de41c.cloudfunctions.net/groupsFunctions/swf/create_group"),
//         headers: {
//           'Content-type': 'application/json',
//         },
//         body: json.encode({
//           'UserID': box("user_id"),
//           'GroupID': groupID,
//           "Currency": Hive.box('userInfo').get("Currency"),
//           "PhoneNumber": _auth.currentUser!.phoneNumber,
//           "NotificationToken": Hive.box('userInfo').get("NotificationToken"),
//           "ProfileIconUrl": Hive.box('userInfo').get("profile_image_url"),
//           "GroupName": groupName,
//           'Username': Hive.box('userInfo').get("Username"),
//         }));

//     if (res.body == "Success") {
//       return [true, groupID];
//     } else {
//       return [false, ""];
//     }
//   }

//   sendMessage(
//     String groupID,
//     String groupName,
//     String message,
//     String messageType,
//     String caption,
//     String messageExtension,
//     String replyMessage,
//     String replyCaption,
//     String replySentByUsername,
//     String replySentByUID,
//     String videoReplyMessage,
//     String replyMessageType,
//   ) async {
//     var messageID = id.v4();

//     await http.post(
//         Uri.parse(
//             "https://us-central1-jayben-de41c.cloudfunctions.net/groupsFunctions/swf/send_message"),
//         headers: {
//           'Content-type': 'application/json',
//         },
//         body: json.encode({
//           'GroupID': groupID,
//           'GroupName': groupName,
//           "Caption": caption,
//           "MessageID": messageID,
//           "MessageType": messageType,
//           "Message": message,
//           "MessageExtension": messageExtension,
//           "ReplyMessage": replyMessage,
//           "ReplyCaption": replyCaption,
//           "ReplySentByUsername": replySentByUsername,
//           "ReplySentByUID": replySentByUID,
//           "ReplyMessageType": replyMessageType,
//           "VideoReplyMessage": videoReplyMessage,
//           "NotificationToken": Hive.box('userInfo').get("NotificationToken"),
//           "OwnerProfileImage": Hive.box('userInfo').get("profile_image_url"),
//           'OwnerUsername': Hive.box('userInfo').get("Username"),
//           'OwnerUserID': box("user_id"),
//         }));
//   }

//   depositToGroup(double amount, String groupID) async {
//     var res = await http.post(
//         Uri.parse(
//             "https://us-central1-jayben-de41c.cloudfunctions.net/groupsFunctions/swf/deposit"),
//         headers: {
//           'Content-type': 'application/json',
//         },
//         body: json.encode({
//           'UserID': box("user_id"),
//           'GroupID': groupID,
//           'Amount': amount,
//           'Username': Hive.box('userInfo').get("Username"),
//           'Currency': Hive.box('userInfo').get("Currency"),
//         }));

//     if (res.body == "Success") {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   withdrawFromGroup(double amount, String groupID) async {
//     var res = await http.post(
//         Uri.parse(
//             "https://us-central1-jayben-de41c.cloudfunctions.net/groupsFunctions/swf/withdraw"),
//         headers: {
//           'Content-type': 'application/json',
//         },
//         body: json.encode({
//           'UserID': box("user_id"),
//           'GroupID': groupID,
//           'Amount': amount,
//           'Username': Hive.box('userInfo').get("Username"),
//           'Currency': Hive.box('userInfo').get("Currency"),
//         }));

//     if (res.body.toString().substring(11, 18) == "Success") {
//       return true;
//     } else if (res.body.toString().substring(11, 18) == "Failed\"") {
//       return false;
//     }
//   }

//   getGroupDetailsAndMessages(String groupID) async {
//     var groupDoc = _fire
//         .collection("Savings Groups")
//         .where("GroupID", isEqualTo: groupID)
//         .snapshots();

//     return [
//       groupDoc,
//       _fire
//           .collection("Savings Groups")
//           .doc(groupID)
//           .collection("Messages")
//           .orderBy("DateCreated", descending: true)
//           .snapshots()
//     ];
//   }

//   getMessages(String groupID, int limit) async {
//     Response res = await http.post(
//         Uri.parse(
//             "https://us-central1-jayben-de41c.cloudfunctions.net/groupsFunctions/swf/get_messages"),
//         headers: {
//           'Content-type': 'application/json',
//         },
//         body: json.encode({
//           'NumberOfMessages': limit,
//           'GroupID': groupID,
//         }));

//     final data = jsonDecode(res.body);

//     return data;
//   }

//   getMessageStream(String groupID) async {
//     return _fire
//         .collection("Savings Groups")
//         .doc(groupID)
//         .collection("Messages")
//         .orderBy("DateCreated", descending: false)
//         .snapshots();
//   }

//   getReceiveGroupNotifsStatus(
//       String groupID, DateTime lastMessageSentDate) async {
//     var qs = await _fire
//         .collection("Savings Groups")
//         .doc(groupID)
//         .collection("Members")
//         .doc(box("user_id"))
//         .get();

//     String date = await processDates(lastMessageSentDate);

//     return [qs.get("ReceiveNotifications"), date];
//   }

//   markAsSeen(String groupID, List lastMessageSeenBy) async {
//     if (!lastMessageSeenBy.contains(box("user_id"))) {
//       await _fire.collection("Savings Groups").doc(groupID).update({
//         "GroupLastMessageReadBy": FieldValue.arrayUnion([box("user_id")])
//       });
//     }
//   }

//   addToCurrentlyInChat(String groupID) async {
//     await http.post(
//         Uri.parse(
//             "https://us-central1-jayben-de41c.cloudfunctions.net/groupsFunctions/swf/go_in_chat"),
//         headers: {
//           'Content-type': 'application/json',
//         },
//         body: json.encode({'GroupID': groupID, 'UserID': box("user_id")}));
//   }

//   removeFromCurrentlyInChat(String groupID) async {
//     await http.post(
//         Uri.parse(
//             "https://us-central1-jayben-de41c.cloudfunctions.net/groupsFunctions/swf/go_out_chat"),
//         headers: {
//           'Content-type': 'application/json',
//         },
//         body: json.encode({'GroupID': groupID, 'UserID': box("user_id")}));
//   }

//   // =========== group settingss

//   addMember(String memberUsername, String groupID, String groupName) async {
//     Response res = await http.post(
//         Uri.parse(
//             "https://us-central1-jayben-de41c.cloudfunctions.net/groupsFunctions/swf/add_member"),
//         headers: {
//           'Content-type': 'application/json',
//         },
//         body: json.encode({
//           'MemberUsername': memberUsername.toLowerCase(),
//           'GroupID': groupID,
//           'GroupName': groupName,
//           'InviterUsername': box("Username"),
//           'InviterUserID': box("user_id")
//         }));

//     if (res.body == "Success") {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   banMember(String groupID, String groupName, String memberUserID,
//       String memberUsername) async {
//     // ***** ADD CODE SO THAT REGULAR ADMINS CANT BAN OTHER ADMINS*********

//     Response res = await http.post(
//         Uri.parse(
//             "https://us-central1-jayben-de41c.cloudfunctions.net/groupsFunctions/swf/ban_member"),
//         headers: {
//           'Content-type': 'application/json',
//         },
//         body: json.encode({
//           'MemberUserID': memberUserID,
//           "MemberUsername": memberUsername,
//           'GroupID': groupID,
//           "GroupName": groupName,
//           'AdminUsername': box("Username"),
//           'AdminUserID': box("user_id"),
//           'AdminNotificationToken': box("NotificationToken")
//         }));

//     if (res.body == "Success") {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   removeMember(String groupID, String memberUID, String groupName) async {
//     Response res = await http.post(
//         Uri.parse(
//             "https://us-central1-jayben-de41c.cloudfunctions.net/groupsFunctions/swf/remove_member"),
//         headers: {
//           'Content-type': 'application/json',
//         },
//         body: json.encode({
//           'MemberUserID': memberUID,
//           'GroupID': groupID,
//           'GroupName': groupName,
//           'InviterUsername': box("Username"),
//           'InviterUserID': box("user_id")
//         }));

//     if (res.body == "Success") {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   leaveGroup(String groupID) async {
//     Response res = await http.post(
//         Uri.parse(
//             "https://us-central1-jayben-de41c.cloudfunctions.net/groupsFunctions/swf/leave_group"),
//         headers: {
//           'Content-type': 'application/json',
//         },
//         body: json.encode({
//           'UserID': box("user_id"),
//           'GroupID': groupID,
//           'Username': box("Username"),
//         }));

//     if (res.body == "Success") {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   getGroupProfileDetails(String groupID) async {
//     var members = await _fire
//         .collection("Savings Groups")
//         .doc(groupID)
//         .collection("Members")
//         .get();

//     var groupDoc = await _fire.collection("Savings Groups").doc(groupID).get();

//     return [
//       members.docs.firstWhere((doc) => doc['UserID'] == box("user_id")),
//       groupDoc,
//       null,
//       members.docs.where((doc) => doc['IsAdmin'] == true).toList(),
//       members.docs.where((doc) => doc['IsAdmin'] == false).toList()
//     ];
//   }

//   getAllGroupTransactions(String groupID) async {
//     var transactions = await _fire
//         .collection("Groups Transactions")
//         .where("GroupID", isEqualTo: groupID)
//         .get();

//     // opt this code for pagination

//     return transactions;
//   }

//   makeAdmin(
//       String groupID, String newAdminUserID, String newAdminUsername) async {
//     await http.post(
//         Uri.parse(
//             "https://us-central1-jayben-de41c.cloudfunctions.net/groupsFunctions/swf/make_admin"),
//         headers: {
//           'Content-type': 'application/json',
//         },
//         body: json.encode({
//           'AdminUserID': box("user_id"),
//           'GroupID': groupID,
//           'NewAdminUserID': newAdminUserID,
//           'NewAdminUsername': newAdminUsername,
//           'AdminUsername': Hive.box('userInfo').get('Username'),
//           'AdminNotificationToken':
//               Hive.box('userInfo').get('NotificationToken')
//         }));
//   }

//   removeAdmin(String groupID, String removeAdminUserID,
//       String removeAdminUsername) async {
//     await http.post(
//         Uri.parse(
//             "https://us-central1-jayben-de41c.cloudfunctions.net/groupsFunctions/swf/remove_admin"),
//         headers: {
//           'Content-type': 'application/json',
//         },
//         body: json.encode({
//           'AdminUserID': box("user_id"),
//           'GroupID': groupID,
//           'RemoveAdminUserID': removeAdminUserID,
//           'RemoveAdminUsername': removeAdminUsername,
//           'AdminUsername': Hive.box('userInfo').get('Username'),
//           'AdminNotificationToken':
//               Hive.box('userInfo').get('NotificationToken')
//         }));
//   }

//   updateGroupNotifToken() async {
//     QuerySnapshot groups = await _fire
//         .collection("Users")
//         .doc(box("user_id"))
//         .collection("Groups")
//         .get();

//     var token = await firebaseMessaging.getToken();

//     if (groups.docs.isNotEmpty) {
//       for (var group in groups.docs) {
//         await _fire
//             .collection("Savings Groups")
//             .doc(group.id)
//             .collection("Members")
//             .doc(box("user_id"))
//             .update({"NotificationToken": token});
//       }
//     }
//   }

//   muteGroup(String groupID) async {
//     await _fire
//         .collection("Savings Groups")
//         .doc(groupID)
//         .collection("Members")
//         .doc(box("user_id"))
//         .update({
//       "ReceiveNotifications": false,
//     });
//   }

//   unMuteGroup(String groupID) async {
//     await _fire
//         .collection("Savings Groups")
//         .doc(groupID)
//         .collection("Members")
//         .doc(box("user_id"))
//         .update({
//       "ReceiveNotifications": true,
//     });
//   }

//   processDates(DateTime lastMessageSentDate) {
//     var dateToday = DateTime.now();
//     var messageDateSentFormatted =
//         DateFormat.yMMMMd().format(lastMessageSentDate);
//     var messageDateSent = DateFormat.yMd().format(lastMessageSentDate);
//     var dateYesterday = DateTime.now().subtract(const Duration(days: 1));
//     var dateTodayFormatted = DateFormat.yMMMMd().format(dateToday);
//     var dateYesterdayFormatted = DateFormat.yMMMMd().format(dateYesterday);

//     if (messageDateSentFormatted == dateTodayFormatted) {
//       return "Today";
//     } else if (messageDateSentFormatted == dateYesterdayFormatted) {
//       return "Yesterday";
//     } else {
//       return messageDateSent;
//     }
//   }

//   // ========== GroupRoom Functions
// }

// class LoanFunctions {
//   calcAmounts(String amountRequested, double loanInterestRate) async {
//     DocumentSnapshot adminDoc =
//         await _fire.collection("Admin").doc("Legal").get();

//     var amountAfterOurProcessingFee = double.parse(amountRequested) -
//         (double.parse(amountRequested) *
//             double.parse(adminDoc.get("LoanProcessingFeePercent").toString()) /
//             100);

//     var amountToBePaidBack = double.parse(amountRequested) +
//         (double.parse(amountRequested) * loanInterestRate / 100);

//     return [
//       adminDoc.get("LoanProcessingFeePercent"),
//       amountAfterOurProcessingFee,
//       amountToBePaidBack
//     ];
//   }

//   updateNotifTokensLoans(String notifToken) async {
//     var loansQS = await getLoans();

//     if (loansQS[0] != null) {
//       for (var i = 0; i < loansQS[0].docs.length; i++) {
//         await _fire
//             .collection("Loans")
//             .doc(loansQS[0].docs[i].id)
//             .update({"NotificationToken": notifToken});
//       }
//     }
//   }

//   getLoanDetails() async {
//     var loanProviderDocsQS = await _fire
//         .collection("Admin")
//         .doc("Legal")
//         .collection("Loans")
//         .orderBy("Max Amount")
//         .get();

//     var adminDoc = await _fire.collection("Admin").doc("Legal").get();

//     return [loanProviderDocsQS, adminDoc];
//   }

//   getTotalAmountOfActiveLoans() async {
//     double total = 0.0;

//     var loansQS = await _fire
//         .collection("Loans")
//         .where("UserID", isEqualTo: box("user_id"))
//         .where("isActive", isEqualTo: true)
//         .where("LoadCurrentStatus", isEqualTo: "Approved")
//         .get();

//     for (var i = 0; i < loansQS.docs.length; i++) {
//       total = total + loansQS.docs[i].get("Amount");
//     }

//     return total;
//   }

//   getLoans() async {
//     var allLoansQS = await _fire
//         .collection("Loans")
//         .where("UserID", isEqualTo: box("user_id"))
//         .orderBy("DateCreated", descending: true)
//         .get();

//     var activeLoansQS = await _fire
//         .collection("Loans")
//         .where("UserID", isEqualTo: box("user_id"))
//         .where("isActive", isEqualTo: true)
//         .get();

//     return [
//       allLoansQS.docs.isEmpty ? null : allLoansQS,
//       activeLoansQS.docs.isEmpty ? 0 : activeLoansQS.docs.length
//     ];
//   }

//   getLoanTCs(double amount) async {
//     var adminDoc = await _fire.collection("Admin").doc("Legal").get();

//     if (int.parse(amount.toStringAsFixed(0)) >
//         adminDoc.get("LoanThresholdAmountToLargerLoanProvider")) {
//       var largeLoanDoc = await _fire
//           .collection("Admin")
//           .doc("Legal")
//           .collection("Loans")
//           .doc("Large Loans")
//           .get();

//       return [largeLoanDoc, adminDoc];
//     } else if (int.parse(amount.toStringAsFixed(0)) <=
//         adminDoc.get("LoanThresholdAmountToLargerLoanProvider")) {
//       var smallLoanDoc = await _fire
//           .collection("Admin")
//           .doc("Legal")
//           .collection("Loans")
//           .doc("Small Loans")
//           .get();

//       return [smallLoanDoc, adminDoc];
//     }
//   }
// }
