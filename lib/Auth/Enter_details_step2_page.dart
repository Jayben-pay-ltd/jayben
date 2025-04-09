// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'components/Enter_details_step2_page_widgets.dart';

class EnterDetailsStep2Page extends StatefulWidget {
  const EnterDetailsStep2Page({super.key, required this.userInfo});

  final Map userInfo;

  @override
  State<EnterDetailsStep2Page> createState() => _EnterDetailsStep2PageState();
}

class _EnterDetailsStep2PageState extends State<EnterDetailsStep2Page> {
  final password_confirm_controller = TextEditingController();
  final referral_code_controller = TextEditingController();
  final password_controller = TextEditingController();
  final email_controller = TextEditingController();

  @override
  void dispose() {
    context.read<AuthProviderFunctions>().stopLoading();
    password_confirm_controller.dispose();
    password_controller.dispose();
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

            if (email_controller.text.isEmpty) {
              showSnackBar(context, 'Enter an Email Address');

              return;
            }

            if (!EmailValidator.validate(email_controller.text)) {
              showSnackBar(context, "Enter a valid email address");

              return;
            }

            if (password_controller.text.length < 8 ||
                password_confirm_controller.text.length < 8) {
              showSnackBar(
                  context, 'Both passwords must 9 characters or more.');

              return;
            }

            // if the pins do not match
            if (password_confirm_controller.text != password_controller.text) {
              showSnackBar(context, "Passwords don't match");

              return;
            }

            // if a referral code has been entered
            if (referral_code_controller.text.isNotEmpty) {
              if (referral_code_controller.text == "Jayben" ||
                  referral_code_controller.text == "jayben" ||
                  referral_code_controller.text == "JAYBEN") {
                showSnackBar(context,
                    "You cannot use 'Jayben' as a referral code. Please try another referral username.");

                return;
              }

              // if user entered their own username
              if (referral_code_controller.text.toLowerCase().trim() ==
                  widget.userInfo["username"].toLowerCase()) {
                showSnackBar(context,
                    "You cannot use your own username as a referral code. Please try another referral username.");

                return;
              }

              value.toggleIsLoading();

              // 1). checks if the referral code/username exists
              bool is_referral_code_valid = await value.checkIfReferralCodeIsValid(
                  referral_code_controller.text.trim());
              // returns a bool value

              value.toggleIsLoading();

              if (!is_referral_code_valid) {
                showSnackBar(context,
                    "The referral username is invalid. Please try another referral username.");

                return;
              }
            }

            value.toggleIsLoading();

            // checks if the email entered by user exists
            bool email_already_exists =
                await value.checkIfEmailExists(email_controller.text.trim());

            value.toggleIsLoading();

            // if the username has been used already
            if (email_already_exists) {
              showSnackBar(context,
                  "Email address has been used for another account. Please use another email address.");

              return;
            }

            value.toggleIsLoading();

            // verifies the pin provided by user
            // then creates the user account in DB
            await value.createUserWithEmailAndPassword(context, {
              "referral_code": referral_code_controller.text.trim(),
              "password": password_controller.text.trim(),
              "email": email_controller.text.trim(),
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
                          emailTextField(email_controller),
                          hGap(30),
                          passwordTextField(password_controller),
                          hGap(30),
                          passwordConfirmTextField(password_confirm_controller),
                          hGap(30),
                          Divider(color: Colors.grey[600]),
                          hGap(15),
                          whoReferedYouText(context),
                          hGap(20),
                          referralCodeTextfield(referral_code_controller),
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
