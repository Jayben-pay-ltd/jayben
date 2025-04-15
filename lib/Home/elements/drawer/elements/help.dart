// ignore_for_file: non_constant_identifier_names
import 'package:jayben/Home/elements/drawer/elements/terms_and_conditions_page.dart';
import 'package:jayben/Home/elements/drawer/elements/contact_us.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/ProfileWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  void initState() {
    // if (box("enable_six_digit_pin") != null) {
    //   enable_six_digit_pin = box("enable_six_digit_pin");
    // } else {
    //   boxPut("enable_six_digit_pin", true);
    //   enable_six_digit_pin = true;
    // }
    super.initState();
  }

  bool? enable_six_digit_pin;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                width: width(context),
                height: height(context),
                padding: const EdgeInsets.only(top: 60, left: 10, right: 10),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.call),
                      onTap: () => changePage(context, const ContactUsPage()),
                      title: const Text("Contact Us"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      onTap: () =>
                          changePage(context, const TermsAndConditionsPage()),
                      title: const Text("Privacy Policy"),
                    ),
                  ],
                ),
              ),
              customAppBar(context)
            ],
          ),
        ),
      ),
    );
  }

  Widget customAppBar(BuildContext context) {
    return Positioned(
      top: 0,
      child: Container(
        width: width(context),
        decoration: appBarDeco(),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            wGap(10),
            InkWell(
              onTap: () => goBack(context),
              child: const SizedBox(
                child: Icon(
                  color: Colors.black,
                  Icons.arrow_back,
                  size: 40,
                ),
              ),
            ),
            const Spacer(),
            Text.rich(
              const TextSpan(text: "Need Help?"),
              textAlign: TextAlign.left,
              style: GoogleFonts.ubuntu(
                color: const Color.fromARGB(255, 54, 54, 54),
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const Spacer(),
            wGap(50),
          ],
        ),
      ),
    );
  }
}
