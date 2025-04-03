// ignore_for_file: file_names, non_constant_identifier_names
import 'package:jayben/Auth/components/Enter_details_step1_page_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewUSSDShortcutPage extends StatefulWidget {
  const NewUSSDShortcutPage({Key? key}) : super(key: key);

  @override
  _NewUSSDShortcutPageState createState() => _NewUSSDShortcutPageState();
}

class _NewUSSDShortcutPageState extends State<NewUSSDShortcutPage> {
  final shortcut_name_controller = TextEditingController();
  final shortcut_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<UssdProviderFunctions>(
      builder: (_, value, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: Colors.white,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                if (value.returnIsLoading()) return;

                hideKeyboard();

                if (shortcut_controller.text.isEmpty ||
                    shortcut_name_controller.text.isEmpty) {
                  showSnackBar(context, 'Enter a shortcut & a shortcut name');
                  return;
                }

                if (!shortcut_controller.text.contains(">")) {
                  showSnackBar(
                      context,
                      "Each step/option must be separated by a '>'\n\n"
                      "Example: *117# > 1 > 2 > 4 > 1234",
                      duration: 15);
                  return;
                }

                value.toggleIsLoading();

                // encrypts and then updates the user's pin
                await value.createUSSDShortcut(
                    shortcut_name_controller.text, shortcut_controller.text);

                value.toggleIsLoading();

                showSnackBar(context, 'USSD Shortcut has been created!');

                goBack(context);
              },
              backgroundColor: Colors.green,
              label: value.returnIsLoading()
                  ? loadingIcon(context)
                  : const Text("Create Shortcut"),
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Container(
                    width: width(context),
                    height: height(context),
                    alignment: Alignment.center,
                    color: Colors.white,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                          top: 180, bottom: 180, left: 20),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Give the',
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 26,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '\nshortcut a name',
                                    style: GoogleFonts.ubuntu(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[400],
                                      fontSize: 26,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          hGap(20),
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: TextField(
                              cursorHeight: 24,
                              cursorColor: Colors.grey[700],
                              maxLines: 2,
                              minLines: 1,
                              keyboardType: TextInputType.multiline,
                              controller: shortcut_name_controller,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(150),
                              ],
                              textAlign: TextAlign.left,
                              style: GoogleFonts.ubuntu(
                                fontSize: 24,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter shortcut name',
                                isDense: true,
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                hintStyle: GoogleFonts.ubuntu(
                                  fontSize: 24,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
                          hGap(10),
                          Text(
                            "Example: 'Buy Airtel 5GB iKali Data Bundle'.",
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          hGap(60),
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Enter the',
                                      style: GoogleFonts.ubuntu(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '\nUSSD shortcut',
                                      style: GoogleFonts.ubuntu(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[400],
                                        fontSize: 26,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.left,
                              )), //Step number
                          hGap(15),
                          Text(
                            "Each step must be separated by a '>'",
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          hGap(10),
                          Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: TextField(
                              cursorHeight: 24,
                              cursorColor: Colors.grey[700],
                              maxLines: 2,
                              minLines: 1,
                              controller: shortcut_controller,
                              keyboardType: TextInputType.multiline,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.ubuntu(
                                fontSize: 24,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter shortcut',
                                isDense: true,
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                hintStyle: GoogleFonts.ubuntu(
                                  fontSize: 24,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                          ),
                          hGap(10),
                          Text(
                            "Example: *117# > 1 > 2 > 4 > 1234",
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  authBackButton(context)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
