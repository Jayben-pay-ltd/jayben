// ignore_for_file: non_constant_identifier_names

import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../../../home_page.dart';

class CreateSharedNoAccessAccountDialogue extends StatefulWidget {
  const CreateSharedNoAccessAccountDialogue({Key? key}) : super(key: key);

  @override
  State<CreateSharedNoAccessAccountDialogue> createState() =>
      _CreateSharedNoAccessAccountDialogueState();
}

class _CreateSharedNoAccessAccountDialogueState
    extends State<CreateSharedNoAccessAccountDialogue> {
  final numberOfDaysController = TextEditingController();
  final savingsAccountNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProviderFunctions>(builder: (_, value, child) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(40))),
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
                      Image.asset("assets/lock.png", height: 30, width: 30),
                      hGap(20),
                      Text(
                        "Create No Access Account",
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[900],
                          fontSize: 15,
                        ),
                      ),
                      hGap(20),
                      Text(
                        "How many days should the money be locked for?",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(
                          color: Colors.grey[800],
                          fontSize: 15,
                        ),
                      ),
                      hGap(20),
                      SizedBox(
                        width: width(context) * 0.9,
                        child: TextField(
                          cursorColor: Colors.grey[700],
                          cursorHeight: 22,
                          minLines: 1,
                          maxLines: 2,
                          controller: numberOfDaysController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(4),
                          ],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                            fontSize: 22,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            focusColor: Colors.white,
                            hintText: 'Number of Days',
                            isDense: true,
                            border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            disabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            hintStyle: GoogleFonts.ubuntu(
                              color: Colors.grey[500],
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      hGap(20),
                      SizedBox(
                        width: width(context) * 0.9,
                        child: TextField(
                          cursorColor: Colors.grey[700],
                          cursorHeight: 22,
                          minLines: 1,
                          maxLines: 2,
                          controller: savingsAccountNameController,
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(25),
                          ],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.w300,
                            color: Colors.black,
                            fontSize: 22,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            focusColor: Colors.white,
                            hintText: 'Name of Account',
                            isDense: true,
                            border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            disabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            hintStyle: GoogleFonts.ubuntu(
                              color: Colors.grey[500],
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      hGap(10),
                      Text(
                        "Example: Birthday Savings 🎁 or Vacation 🏖",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.ubuntu(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      hGap(20),
                      GestureDetector(
                        onTap: () async {
                          if (value.returnIsLoading()) return;

                          hideKeyboard();

                          if (savingsAccountNameController.text.isEmpty ||
                              numberOfDaysController.text.isEmpty) {
                            showSnackBar(context,
                                'Fill in every field. Number of days & Account Name');

                            return;
                          }

                          int num_of_days = int.parse(numberOfDaysController
                              .text
                              .replaceAll("-", "")
                              .trim());

                          if (num_of_days < 1) {
                            showSnackBar(
                                context, "Minimum lock up period is 1 day");
                            return;
                          }

                          value.toggleIsLoading();

                          // creates the no access sav acc
                          await value.createSharedNoAccessAccount({
                            "account_name": savingsAccountNameController.text,
                            "number_of_days": num_of_days,
                          });

                          changePage(context, const HomePage(), type: "pr");

                          value.toggleIsLoading();

                          showSnackBar(
                              context,
                              'No Access Savings Account has been created. '
                              '\nYou can now save money yourself or with friends & family '
                              '\nfor ${numberOfDaysController.text} days.',
                              color: Colors.grey[700]!,
                              duration: 5);
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
                                  "Create",
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
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () => goBack(context),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[100],
                  child: Icon(
                    color: Colors.grey[600],
                    Icons.close,
                    size: 20,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
