// ignore_for_file: file_names

import 'package:jayben/Utilities/provider_functions.dart';
import '../../../../Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Utilities/legacy_functions.dart';
import 'request_confirmation_page.dart';
import 'package:flutter/material.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({Key? key}) : super(key: key);

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> with WidgetsBindingObserver {
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

  String balance = "0";
  bool isSubmitting = false;
  String primaryPaymentMethod = "";
  final GlobalKey _scaffoldKey = GlobalKey();
  final _amountController = TextEditingController();
  final _numberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.green,
            onPressed: () async {
              var myLine = box("phone_number").replaceAll("+26", '');

              if (_amountController.text != "" &&
                  _numberController.text != "" &&
                  isSubmitting == false &&
                  _numberController.text != myLine) {
                setState(() {
                  isSubmitting = true;
                });

                // var validationDetails = await RequestFunctions()
                //     .checkIfPhoneNumberValid(_numberController.text);

                // if (validationDetails[0] == true) {
                //   setState(() {
                //     isSubmitting = false;
                //   });
                //   Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //           builder: (builder) => RequestConfirmation(
                //               amount:
                //                   _amountController.text.replaceAll('-', ''),
                //               requesteeFullNames: validationDetails[1],
                //               requesteePhoneNumber: _numberController.text)));
                // } else if (validationDetails[0] == false) {
                //   setState(() {
                //     isSubmitting = false;
                //   });
                //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                //       duration: Duration(seconds: 2),
                //       backgroundColor: Colors.red,
                //       content: Text("Phone number is invalid")));
                // }
              } else if (_amountController.text == "") {
                setState(() {
                  isSubmitting = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                    content: Text("Enter an amount.")));
              } else if (_numberController.text == "") {
                setState(() {
                  isSubmitting = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                    content: Text("Enter a Phone Number")));
              } else if (_numberController.text == myLine) {
                setState(() {
                  isSubmitting = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red,
                    content: Text("Stop wasting time boss Lol")));
              }
            },
            label: const Text("Confirm")),
        backgroundColor: Colors.white,
        body: WillPopScope(
            child: isSubmitting
                ? loadingScreenPlain(context)
                : Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.only(top: 30, bottom: 50),
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Enter an amount',
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 26),
                                              ),
                                              TextSpan(
                                                text: '\nto request',
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.green[400],
                                                    fontSize: 26,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.left,
                                        )),
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 100),
                                      child: TextField(
                                        cursorHeight: 24,
                                        cursorColor: Colors.grey[700],
                                        maxLines: 1,
                                        controller: _amountController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(100),
                                          FilteringTextInputFormatter.deny(
                                              RegExp(r"\s\b|\b\s"))
                                        ],
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.ubuntu(
                                          fontSize: 24,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w300,
                                        ),
                                        decoration: InputDecoration(
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          labelText: Hive.box("userInfo")
                                              .get('Currency')
                                              .toLowerCase(),
                                          labelStyle: const TextStyle(
                                              color: Colors.black87,
                                              fontSize: 20,
                                              fontFamily: 'AvenirLight'),
                                          hintText: 'Amount',
                                          isDense: true,
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey[800]!,
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey[800]!,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey[800]!,
                                            ),
                                          ),
                                          disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey[800]!,
                                            ),
                                          ),
                                          hintStyle: GoogleFonts.ubuntu(
                                            fontSize: 24,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 70),
                                    Container(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Enter a phone number',
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.grey[700],
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 26),
                                              ),
                                              TextSpan(
                                                text: '\nto request from',
                                                style: GoogleFonts.ubuntu(
                                                    color: Colors.green[400],
                                                    fontSize: 26,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.left,
                                        )),
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20, right: 100),
                                      child: TextField(
                                        cursorHeight: 24,
                                        cursorColor: Colors.grey[700],
                                        maxLines: 1,
                                        controller: _numberController,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(12),
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]')),
                                          FilteringTextInputFormatter.deny(
                                              RegExp(r"\s\b|\b\s"))
                                        ],
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.ubuntu(
                                          fontSize: 24,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w300,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Phone Number',
                                          isDense: true,
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey[800]!,
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey[800]!,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey[800]!,
                                            ),
                                          ),
                                          disabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.grey[800]!,
                                            ),
                                          ),
                                          hintStyle: GoogleFonts.ubuntu(
                                            fontSize: 24,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Text("Example: 0977888707",
                                          style: GoogleFonts.ubuntu(
                                            color: Colors.grey[600],
                                          )),
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                      ),
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
              return false;
            }));
  }
}
