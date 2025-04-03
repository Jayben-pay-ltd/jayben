// // ignore_for_file: file_names

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter/material.dart';
// import 'package:jayben/Utilities/provider_functions.dart';
// import 'package:flutter/services.dart';
// import '../../../../Utilities/legacy_functions.dart';
// import 'components/RequestsTile.dart';

// class RequestsListPage extends StatefulWidget {
//   const RequestsListPage({Key? key}) : super(key: key);

//   @override
//   _RequestsListPageState createState() => _RequestsListPageState();
// }

// class _RequestsListPageState extends State<RequestsListPage>
//     with WidgetsBindingObserver {
//   @override
//   void initState() {
//     onPagelaunch().whenComplete(() {
//       setState(() {});
//     });
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//         statusBarBrightness: Brightness.light,
//         statusBarIconBrightness: Brightness.dark,
//         systemNavigationBarColor: Colors.white,
//         systemNavigationBarIconBrightness: Brightness.dark,
//         statusBarColor: Colors.transparent));
//     super.initState();
//   }

//   QuerySnapshot<Object?>? requestsQS;
//   bool isLoading = false;
//   bool? isEmpty;

//   onPagelaunch() async {
//     // var snapshot = await RequestFunctions().getRequests();

//     if (!mounted) return;
//     if (mounted) {
//       setState(() {
//         // requestsQS = snapshot;
//       });
//     }

//     if (requestsQS == null) {
//       setState(() {
//         isEmpty = true;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.dark,
//       child: Scaffold(
//           backgroundColor: Colors.white,
//           appBar: AppBar(
//             leading: GestureDetector(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Icon(Icons.arrow_back,
//                     size: 30, color: Color(0xFF616161))),
//             backgroundColor: Colors.white,
//             title: Text("Requests",
//                 style: GoogleFonts.ubuntu(
//                     color: const Color(0xFF616161),
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold)),
//             centerTitle: true,
//             actions: [
//               GestureDetector(
//                   onTap: () async {
//                     setState(() {
//                       isLoading = true;
//                     });
//                     await onPagelaunch();
//                     setState(() {
//                       isLoading = false;
//                     });
//                   },
//                   child: const Icon(Icons.refresh,
//                       size: 25, color: Color(0xFF616161))),
//               const SizedBox(width: 20)
//             ],
//           ),
//           body: SafeArea(
//             child: Stack(
//               children: [
//                 Container(
//                     height: height(context),
//                     width: width(context),
//                     color: Colors.white,
//                     child: requestsQS == null && isEmpty != true
//                         ? const Center(
//                             child: CircularProgressIndicator(
//                             color: Colors.green,
//                           ))
//                         : ListView(
//                             shrinkWrap: true,
//                             physics: const BouncingScrollPhysics(),
//                             children: [
//                                 Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Flexible(
//                                         child: RequestsTile(
//                                             myRequests: requestsQS)),
//                                   ],
//                                 ),
//                               ])),
//                 SizedBox(
//                     width: width(context),
//                     child: isLoading
//                         ? LinearProgressIndicator(
//                             minHeight: 3,
//                             backgroundColor: Colors.transparent,
//                             color: Colors.orange[700])
//                         : const SizedBox())
//               ],
//             ),
//           )),
//     );
//   }
// }
