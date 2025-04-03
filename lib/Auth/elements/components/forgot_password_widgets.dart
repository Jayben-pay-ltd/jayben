import '../../../Home/elements/drawer/elements/components/ProfileWidgets.dart';
import '../../../Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../forgot_password_page.dart';

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
            const TextSpan(text: "Reset Password"),
            textAlign: TextAlign.left,
            style: GoogleFonts.ubuntu(
              color: const Color.fromARGB(255, 54, 54, 54),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          wGap(50),
        ],
      ),
    ),
  );
}

Widget forgotPasswordButton(context) {
  return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (builder) => const ForgotPassword()));
      },
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15),
          child: Text("Forgot Password?",
              style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w300,
                  fontSize: 17,
                  color: Colors.black))));
}

Widget forgotPasswordDetailText() {
  return FittedBox(
      child: Text(
    "Reset Password",
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.center,
    style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold),
  ));
}

Widget forgotPasswordDetailsDescriptionText() {
  return FittedBox(
      child: Text(
          "Enter your account email below,"
          "\nreset link will be sent"
          "\nto your email.",
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.grey[500])));
}

Widget sendForgotPasswordLink(void Function()? onSendLinkPress) {
  return ElevatedButton(
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.green),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ))),
      onPressed: onSendLinkPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15),
        child:
            Consumer<AuthProviderFunctions>(builder: (context, value, child) {
          return value.returnIsLoading()
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                    backgroundColor: Colors.transparent,
                  ),
                )
              : const Text("Send link",
                  style: TextStyle(
                    fontSize: 20,
                  ),);
        },),
      ),);
}
