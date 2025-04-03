// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class ReportPostDialog extends StatefulWidget {
  const ReportPostDialog({Key? key, required this.post_map}) : super(key: key);

  final Map post_map;

  @override
  State<ReportPostDialog> createState() => _ReportPostDialogState();
}

class _ReportPostDialogState extends State<ReportPostDialog> {
  String typeOfReport = "";
  bool isReportingVideo = false;
  final reportController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProviderFunctions>(
      builder: (_, value, child) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(40))),
          content: SizedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    "Report Post",
                    style: GoogleFonts.ubuntu(
                        color: Colors.grey[600], fontSize: 20),
                  ),
                ]),
                const SizedBox(height: 20),
                Stack(
                  children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        width: width(context) * 0.9,
                        height: height(context) * 0.06,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(
                            typeOfReport == ""
                                ? 'Select a reason'
                                : typeOfReport,
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 15),
                          ),
                          //Spacer(),
                        ])),
                    Positioned(
                      right: 15,
                      child: DropdownButton<String>(
                        underline: const SizedBox(),
                        items: <String>[
                          'Nudity',
                          'Profanity',
                          'Dangerous',
                          "Graphic",
                          'Irrelevant',
                          "Misleading",
                          "Spam",
                          "Copyright Violation",
                          "Other"
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            typeOfReport = value!;
                          });
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: width(context) * 0.9,
                  child: TextField(
                    cursorColor: Colors.grey[700],
                    cursorHeight: 15,
                    minLines: 1,
                    maxLines: 2,
                    controller: reportController,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100),
                    ],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[700],
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      focusColor: Colors.white,
                      hintText: 'Tell us more...',
                      fillColor: Colors.grey[200],
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
                        fontSize: 15,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    if (value.returnIsLoading()) return;

                    if (typeOfReport.isEmpty || reportController.text.isEmpty) {
                      showSnackBar(context, "Fill in all the report boxes");

                      return;
                    }

                    hideKeyboard();

                    value.toggleIsLoading();

                    await value.reportPost({
                      "post_row": widget.post_map,
                      "report_type": typeOfReport,
                      "report_details": reportController.text,
                    });

                    value.toggleIsLoading();

                    showSnackBar(context, "Report successful! Thank you.",
                        color: Colors.green);

                    Navigator.pop(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: height(context) * 0.06,
                    width: width(context) * 0.25,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    child: value.returnIsLoading()
                        ? loadingIcon(this.context)
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
