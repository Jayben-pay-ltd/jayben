// ignore_for_file: non_constant_identifier_names

import 'package:jayben/Home/elements/attach_media/components/attach_media_widgets.dart';
import 'package:jayben/Home/elements/timeline_privacy_settings/timeline_privacy_settings.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Home/home_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddMoneyToSavingsConfirmationPage extends StatefulWidget {
  const AddMoneyToSavingsConfirmationPage(
      {Key? key, required this.transfer_info})
      : super(key: key);

  final Map transfer_info;

  @override
  _AddMoneyToSavingsConfirmationPageState createState() =>
      _AddMoneyToSavingsConfirmationPageState();
}

class _AddMoneyToSavingsConfirmationPageState
    extends State<AddMoneyToSavingsConfirmationPage> {
  @override
  void initState() {
    if (box("DefaultTransactionPrivacy") == "Public") {
      setState(() {
        postToFeed = true;
      });
    } else if (box("DefaultTransactionPrivacy") == "Private") {
      setState(() {
        postToFeed = false;
      });
    }
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      statusBarColor: Colors.transparent,
    ));
    super.initState();
  }

  bool isLoading = false;
  bool postToFeed = true;
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String account_name = widget.transfer_info["accountName"];
    return Consumer<SavingsProviderFunctions>(
      builder: (_, value, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                if (value.returnIsLoading()) return;

                hideKeyboard();

                // makes comments mandatory for all transfers
                if (_commentController.text.isEmpty) {
                  showSnackBar(context, "Enter a comment");
                  return;
                }

                showSnackBar(context, "Transfer is being made...");

                value.toggleIsLoading();

                // adds money to savings & creates a text only timeline post
                bool isSuccessful =
                    await value.saveMoneyToSharedNasAccWithTextOnlyPost({
                  "account_id": widget.transfer_info["accountID"],
                  "comment": _commentController.text.trim(),
                  "amount": widget.transfer_info["amount"],
                });

                value.toggleIsLoading();

                if (!isSuccessful) {
                  showSnackBar(
                      context, "Transfer failed! Please try again later.",
                      color: Colors.red);

                  return;
                }

                // routes user to the home page
                changePage(context, const HomePage(), type: "pr");
              },
              backgroundColor: Colors.green,
              label: value.returnIsLoading()
                  ? loadingIcon(context)
                  : Row(
                      children: [
                        Image.asset(
                          'assets/arrows.png',
                          color: Colors.white,
                          height: 20,
                          width: 20,
                        ),
                        const SizedBox(width: 10),
                        const Text("Transfer Now"),
                      ],
                    ),
            ),
            body: WillPopScope(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => hideKeyboard(),
                          child: Container(
                            width: width(context),
                            color: Colors.white,
                            height: height(context),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(top: 30, bottom: 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(left: 20),
                                  width: width(context),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              'Transfer \n${box("currency")} ${widget.transfer_info["amount"]} to',
                                          style: GoogleFonts.ubuntu(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[600],
                                            fontSize: 30,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '\n$account_name?',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                            fontSize: 28,
                                          ),
                                        )
                                      ],
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                hGap(10),
                                commentTextField(context, {
                                  "comment_controller": _commentController,
                                  "transfer_info": widget.transfer_info
                                }),
                                hGap(10),
                                commentExplainWidget(context)
                                // checkBoxWidget(context),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  backButton(context)
                ],
              ),
              onWillPop: () async {
                Navigator.pop(context);
                return true;
              },
            ),
          ),
        );
      },
    );
  }

  Widget commentExplainWidget(BuildContext context) {
    return Container(
      width: width(context),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "Example: Pizza 🍕 or I love you 😘",
        style: GoogleFonts.ubuntu(
          color: Colors.grey[400],
          fontSize: 15,
        ),
      ),
    );
  }

  Widget commentTextField(BuildContext context, Map body_info) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: TextField(
        cursorHeight: 24,
        cursorColor: Colors.grey[700],
        minLines: 1,
        maxLines: 10,
        controller: body_info["comment_controller"],
        keyboardType: TextInputType.text,
        inputFormatters: [
          LengthLimitingTextInputFormatter(300),
        ],
        textAlign: TextAlign.left,
        style: GoogleFonts.ubuntu(
          fontSize: 24,
          color: Colors.grey[600],
          fontWeight: FontWeight.w300,
        ),
        decoration: InputDecoration(
          suffixIcon: GestureDetector(
            onTap: () => showBottomCard(
                context,
                selectMediaCard(
                    context, {"transaction_type": "savings", ...body_info})),
            child: Icon(
              color: Colors.grey[500],
              Icons.camera_alt_rounded,
              size: 20,
            ),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
          filled: true,
          fillColor: Colors.grey[200],
          focusColor: Colors.white,
          isDense: false,
          alignLabelWithHint: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelStyle: const TextStyle(
              color: Colors.black87, fontSize: 18, fontFamily: 'AvenirLight'),
          hintText: 'Write a Comment...',
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintStyle: GoogleFonts.ubuntu(
            color: Colors.grey[500],
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget checkBoxWidget(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => postToFeed = !postToFeed),
      child: Container(
        width: width(context),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: postToFeed ? Colors.green[300] : Colors.white,
                border: Border.all(
                  color: postToFeed ? Colors.green[300]! : Colors.grey[300]!,
                ),
                shape: BoxShape.circle,
              ),
              height: 25.0,
              width: 25.0,
              child: postToFeed
                  ? const Center(
                      child: Icon(
                        color: Colors.white,
                        Icons.check,
                        size: 15,
                      ),
                    )
                  : nothing(),
            ),
            wGap(10),
            Text(
              "Share to timeline",
              style: GoogleFonts.ubuntu(
                color: Colors.grey[500],
                fontSize: 15,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () =>
                  changePage(context, const TimelinePrivacySettingsPage()),
              child: SizedBox(
                child: Text(
                  "Timeline Privacy",
                  style: GoogleFonts.ubuntu(
                    decoration: TextDecoration.underline,
                    color: Colors.grey[500],
                    fontSize: 13,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
