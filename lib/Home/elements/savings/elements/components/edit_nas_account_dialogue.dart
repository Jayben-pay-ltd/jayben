// ignore_for_file: non_constant_identifier_names

import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../../../home_page.dart';

class EditExistinNasAccountNameDialogue extends StatefulWidget {
  const EditExistinNasAccountNameDialogue({Key? key, required this.account_map})
      : super(key: key);

  final Map account_map;

  @override
  State<EditExistinNasAccountNameDialogue> createState() =>
      _EditExistinNasAccountNameDialogueState();
}

class _EditExistinNasAccountNameDialogueState
    extends State<EditExistinNasAccountNameDialogue> {
  @override
  void initState() {
    setState(() {
      savingsAccountNameController.text = widget.account_map["account_name"];
    });
    super.initState();
  }

  final savingsAccountNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<SavingsProviderFunctions>(builder: (_, value, child) {
      return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(40))),
        content: Stack(
          children: [
            GestureDetector(
              onTap: () => hideKeyboard(),
              child: SizedBox(
                width: width(context) * 0.8,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/edit.png", height: 30, width: 30),
                        hGap(20),
                        Text(
                          "Edit account name",
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                            fontSize: 15,
                          ),
                        ),
                        hGap(25),
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
                              hintText: 'Name Of Account',
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
                        hGap(25),
                        GestureDetector(
                          onTap: () async {
                            if (value.returnIsLoading()) return;

                            if (savingsAccountNameController.text ==
                                widget.account_map["account_name"]) {
                              showSnackBar(context, "No changes made");
                              goBack(context);
                              goBack(context);
                              return;
                            }

                            hideKeyboard();

                            value.toggleIsLoading();

                            // creates the no access sav acc
                            await value.updateExistingSharedNasAccName(
                                widget.account_map, {
                              "account_name": savingsAccountNameController.text,
                            });

                            value.toggleIsLoading();

                            showSnackBar(context, 'account updated',
                                duration: 5);

                            changePage(context, const HomePage(), type: "pr");
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
                        ),
                      ],
                    ),
                  ],
                ),
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

  Decoration addSubtractButtonDeco(String type) {
    return BoxDecoration(
      color: Colors.grey[200],
      borderRadius: type != "add"
          ? const BorderRadius.only(
              topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))
          : const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
    );
  }
}
