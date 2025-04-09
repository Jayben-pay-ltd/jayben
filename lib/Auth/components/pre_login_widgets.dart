import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Auth/login_page.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Auth/enter_details_step1_page.dart';
import 'package:jayben/Home/elements/drawer/elements/help.dart';

Widget preLoginBody(BuildContext context, Map controllers) {
  return WillPopScope(
    onWillPop: () async => await Future.value(false),
    child: SizedBox(
      width: width(context),
      height: height(context),
      child: Stack(
        children: [
          Container(
            width: width(context),
            height: height(context),
            padding: EdgeInsets.only(top: height(context) * 0.77, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Let's get you started!",
                  textAlign: TextAlign.center,
                  style: googleStyle(
                    weight: FontWeight.w900,
                    color: Colors.black,
                    size: 18,
                  ),
                ),
                const Spacer(),
                Text(
                  "Don't have an account yet?",
                  textAlign: TextAlign.center,
                  style: googleStyle(
                    color: Colors.grey[800]!,
                    weight: FontWeight.w300,
                    size: 14,
                  ),
                ),
                hGap(15),
                signUpButton(context)
              ],
            ),
          ),
          logoWidget(context),
          loginButton(context),
          contactUsButton(context),
        ],
      ),
    ),
  );
}

Widget signUpButton(BuildContext context) {
  return GestureDetector(
    onTap: () => changePage(context, const EnterDetailsStep1Page()),
    // onTap: () async {
    //   print("taaaaaaaaaap");

    //   bool? isUsernameValid = await context
    //       .read<AuthProviderFunctions>()
    //       .checkIfUsernameExists("teeeeee");

    //   if (isUsernameValid!) {
    //     showSnackBar(context, "username is valid", color: Colors.green);
    //     print("username exists");
    //   } else {
    //     showSnackBar(context, "username does not exist", color: Colors.red);
    //     print("username does not exist");
    //   }
    // },
    child: Container(
      width: width(context) * 0.8,
      alignment: Alignment.center,
      decoration: createAccountButtonDeco(),
      padding: const EdgeInsets.symmetric(vertical: 17),
      child: const Text(
        "CREATE ACCOUNT",
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontSize: 13,
        ),
      ),
    ),
  );
}

Widget loginButton(BuildContext context) {
  return Positioned(
    top: 70,
    right: 40,
    child: GestureDetector(
      onTap: () => changePage(context, const LoginPage()),
      child: SizedBox(
        child: Text(
          "LOGIN",
          style: googleStyle(
              weight: FontWeight.w500, color: Colors.green, size: 16),
        ),
      ),
    ),
  );
}

Widget contactUsButton(BuildContext context) {
  return Positioned(
    top: 70,
    left: 40,
    child: GestureDetector(
      onTap: () async {
        changePage(context, const HelpPage());

        context.read<HomeProviderFunctions>().toggleIsLoading();

        await context.read<HomeProviderFunctions>().getContactUsDetails();

        context.read<HomeProviderFunctions>().toggleIsLoading();
      },
      child: SizedBox(
        child: Text(
          "HELP?",
          style: googleStyle(
              weight: FontWeight.w500, color: Colors.white, size: 16),
        ),
      ),
    ),
  );
}

Widget logoWidget(BuildContext context) {
  return Align(
    alignment: Alignment.topCenter,
    child: Container(
      decoration: logoDeco(),
      width: width(context) * 0.97,
      height: height(context) * 0.75,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 40),
      child: Image.asset(
        "assets/logo.png",
        color: Colors.white,
        height: 130,
        width: 130,
      ),
    ),
  );
}

// =================== styling widgets

Decoration createAccountButtonDeco() {
  return const BoxDecoration(
    color: Colors.black,
    borderRadius: BorderRadius.all(
      Radius.circular(50),
    ),
  );
}

Decoration logoDeco() {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.grey[900]!,
        Colors.black,
      ],
    ),
    borderRadius: const BorderRadius.only(
      bottomRight: Radius.circular(50),
      bottomLeft: Radius.circular(50),
    ),
  );
}
