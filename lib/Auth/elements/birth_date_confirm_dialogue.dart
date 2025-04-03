// ignore_for_file: non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:jayben/Auth/enter_details_step2_page.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class BirthDateConfirm extends StatefulWidget {
  const BirthDateConfirm({Key? key, required this.account_details_map})
      : super(key: key);

  final Map account_details_map;

  @override
  State<BirthDateConfirm> createState() => _BirthDateConfirmState();
}

class _BirthDateConfirmState extends State<BirthDateConfirm> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderFunctions>(builder: (_, value, child) {
      List<String> date_split =
          widget.account_details_map["dob"].toString().split(" ");

      int age =
          int.parse(DateTime.now().year.toString()) - int.parse(date_split[2]);
      return AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(40),
          ),
        ),
        content: Stack(
          children: [
            SizedBox(
              width: width(context) * 0.8,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Kindly Confirm Your Birthday",
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                          fontSize: 15,
                        ),
                      ),
                      hGap(20),
                      Text(
                        "You selected ${widget.account_details_map["dob"]} as your birthday",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(
                          color: Colors.grey[600],
                          fontSize: 15,
                        ),
                      ),
                      hGap(20),
                      Text(
                        "Are you $age years old?",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      hGap(30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              showSnackBar(
                                  context, "Choose your correct birthdate");

                              goBack(context);

                              widget.account_details_map["onDateConfirm"];
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: width(context) * 0.25,
                              height: height(context) * 0.06,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
                              child: value.returnIsLoading()
                                  ? loadingIcon(context)
                                  : Text(
                                      "No",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.ubuntu(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                          ),
                          wGap(20),
                          GestureDetector(
                            onTap: () async {
                              changePage(
                                context,
                                EnterDetailsStep2Page(
                                  userInfo: widget.account_details_map,
                                ),
                              );
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: width(context) * 0.25,
                              height: height(context) * 0.06,
                              decoration: BoxDecoration(
                                color: Colors.green[400]!,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(30),
                                ),
                              ),
                              child: value.returnIsLoading()
                                  ? loadingIcon(context)
                                  : Text(
                                      "Yes",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.ubuntu(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
