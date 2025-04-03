// ignore_for_file: non_constant_identifier_names

import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SendReplyMessageDialogue extends StatefulWidget {
  const SendReplyMessageDialogue({Key? key, required this.other_person_user_id})
      : super(key: key);

  final String other_person_user_id;

  @override
  State<SendReplyMessageDialogue> createState() =>
      _SendReplyMessageDialogueState();
}

class _SendReplyMessageDialogueState extends State<SendReplyMessageDialogue> {
  final reply_message_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProviderFunctions>(
      builder: (_, value, child) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(40),
            ),
          ),
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
                          Image.asset("assets/comments.png",
                              height: 30, width: 30),
                          hGap(20),
                          Text(
                            "Send a reply message",
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
                              controller: reply_message_controller,
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
                                hintText: 'Write a reply...',
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

                              if (reply_message_controller.text.isEmpty) {
                                showSnackBar(context, "Write a reply...");

                                return;
                              }

                              hideKeyboard();

                              showSnackBar(context, 'reply sent',
                                  color: Colors.green);

                              goBack(context);

                              // creates the no access sav acc
                              await value.sendMessage({
                                "message_controller": reply_message_controller,
                                "reply_message_thumbnail_url": null,
                                "reply_message_first_name": null,
                                "reply_message_last_name": null,
                                "other_person_user_id":
                                    widget.other_person_user_id,
                                "reply_message_type": null,
                                "message_extension": null,
                                "reply_message_uid": null,
                                "reply_message_id": null,
                                "message_type": "text",
                                "reply_message": null,
                                "reply_caption": null,
                                "caption": null,
                              });
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
                                      "Send",
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
                  onTap: () {
                    hideKeyboard();
                    goBack(context);
                  },
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
      },
    );
  }
}
