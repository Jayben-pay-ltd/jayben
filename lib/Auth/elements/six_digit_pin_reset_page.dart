import 'package:jayben/Home/elements/drawer/elements/contact_us.dart';
import 'package:jayben/Auth/elements/six_digit_pin_page.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class PinResetPage extends StatefulWidget {
  const PinResetPage({Key? key}) : super(key: key);

  @override
  _PinResetPageState createState() => _PinResetPageState();
}

class _PinResetPageState extends State<PinResetPage> {
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Consumer<AuthProviderFunctions>(
        builder: (_, value, child) {
          return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () async {
                if (value.returnIsLoading()) return;

                if (emailController.text.isEmpty) {
                  showSnackBar(context, "Enter an email address");

                  return;
                }

                value.toggleIsLoading();

                bool email_already_exists = await context
                    .read<AuthProviderFunctions>()
                    .checkIfEmailExists(emailController.text);

                value.toggleIsLoading();

                if (!email_already_exists) {
                  showSnackBar(context, 'Incorrect Email, please try again.');

                  return;
                }

                changePage(context, const PasscodePage(), type: "pr");

                showSnackBar(context, 'PIN has been sent to your Email.');

                // sends user reset PIN email
                bool is_reset = await context
                    .read<AuthProviderFunctions>()
                    .resetPIN("1234");
              },
              backgroundColor: Colors.grey[800],
              label: value.returnIsLoading()
                  ? loadingIcon(context)
                  : const Text("Send PIN Reset email"),
            ),
            backgroundColor: Colors.white,
            body: WillPopScope(
              child: Stack(
                children: [
                  Container(
                    width: width(context),
                    color: Colors.white,
                    height: height(context),
                    alignment: Alignment.center,
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
                                  text: 'Enter your email 🤔\n',
                                  style: GoogleFonts.ubuntu(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 26,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      box("obscured_email"),
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
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(right: 90),
                          child: TextField(
                            cursorHeight: 24,
                            cursorColor: Colors.grey[700],
                            maxLines: 1,
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(300),
                              FilteringTextInputFormatter.deny(
                                  RegExp(r"\s\b|\b\s"))
                            ],
                            textAlign: TextAlign.left,
                            style: GoogleFonts.ubuntu(
                              fontSize: 24,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w300,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Email',
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
                                fontSize: 24,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        hGap(20),
                        GestureDetector(
                          onTap: () =>
                              changePage(context, const ContactUsPage()),
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
                                  Icons.call_rounded,
                                  size: 20,
                                ),
                                wGap(5),
                                Text(
                                  "Contact Support?",
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
                  backButton(context)
                ],
              ),
              onWillPop: () async {
                goBack(context);
                return false;
              },
            ),
          );
        },
      ),
    );
  }
}
