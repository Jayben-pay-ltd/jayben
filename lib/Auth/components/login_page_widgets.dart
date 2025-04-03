import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../Utilities/constants.dart';
import '../../Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import '../../Home/elements/drawer/elements/components/ProfileWidgets.dart';

Widget customLoginAppBar(BuildContext context) {
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
            const TextSpan(text: "Login"),
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

Widget logo() {
  return Center(
    child: Image.asset(
      color: Colors.grey[800],
      "assets/logo_name.png",
      height: 30,
    ),
  );
}

Widget enterDetailsText() {
  return FittedBox(
    child: Text(
      "LOGIN",
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: GoogleFonts.ubuntu(
        fontWeight: FontWeight.bold,
        color: iconColor,
      ),
    ),
  );
}

Widget enterdetailsDescriptionText() {
  return FittedBox(
      child: Text(
          "Enter your login details"
          "\nbelow",
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.ubuntu(
              fontSize: 16, fontWeight: FontWeight.w300, color: iconColor)));
}

Widget emailTextfield(context, controller) {
  return SizedBox(
    width: width(context) * 0.8,
    child: TextField(
      cursorHeight: 24,
      cursorColor: iconColor,
      maxLines: 1,
      autocorrect: false,
      controller: controller,
      enableSuggestions: false,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      inputFormatters: [
        LengthLimitingTextInputFormatter(150),
        FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
      ],
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: 'Email address',
        isDense: true,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(20.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(20.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(20.0),
        ),
        hintStyle: GoogleFonts.ubuntu(
          fontSize: 24,
          color: Colors.grey[500],
        ),
      ),
    ),
  );
}

Widget passwordTextfield(context, controller) {
  return Consumer<AuthProviderFunctions>(builder: (_, value, child) {
    return SizedBox(
      width: width(context) * 0.8,
      child: TextField(
        cursorHeight: 24,
        cursorColor: iconColor,
        maxLines: 1,
        autocorrect: false,
        controller: controller,
        enableSuggestions: false,
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.none,
        obscureText: !value.returnShowLoginPassword(),
        inputFormatters: [
          LengthLimitingTextInputFormatter(150),
          FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
        ],
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: 'Password',
          isDense: true,
          filled: true,
          suffixIcon: GestureDetector(
            onTap: () => value.toggleShowLoginPassword(),
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                color: Colors.grey[600],
                value.returnShowLoginPassword()
                    ? Icons.visibility_off
                    : Icons.visibility,
                size: 25,
              ),
            ),
          ),
          suffixIconColor: Colors.grey[800],
          contentPadding: const EdgeInsets.fromLTRB(50, 15, 0, 15),
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(20.0),
          ),
          hintStyle: GoogleFonts.ubuntu(
            fontSize: 24,
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  });
}

Widget passwordExample(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    width: width(context) * 0.55,
    child: Align(
      alignment: Alignment.center,
      child: Text(
        "must be at least 9 characters",
        style: GoogleFonts.ubuntu(
            color: iconColor, fontWeight: FontWeight.w300, fontSize: 12),
      ),
    ),
  );
}

Widget actionButton(BuildContext context, passwordController, emailController) {
  return ChangeNotifierProvider(
    create: (_) => AuthProviderFunctions(),
    builder: (context, child) {
      return Builder(
        builder: (context) {
          return Consumer<AuthProviderFunctions>(
            builder: (context, value, child) {
              return GestureDetector(
                onTap: () async {
                  if (value.returnIsLoading()) return;

                  if (passwordController.text.length < 8 ||
                      emailController.text.isEmpty) {
                    showSnackBar(context,
                        'Enter both an email address and a 9 or more character password to login');

                    return;
                  }

                  hideKeyboard();

                  value.toggleIsLoading();

                  await value.signInWithEmailAndPassword(context, {
                    "password": passwordController.text.trim(),
                    "email": emailController.text.trim()
                  });

                  value.toggleIsLoading();
                },
                child: Container(
                  width: 190,
                  height: 50,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: value.returnIsLoading()
                      ? loadingIcon(context)
                      : Text(
                          "Login",
                          style: GoogleFonts.ubuntu(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                ),
              );
            },
          );
        },
      );
    },
  );
}
