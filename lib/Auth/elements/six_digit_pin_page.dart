// ignore_for_file: non_constant_identifier_names
import 'package:jayben/Home/elements/savings/elements/join_shared_nas_account_card.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:jayben/Auth/elements/six_digit_pin_reset_page.dart';
import '../../Home/elements/legal/account_restricted_page.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../Home/home_page.dart';
import 'dart:io';

class PasscodePage extends StatefulWidget {
  const PasscodePage({Key? key}) : super(key: key);

  @override
  _PasscodePageState createState() => _PasscodePageState();
}

class _PasscodePageState extends State<PasscodePage> {
  @override
  void initState() {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      if (!mounted) return;

      showBottomCard(
          context,
          JoinSharedNasAccountCard(
              account_id: dynamicLinkData.link.queryParameters["id"]!));
    }).onError((error) {
      showSnackBar(context, "An error ocurred trying to open link");
    });

    onPageLaunch();
    super.initState();
  }

  Future<void> onPageLaunch() async {
    // queries the user's PIN and OnHold values
    await context.read<HomeProviderFunctions>().loadDetailsToHive();

    // 1). decrypts the encrypted user pin
    // 2). pretty much intended to get the reset email and store it
    List<dynamic> result = await Future.wait([
      // context.read<AuthProviderFunctions>().decryptPin(box("PIN")),
      context.read<AuthProviderFunctions>().processResetEmail()
    ]);

    if (!mounted) return;

    setState(() => decrypted_pin = result[0]);
  }

  @override
  void dispose() {
    passcodeController.dispose();
    decrypted_pin = "";
    super.dispose();
  }

  final passcodeController = TextEditingController();
  String decrypted_pin = "";

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProviderFunctions>(
      builder: (_, value, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: WillPopScope(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => hideKeyboard(),
                    child: Container(
                      color: Colors.white,
                      width: width(context),
                      height: height(context),
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: box("FirstName") == null
                                        ? "Hi there 👋"
                                        : 'Hi ${box("FirstName")} 👋',
                                    style: GoogleFonts.ubuntu(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                      fontSize: 26,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '\nenter your 6 digit PIN',
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
                          hGap(30),
                          RepaintBoundary(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 100),
                              child: TextField(
                                cursorHeight: 24,
                                obscureText: true,
                                maxLines: 1,
                                controller: passcodeController,
                                cursorColor: Colors.grey[700],
                                onChanged: (String text) async {
                                  if (text.length < 6) return;

                                  hideKeyboard();

                                  if (decrypted_pin.isEmpty) {
                                    showSnackBar(context,
                                        'Check your internet connection');

                                    return;
                                  }

                                  // waits for keyboard to fylly dismiss
                                  await Future.delayed(
                                      const Duration(milliseconds: 200));

                                  if (decrypted_pin !=
                                      passcodeController.text.trim()) {
                                    showSnackBar(context,
                                        'Invalid PIN, please try again');

                                    return;
                                  }

                                  // if account is restricted
                                  if (box("OnHold")) {
                                    changePage(
                                        context, const PendingApprovalPage(),
                                        type: "pr");

                                    return;
                                  }

                                  // routes user to the home page
                                  changePage(context, const HomePage(),
                                      type: "pr");

                                  await value.updateNotificationToken();
                                  // updates the notification token
                                  // incase it has changed
                                },
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
                                  fontSize: 30,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w300,
                                ),
                                decoration: InputDecoration(
                                  hintText: '6 Digit PIN',
                                  isDense: true,
                                  filled: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(20, 12, 0, 12),
                                  fillColor: Colors.grey[200],
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        bottomRight: Radius.circular(20)),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        bottomRight: Radius.circular(20)),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        bottomRight: Radius.circular(20)),
                                    borderSide: BorderSide.none,
                                  ),
                                  disabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        bottomRight: Radius.circular(20)),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintStyle: GoogleFonts.ubuntu(
                                    color: Colors.grey[700],
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          hGap(20),
                          GestureDetector(
                            onTap: () =>
                                changePage(context, const PinResetPage()),
                            child: Container(
                              width: width(context),
                              color: Colors.white,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(
                                  left: 20, top: 5, bottom: 10),
                              child: Row(
                                children: [
                                  Icon(
                                    color: Colors.grey[500],
                                    Icons.lock_rounded,
                                    size: 20,
                                  ),
                                  wGap(5),
                                  Text(
                                    "Forgot PIN?",
                                    style: GoogleFonts.ubuntu(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.grey[700],
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  loadingWidget(context)
                ],
              ),
              onWillPop: () async {
                Navigator.pop(context);
                return false;
              },
            ),
          ),
        );
      },
    );
  }

  Widget loadingWidget(BuildContext context) {
    return Positioned(
      left: 20,
      top: Platform.isIOS ? 60 : 40,
      child: decrypted_pin.isNotEmpty
          ? nothing()
          : Container(
              height: 20,
              width: 20,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                color: Colors.green,
                strokeWidth: 2,
              ),
            ),
    );
  }
}
