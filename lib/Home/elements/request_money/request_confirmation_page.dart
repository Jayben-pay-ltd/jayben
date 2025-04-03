import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import '../../home_page.dart';
import '../../../Utilities/legacy_functions.dart';

class RequestConfirmation extends StatefulWidget {
  const RequestConfirmation(
      {Key? key,
      required this.requesteePhoneNumber,
      required this.requesteeFullNames,
      required this.amount})
      : super(key: key);

  final String amount;
  final String requesteeFullNames;
  final String requesteePhoneNumber;

  @override
  _RequestConfirmationState createState() => _RequestConfirmationState();
}

class _RequestConfirmationState extends State<RequestConfirmation> {
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent));
    super.initState();
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                if (isLoading == false) {
                  setState(() {
                    isLoading = true;
                  });

                  // await RequestFunctions().submitRequest(
                  //     widget.amount, widget.requesteePhoneNumber);

                  setState(() {
                    isLoading = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(seconds: 4),
                      backgroundColor: Colors.grey[700],
                      content: const Text("Cash Request has been sent.")));

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));
                }
              },
              backgroundColor: Colors.green,
              label: Row(
                children: [
                  Image.asset('assets/send.png',
                      height: 20, width: 20, color: Colors.white),
                  const SizedBox(width: 10),
                  const Text("Submit"),
                ],
              ),
            ),
            backgroundColor: Colors.white,
            body: WillPopScope(
                child: isLoading
                    ? Container(
                        color: Colors.white,
                        height: height(context),
                        width: width(context),
                        child: const Center(
                            child: CircularProgressIndicator(
                          color: Colors.green,
                        )))
                    : Stack(
                        children: [
                          Container(
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.only(top: 30, bottom: 0),
                              color: Colors.white,
                              height: height(context),
                              width: width(context),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        width: width(context),
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    'Request \n${Hive.box('userInfo').get("Currency")} ${widget.amount} from',
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 26),
                                              ),
                                              TextSpan(
                                                text:
                                                    '\n${widget.requesteeFullNames}?',
                                                style: const TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 26,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                          textAlign: TextAlign.start,
                                        )),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child:
                                          Text("*Press SUBMIT to send request.",
                                              style: GoogleFonts.ubuntu(
                                                color: Colors.grey[600],
                                              )),
                                    )
                                  ])),
                          Positioned(
                              top: 40,
                              left: 10,
                              child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.arrow_back, size: 40)))
                        ],
                      ),
                onWillPop: () async {
                  Navigator.pop(context);
                  return true;
                })));
  }
}
