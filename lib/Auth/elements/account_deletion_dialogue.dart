// ignore_for_file: non_constant_identifier_names

import 'package:jayben/Utilities/provider_functions.dart';
import '../../Utilities/general_widgets.dart';
import 'package:jayben/Auth/pre_login.dart';
import 'package:provider/provider.dart';
import '../../Utilities/Constants.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:async';

class AccountDeletionDialogue extends StatefulWidget {
  const AccountDeletionDialogue({Key? key}) : super(key: key);

  @override
  State<AccountDeletionDialogue> createState() =>
      _AccountDeletionDialogueState();
}

class _AccountDeletionDialogueState extends State<AccountDeletionDialogue> {
  String deletion_reason = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(40),
        ),
      ),
      content: Consumer<AuthProviderFunctions>(
        builder: (_, value, child) {
          return Stack(
            children: [
              SizedBox(
                width: width(context) * 0.8,
                child: ListView(
                  physics: const PageScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/cancel.png", height: 30, width: 30),
                        hGap(20),
                        Text(
                          "Are you sure you want to delete your account?",
                          textAlign: TextAlign.center,
                          style: googleStyle(
                            color: Colors.grey[900]!,
                            weight: FontWeight.bold,
                            size: 15,
                          ),
                        ),
                        hGap(20),
                        Stack(
                          children: [
                            Container(
                              width: width(context) * 0.9,
                              height: height(context) * 0.06,
                              alignment: Alignment.centerLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                color: Colors.grey[200],
                              ),
                              child: Text(
                                deletion_reason == ""
                                    ? 'Select a reason'
                                    : deletion_reason,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 15,
                              child: DropdownButton<String>(
                                underline: const SizedBox(),
                                items: <String>[
                                  "I have too many accounts",
                                  "Doesn't have useful features",
                                  'I was just checking the app out',
                                  "Don't use this account anymore",
                                  "Don't use the app anymore",
                                  "Too many features",
                                  "Hard to use",
                                  "Other",
                                ].map(
                                  (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  },
                                ).toList(),
                                onChanged: (value) =>
                                    setState(() => deletion_reason = value!),
                              ),
                            )
                          ],
                        ),
                        hGap(20),
                        InkWell(
                          onTap: () async {
                            if (deletion_reason.isEmpty) {
                              showSnackBar(context, "Select a deletion reason",
                                  color: Colors.grey[800]!);

                              return;
                            }

                            value.toggleIsLoading();

                            Future.delayed(const Duration(seconds: 3));

                            bool user_has_money = await value
                                .checkIfUserHasMoneyInSystemBeforeAccountDeletion();

                            value.toggleIsLoading();

                            if (user_has_money) {
                              showSnackBar(
                                  context,
                                  "Your account has money in it. Please withdraw all of it first or send it "
                                  "to another account. If you have an active savings account, you need to first "
                                  "transfer ownership to another Jayben user and then you can close this account.",
                                  color: Colors.red,
                                  duration: 10);

                              return;
                            }

                            goBack(context);

                            showSnackBar(
                                context, "Your account is being deleted",
                                color: Colors.red, duration: 10);

                            // changePage(context, const PreLoginPage(),
                            //     type: "pr");

                            // await value.deleteAccount(deletion_reason);

                            // await boxClear();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: width(context) * 0.25,
                            height: height(context) * 0.06,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                              color: Colors.red,
                            ),
                            child: value.returnIsLoading()
                                ? loadingIcon(context)
                                : Text(
                                    "Delete",
                                    textAlign: TextAlign.center,
                                    style: googleStyle(
                                      weight: FontWeight.bold,
                                      color: Colors.white,
                                      size: 18,
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
                  child: Icon(
                    Icons.close,
                    color: Colors.grey[600],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
