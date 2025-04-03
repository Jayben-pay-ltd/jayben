// ignore_for_file: non_constant_identifier_names
import 'dart:io';

import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Home/home_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ExtendSharedNasAccountCard extends StatefulWidget {
  const ExtendSharedNasAccountCard({Key? key, required this.account_map})
      : super(key: key);

  final Map account_map;

  @override
  State<ExtendSharedNasAccountCard> createState() =>
      _ExtendSharedNasAccountCardState();
}

class _ExtendSharedNasAccountCardState
    extends State<ExtendSharedNasAccountCard> {
  int number_of_days_to_extend_account = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProviderFunctions>(
      builder: (_, value, child) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Container(
            padding: EdgeInsets.only(
                left: 30, right: 30, top: 30, bottom: Platform.isIOS ? 40 : 25),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.account_map["account_name"],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w200,
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Extend by how many days?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 30),
                quantityButtons(context),
                const SizedBox(height: 30),
                saveButton(context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget quantityButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            // makes device vibrate once
            Vibrate.feedback(FeedbackType.light);

            setState(() {
              if (number_of_days_to_extend_account > 0) {
                number_of_days_to_extend_account--;
              }
            });
          },
          child: Container(
            width: 80,
            height: 50,
            decoration: addSubtractButtonDeco("subtract"),
            child: Icon(
              Icons.remove,
              color: Colors.grey[600],
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 3),
        Container(
          width: 135,
          height: 50,
          color: Colors.grey[200],
          alignment: Alignment.center,
          child: Text(
            number_of_days_to_extend_account.toString(),
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 19,
            ),
          ),
        ),
        const SizedBox(width: 3),
        GestureDetector(
          onTap: () {
            // makes device vibrate once
            Vibrate.feedback(FeedbackType.light);

            setState(() {
              number_of_days_to_extend_account++;
            });
          },
          child: Container(
            width: 80,
            height: 50,
            decoration: addSubtractButtonDeco("add"),
            child: Icon(
              Icons.add,
              color: Colors.grey[600],
              size: 30,
            ),
          ),
        )
      ],
    );
  }

  Widget saveButton(BuildContext context) {
    return Consumer<SavingsProviderFunctions>(builder: (context, value, child) {
      return GestureDetector(
        onTap: () async {
          if (value.returnIsLoading()) return;

          if (number_of_days_to_extend_account == 0) {
            showSnackBar(context, "No changes made");
            goBack(context);
            goBack(context);
            return;
          }

          hideKeyboard();

          value.toggleIsLoading();

          // creates the no access sav acc
          bool is_extended = await value.extendExistingSharedNasAccDaysLeft(
            widget.account_map["account_id"],
            number_of_days_to_extend_account,
          );

          value.toggleIsLoading();

          if (!is_extended) {
            showSnackBar(context, "Error extending account");
          } else {
            showSnackBar(context, 'Account Extended', duration: 5);

            changePage(context, const HomePage(), type: "pr");
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: width(context) * 0.25,
          height: height(context) * 0.06,
          decoration: const BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.all(
              Radius.circular(30),
            ),
          ),
          child: value.returnIsLoading()
              ? loadingIcon(context)
              : Text(
                  "Save",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
        ),
      );
    });
  }

  Widget priceTag(String price) {
    return Container(
      decoration: deco(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        "${box('Currency')} $price",
        style: GoogleFonts.ubuntu(color: Colors.white),
      ),
    );
  }
}

Decoration addSubtractButtonDeco(String type) {
  return BoxDecoration(
      color: Colors.grey[200],
      borderRadius: type != "add"
          ? const BorderRadius.only(
              topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))
          : const BorderRadius.only(
              topRight: Radius.circular(20), bottomRight: Radius.circular(20)));
}

EdgeInsets customPadding() {
  return const EdgeInsets.symmetric(vertical: 10, horizontal: 15);
}

Decoration orderButtonDeco(Color color) {
  return BoxDecoration(
      color: color, borderRadius: const BorderRadius.all(Radius.circular(50)));
}

Decoration deco() {
  return const BoxDecoration(
      color: Colors.black, borderRadius: BorderRadius.all(Radius.circular(20)));
}
