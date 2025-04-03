// ignore_for_file: non_constant_identifier_names
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:jayben/Auth/pre_login.dart';
import 'package:jayben/Home/elements/timeline_privacy_settings/timeline_privacy_settings.dart';
import 'package:jayben/Home/elements/drawer/elements/kyc_verification.dart';
import 'package:jayben/Auth/elements/account_deletion_dialogue.dart';
import 'package:jayben/Home/elements/drawer/elements/Profile.dart';
import 'package:jayben/Auth/elements/forgot_password_page.dart';
import '../../../../Auth/elements/change_account_email.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'components/ProfileWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  bool? enable_six_digit_pin;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Container(
                width: width(context),
                height: height(context),
                padding: const EdgeInsets.only(top: 60, left: 10, right: 10),
                child: Column(
                  children: [
                    // ListTile(
                    //   title: const Text(
                    //     "Enable 6 Digit PIN",
                    //     style: TextStyle(
                    //       fontWeight: FontWeight.w400,
                    //     ),
                    //   ),
                    //   trailing: CupertinoSwitch(
                    //     value: enable_six_digit_pin!,
                    //     onChanged: (bool? value) {
                    //       setState(() {
                    //         boxPut("enable_six_digit_pin", value);
                    //         enable_six_digit_pin = value;
                    //       });
                    //     },
                    //   ),
                    // ),
                    // const Divider(),
                    // ListTile(
                    //     leading: const Icon(Icons.lock),
                    //     onTap: () => changePage(context, const ChangePINPage()),
                    //     title: const Text("Change 6 Digit PIN")),
                    ListTile(
                        leading: const Icon(Icons.person_2),
                        onTap: () => changePage(context, const ProfilePage()),
                        title: const Text("Edit Profile")),
                    !box("Timeline")
                        ? nothing()
                        : ListTile(
                            leading: const Icon(Icons.remove_red_eye),
                            onTap: () => changePage(
                                context, const TimelinePrivacySettingsPage()),
                            title: const Text("Timeline Privacy")),
                    ListTile(
                        leading: const Icon(Icons.verified_sharp),
                        onTap: () =>
                            changePage(context, const KycVerificationPage()),
                        title: const Text("KYC Verification")),
                    ListTile(
                        leading: const Icon(Icons.alternate_email_outlined),
                        onTap: () =>
                            changePage(context, const ChangeAccountEmail()),
                        title: const Text("Change Account Email")),
                    ListTile(
                        leading: const Icon(Icons.password),
                        onTap: () =>
                            changePage(context, const ForgotPassword()),
                        title: const Text("Change Password")),
                    ListTile(
                        leading: const Icon(Icons.delete),
                        onTap: () => showDialogue(
                            context, const AccountDeletionDialogue()),
                        title: const Text("Delete Account")),
                    ListTile(
                      leading: const Icon(
                        color: Colors.red,
                        Icons.logout,
                      ),
                      title: Text(
                        'Log Out',
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      onTap: () async {
                        // await _auth.signOut();

                        if (box("user_id") == null) return;

                        changePage(context, const PreLoginPage(), type: "pr");

                        boxDelete("is_logged_in");

                        boxDelete("user_id");

                        showSnackBar(context, "You have been Logged Out",
                            color: Colors.grey[700]!);

                        await clearAllProviderVariables();
                      },
                    ),
                  ],
                ),
              ),
              customAppBar(context),
              Positioned(
                bottom: 0,
                child: GestureDetector(
                  onTap: () => showSnackBar(
                    context,
                    "The people crazy enough to believe they can change the world, "
                    "are often the ones that do. \n\n- Steve Jobs",
                    color: const Color.fromARGB(255, 166, 124, 40),
                    duration: 10,
                  ),
                  child: Container(
                    width: width(context),
                    alignment: Alignment.center,
                    height: height(context) * 0.09,
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Jayben Technologies Zambia Limited",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ubuntu(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        hGap(5),
                        Text(
                          "Version ${context.read<AuthProviderFunctions>().returnBuildVersion()}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ubuntu(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // clears all the variables in all
  // provider classes that were all stored
  clearAllProviderVariables() {
    context.read<HomeProviderFunctions>().clearAllVariables();
    context.read<AuthProviderFunctions>().clearAllVariables();
    context.read<SavingsProviderFunctions>().clearAllVariables();
    context.read<PaymentProviderFunctions>().clearAllVariables();
    context.read<DepositProviderFunctions>().clearAllVariables();
    context.read<WithdrawProviderFunctions>().clearAllVariables();
    context.read<QRScannerProviderFunctions>().clearAllVariables();
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
              const TextSpan(text: "Settings"),
              textAlign: TextAlign.left,
              style: GoogleFonts.ubuntu(
                color: const Color.fromARGB(255, 54, 54, 54),
                fontWeight: FontWeight.bold,
                fontSize: 30,
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
