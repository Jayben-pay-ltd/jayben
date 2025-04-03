// ignore_for_file: file_names, non_constant_identifier_names
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../home_page.dart';

class ChangePINPage extends StatefulWidget {
  const ChangePINPage({Key? key}) : super(key: key);

  @override
  _ChangePINPageState createState() => _ChangePINPageState();
}

class _ChangePINPageState extends State<ChangePINPage> {
  @override
  void initState() {
    decryptExistingPin();
    super.initState();
  }

  final confirmPasscodeController = TextEditingController();
  final oldPasscodeController = TextEditingController();
  final passcodeController = TextEditingController();
  String decrypted_old_pin = "";

  Future<void> decryptExistingPin() async {
    // decrypts the encrypted user pin
    // String? decrypted_pin =
        // await context.read<AuthProviderFunctions>().decryptPin(box("PIN"));

    // if (!mounted || decrypted_pin == null) return;

    // setState(() => decrypted_old_pin = decrypted_pin);
  }

  @override
  void dispose() {
    confirmPasscodeController.dispose();
    oldPasscodeController.dispose();
    passcodeController.dispose();
    decrypted_old_pin = "";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderFunctions>(
      builder: (_, value, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: decrypted_old_pin.isEmpty
              ? loadingScreenPlainNoBackButton(context)
              : Scaffold(
                  backgroundColor: Colors.white,
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: () async {
                      if (value.returnIsLoading()) return;

                      if (passcodeController.text.isEmpty &&
                          oldPasscodeController.text.isEmpty &&
                          confirmPasscodeController.text.isEmpty) {
                        showSnackBar(context, 'Fill in all fields.');
                        return;
                      }

                      hideKeyboard();

                      if (decrypted_old_pin != oldPasscodeController.text) {
                        showSnackBar(context, 'Old PIN is incorrect.');

                        return;
                      }

                      if (oldPasscodeController.text ==
                          confirmPasscodeController.text) {
                        showSnackBar(context,
                            'Your old PIN and new PIN cannot be the same.');
                        return;
                      }

                      if (passcodeController.text !=
                          confirmPasscodeController.text) {
                        showSnackBar(context, 'PINs do not match.');
                        return;
                      }

                      value.toggleIsLoading();

                      // encrypts and then updates the user's pin
                      await value.changePIN(passcodeController.text.trim(), "1234");

                      value.toggleIsLoading();

                      showSnackBar(
                          context, 'PIN has been changed successfully.');

                      changePage(context, const HomePage(),
                          type: "pushReplacement");
                    },
                    backgroundColor: Colors.green,
                    label: value.returnIsLoading()
                        ? loadingIcon(context)
                        : const Text("Change PIN"),
                  ),
                  body: SafeArea(
                    bottom: false,
                    child: Stack(
                      children: [
                        Container(
                          width: width(context),
                          height: height(context),
                          alignment: Alignment.center,
                          color: Colors.white,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(top: 30, bottom: 20),
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Enter your',
                                            style: GoogleFonts.ubuntu(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 26),
                                          ),
                                          TextSpan(
                                            text: '\nold PIN',
                                            style: GoogleFonts.ubuntu(
                                                color: Colors.green[400],
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.left,
                                    )), //Step number
                                const SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 100),
                                  child: TextField(
                                    cursorHeight: 24,
                                    obscureText: true,
                                    cursorColor: Colors.grey[700],
                                    maxLines: 1,
                                    controller: oldPasscodeController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(6),
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r"\s\b|\b\s"))
                                    ],
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 24,
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Old PIN',
                                      isDense: true,
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      hintStyle: GoogleFonts.ubuntu(
                                        fontSize: 24,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ), //Enter bio
                                const SizedBox(height: 50),
                                Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Set a new',
                                            style: GoogleFonts.ubuntu(
                                                color: Colors.grey[700],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 26),
                                          ),
                                          TextSpan(
                                            text: '\n6 digit PIN',
                                            style: GoogleFonts.ubuntu(
                                                color: Colors.green[400],
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.left,
                                    )),
                                const SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 100),
                                  child: TextField(
                                    cursorHeight: 24,
                                    obscureText: true,
                                    cursorColor: Colors.grey[700],
                                    maxLines: 1,
                                    controller: passcodeController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(6),
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r"\s\b|\b\s"))
                                    ],
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 24,
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'New PIN',
                                      isDense: true,
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      hintStyle: GoogleFonts.ubuntu(
                                        fontSize: 24,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 100),
                                  child: TextField(
                                    cursorHeight: 24,
                                    obscureText: true,
                                    cursorColor: Colors.grey[700],
                                    maxLines: 1,
                                    controller: confirmPasscodeController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(6),
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')),
                                      FilteringTextInputFormatter.deny(
                                          RegExp(r"\s\b|\b\s"))
                                    ],
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.ubuntu(
                                      fontSize: 24,
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Confirm New PIN',
                                      isDense: true,
                                      filled: true,
                                      fillColor: Colors.grey[200],
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      disabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                        borderSide: BorderSide.none,
                                      ),
                                      hintStyle: GoogleFonts.ubuntu(
                                        fontSize: 24,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 40,
                          left: 10,
                          child: IconButton(
                            onPressed: () => goBack(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              size: 40,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
