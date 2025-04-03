import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'components/Enter_details_step2_page_widgets.dart';

class EnterDetailsStep2Page extends StatefulWidget {
  const EnterDetailsStep2Page({Key? key, required this.userInfo})
      : super(key: key);

  final Map userInfo;

  @override
  State<EnterDetailsStep2Page> createState() => _EnterDetailsStep2PageState();
}

class _EnterDetailsStep2PageState extends State<EnterDetailsStep2Page> {
  final passwordConfirmController = TextEditingController();
  final referralCodeController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void dispose() {
    passwordConfirmController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderFunctions>(
      builder: (_, value, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: floatingActionButtonWidgetStep2(() async {
            if (value.returnIsLoading()) return;

            hideKeyboard();

            if (emailController.text.isEmpty) {
              showSnackBar(context, 'Enter an Email Address');

              return;
            }

            if (!EmailValidator.validate(emailController.text)) {
              showSnackBar(context, "Enter a valid email address");

              return;
            }

            if (passwordController.text.length < 8 ||
                passwordConfirmController.text.length < 8) {
              showSnackBar(
                  context, 'Both passwords must 9 characters or more.');

              return;
            }

            // if the pins do not match
            if (passwordConfirmController.text != passwordController.text) {
              showSnackBar(context, "Passwords don't match");

              return;
            }

            // if a referral code has been entered
            if (referralCodeController.text.isNotEmpty) {
              if (referralCodeController.text == "Jayben" ||
                  referralCodeController.text == "jayben" ||
                  referralCodeController.text == "JAYBEN") {
                showSnackBar(context,
                    "You cannot use 'Jayben' as a referral code. Please try another referral username.");

                return;
              }

              // if user entered their own username
              if (referralCodeController.text.toLowerCase().trim() ==
                  widget.userInfo["username"].toLowerCase()) {
                showSnackBar(context,
                    "You cannot use your own username as a referral code. Please try another referral username.");

                return;
              }

              value.toggleIsLoading();

              // 1). checks if the referral code/username exists
              bool isReferralCodeValid = await value.checkIfReferralCodeIsValid(
                  referralCodeController.text.trim());
              // returns a bool value

              value.toggleIsLoading();

              if (!isReferralCodeValid) {
                showSnackBar(context,
                    "The referral username is invalid. Please try another referral username.");

                return;
              }
            }

            value.toggleIsLoading();

            // checks if the email entered by user exists
            bool isEmailValid =
                await value.checkIfEmailExists(emailController.text.trim());

            value.toggleIsLoading();

            // if the username has been used already
            if (!isEmailValid) {
              showSnackBar(context,
                  "Email address has been used for another account. Please use another email address.");

              return;
            }

            value.toggleIsLoading();

            // verifies the pin provided by user
            // then creates the user account in DB
            await value.createUserWithEmailAndPassword(context, {
              "referralCode": referralCodeController.text.trim(),
              "password": passwordController.text.trim(),
              "email": emailController.text.trim(),
              ...widget.userInfo,
            });
            // then routes user to home page
          }),
          body: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => hideKeyboard(),
                  child: SizedBox(
                    width: width(context),
                    height: height(context),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 70, bottom: 80),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          stepCounterWidget(),
                          hGap(10),
                          enterDetialsText(),
                          hGap(10),
                          requiredTextWidget(),
                          hGap(30),
                          emailTextField(emailController),
                          hGap(30),
                          passwordTextField(passwordController),
                          hGap(30),
                          passwordConfirmTextField(passwordConfirmController),
                          hGap(30),
                          Divider(color: Colors.grey[600]),
                          hGap(15),
                          whoReferedYouText(context),
                          hGap(20),
                          referralCodeTextfield(referralCodeController),
                        ],
                      ),
                    ),
                  ),
                ),
                customAppBar(context)
              ],
            ),
          ),
        );
      },
    );
  }
}
