import '../../../Home/elements/drawer/elements/components/ProfileWidgets.dart';
import '../../../Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

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
            const TextSpan(text: "Change Account Email"),
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

Widget forgotPasswordDetailText() {
  return FittedBox(
    child: Text(
      "Reset Email",
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey[500],
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget forgotPasswordDetailsDescriptionText() {
  return FittedBox(
    child: Text(
      "Enter new account email & "
      "\nyour existing password below,"
      "\nemail you use to login"
      "\nwill be changed.",
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.w300,
        color: Colors.grey[500],
        fontSize: 16,
      ),
    ),
  );
}

Widget updateAccountEmailAddress(void Function()? onSendLinkPress) {
  return ElevatedButton(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.green),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    ),
    onPressed: onSendLinkPress,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15),
      child: Consumer<AuthProviderFunctions>(
        builder: (_, value, child) {
          return value.returnIsLoading()
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  "Update Email",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                );
        },
      ),
    ),
  );
}
