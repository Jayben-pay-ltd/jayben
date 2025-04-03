// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class SubmitFeedbackDialogue extends StatefulWidget {
  const SubmitFeedbackDialogue({Key? key}) : super(key: key);

  @override
  State<SubmitFeedbackDialogue> createState() => _SubmitFeedbackDialogueState();
}

class _SubmitFeedbackDialogueState extends State<SubmitFeedbackDialogue> {
  final feedback_controller = TextEditingController();
  String type_of_feedback = "";
  bool is_submitting = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProviderFunctions>(
      builder: (_, value, child) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(40))),
          content: SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Submit Feedback",
                      style: GoogleFonts.ubuntu(
                        color: Colors.grey[600],
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                hGap(20),
                Stack(
                  children: [
                    Container(
                      width: width(context) * 0.9,
                      height: height(context) * 0.06,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            type_of_feedback.isEmpty
                                ? 'Select a feedback type'
                                : type_of_feedback,
                            style: GoogleFonts.ubuntu(
                              color: type_of_feedback.isEmpty
                                  ? Colors.grey[500]
                                  : Colors.black,
                              fontSize: 19,
                            ),
                          ),
                          //Spacer(),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 15,
                      child: DropdownButton<String>(
                        underline: const SizedBox(),
                        items: <String>[
                          'Bug or Issue',
                          'Feature Request',
                          'Other',
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: GoogleFonts.ubuntu(color: Colors.black),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => type_of_feedback = value!),
                      ),
                    )
                  ],
                ),
                hGap(20),
                SizedBox(
                  width: width(context) * 0.9,
                  child: TextField(
                    cursorColor: Colors.green[700],
                    cursorHeight: 25,
                    minLines: 1,
                    maxLines: 4,
                    controller: feedback_controller,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(500),
                    ],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[200],
                      focusColor: Colors.white,
                      hintText: 'What is your feedback?',
                      isDense: true,
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      disabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      hintStyle: GoogleFonts.ubuntu(
                        color: Colors.grey[500],
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                hGap(20),
                GestureDetector(
                  onTap: () async {
                    if (value.returnIsLoading()) return;

                    hideKeyboard();

                    if (type_of_feedback.isEmpty ||
                        feedback_controller.text.isEmpty) {
                      showSnackBar(context, "Fill in all the submission boxes");

                      return;
                    }

                    setState(() {
                      is_submitting = true;
                    });

                    await value.submitFeedback(
                        feedback_controller.text, type_of_feedback);

                    await value.getFeedbackSubmissions();

                    setState(() {
                      is_submitting = false;
                    });

                    showSnackBar(context, "Feedback submitted! Thank you.",
                        color: Colors.green);

                    Navigator.pop(context);
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
                    child: is_submitting
                        ? loadingIcon(context)
                        : Text(
                            "Submit",
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
          ),
        );
      },
    );
  }
}
