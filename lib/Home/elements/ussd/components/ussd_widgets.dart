// ignore_for_file: non_constant_identifier_names

import 'package:jayben/Home/elements/ussd/components/choose_sim_card.dart';
import 'package:jayben/Home/elements/ussd/components/edit_shortcut.dart';
import 'package:jayben/Home/elements/drawer/elements/Settings.dart';
import 'package:jayben/Home/elements/ussd/new_ussd_shortcut.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/General_widgets.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

Widget ussdBody(BuildContext context) {
  return SizedBox(
    width: width(context),
    height: height(context),
    child: Stack(
      children: [
        body(context),
        customAppBar(context),
      ],
    ),
  );
}

Widget customAppBar(BuildContext context) {
  return Consumer<ReferralProviderFunctions>(
    builder: (_, value, child) {
      return Positioned(
        top: 0,
        child: Container(
          width: width(context),
          decoration: appBarDeco(),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(bottom: 0, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
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
                    const TextSpan(text: "USSD Shortcuts"),
                    textAlign: TextAlign.left,
                    style: GoogleFonts.ubuntu(
                      color: const Color.fromARGB(255, 54, 54, 54),
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async =>
                        changePage(context, const NewUSSDShortcutPage()),
                    child: const Icon(
                      color: Colors.black,
                      Icons.add,
                      size: 40,
                    ),
                  ),
                  wGap(10),
                ],
              ),
              hGap(20),
              Container(
                width: width(context),
                alignment: Alignment.center,
                child: Container(
                  height: 50,
                  width: width(context) * 0.9,
                  decoration: tabWidgetDeco(),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => value.changeIndex(0),
                        child: Container(
                          width: width(context) * 0.43,
                          color: value.returnCurrentIndex() == 1
                              ? Colors.transparent
                              : Colors.white,
                          alignment: Alignment.center,
                          child: Text(
                            "USSD Codes",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: value.returnCurrentIndex() == 1
                                  ? Colors.grey[600]!
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      wGap(5),
                      GestureDetector(
                        onTap: () => value.changeIndex(1),
                        child: Container(
                          width: width(context) * 0.43,
                          color: value.returnCurrentIndex() == 0
                              ? Colors.transparent
                              : Colors.white,
                          alignment: Alignment.center,
                          child: Text(
                            "How To Setup",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: value.returnCurrentIndex() == 0
                                  ? Colors.grey[600]!
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

Widget body(BuildContext context) {
  return Consumer<ReferralProviderFunctions>(
    builder: (_, value, child) {
      return value.returnIsLoading()
          ? loadingScreenPlainNoBackButton(context)
          : value.returnCurrentIndex() == 0
              ? ussdCodesWidget(context)
              : howToSetupWidget(context);
    },
  );
}

Widget ussdCodesWidget(BuildContext context) {
  return Consumer<UssdProviderFunctions>(builder: (_, value, child) {
    return value.returnListOfShorcuts() == null
        ? loadingScreenPlainNoBackButton(context)
        : Stack(
            children: [
              Container(
                width: width(context),
                height: height(context),
                alignment: Alignment.center,
                child: box("list_of_ussd_shortcuts").isEmpty
                    ? ussdShortcutExampleWidget(context)
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: box("list_of_ussd_shortcuts").length,
                        padding: const EdgeInsets.only(top: 120),
                        itemBuilder: (_, i) => shortcutTile(
                          box("list_of_ussd_shortcuts")[i],
                          context,
                        ),
                      ),
              ),
              disablePinWidget(context)
            ],
          );
  });
}

Widget shortcutTile(Map shortcut, BuildContext context) {
  return Consumer<UssdProviderFunctions>(
    builder: (_, value, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListTile(
          onTap: () =>
              changePage(context, EditShortcutPage(shortcut_map: shortcut)),
          title: Text(
            shortcut["shortcut_name"],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: googleStyle(
              weight: FontWeight.w400,
              color: Colors.black,
              size: 15,
            ),
          ),
          subtitle: Text(
            shortcut["shortcut"],
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: googleStyle(
              color: Colors.black54,
              size: 15,
            ),
          ),
          trailing: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)),
              ),
              backgroundColor: MaterialStateProperty.all(Colors.black),
            ),
            onPressed: () async {
              try {
                showBottomCard(context, ChooseSimCard(shortcut_map: shortcut));
              } on Exception catch (e) {
                showSnackBar(context,
                    "An error occured: $e. If issue persists, please contact customer support.",
                    duration: 10);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
              child: Text(
                "Run Shortcut",
                style: GoogleFonts.ubuntu(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget ussdShortcutExampleWidget(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    width: height(context) * 0.8,
    padding: const EdgeInsets.only(bottom: 30),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          "assets/hashtag.png",
          height: 80,
        ),
        hGap(20),
        Text(
          "Create USSD shortcuts to automatically\n"
          "buy you stuff like ikali data bundles,\nAll Net Voice Minutes etc...",
          textAlign: TextAlign.center,
          style: googleStyle(
            weight: FontWeight.w300,
            color: Colors.black,
            size: 18,
          ),
        ),
        hGap(20),
        codeExample(context),
        hGap(25),
        createShortcutButton(context)
      ],
    ),
  );
}

Widget codeExample(BuildContext context) {
  return Container(
    width: width(context),
    alignment: Alignment.center,
    decoration: exampleCodeDeco(),
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
    child: Text(
      "An example of a USSD Shortcut is: \n\n*117# > Option 1 > Option 2 > 1234 (Mobile Money PIN)",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey[900]),
    ),
  );
}

Widget createShortcutButton(BuildContext context) {
  return ElevatedButton(
    style: ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
      backgroundColor: MaterialStateProperty.all(Colors.black),
    ),
    onPressed: () => changePage(context, const NewUSSDShortcutPage()),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
      child: Text(
        "Create a USSD Shortcut",
        style: GoogleFonts.ubuntu(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    ),
  );
}

Widget howToSetupWidget(BuildContext context) {
  return Consumer<UssdProviderFunctions>(
    builder: (_, value, child) {
      return Container(
        width: width(context),
        height: height(context),
        padding: const EdgeInsets.only(top: 120),
        child: RepaintBoundary(
          child: ListView(
            shrinkWrap: true,
            addRepaintBoundaries: true,
            physics: const BouncingScrollPhysics(),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  hGap(10),
                  stepTextWidget(
                      context, "Step 1: Accept Calls/Phone Permissions"),
                  hGap(20),
                  imageWidget(context, 350, "calls_permission"),
                  hGap(30),
                  stepTextWidget(context,
                      "Step 2: Goto Phone Settings, then select Accessibility"),
                  hGap(20),
                  imageWidget(context, 350, "accessibility"),
                  hGap(30),
                  stepTextWidget(context,
                      "Step 3: Inside Accessibility, select Installed services"),
                  hGap(20),
                  imageWidget(context, 350, "installed_services"),
                  hGap(30),
                  stepTextWidget(
                      context, "Step 4: Select Jayben (at the bottom)"),
                  hGap(20),
                  imageWidget(context, 390, "select_jayben"),
                  hGap(20),
                  stepTextWidget(
                      context, "Step 5: Enable the USSD Jayben Permission"),
                  hGap(20),
                  imageWidget(context, 390, "enable_permission"),
                  hGap(20),
                  usageDisclaimer(
                      context,
                      "(By enabling this Permission, Jayben will\n only be able to run"
                      " USSD shortcuts, and nothing else. No data is collected and/or"
                      " shared from Accessibility)."),
                  hGap(20),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}

Widget usageDisclaimer(BuildContext context, String step_text) {
  return SizedBox(
    width: width(context) * 0.8,
    child: Text(
      step_text,
      maxLines: 4,
      textAlign: TextAlign.center,
      style: GoogleFonts.ubuntu(
        fontWeight: FontWeight.w500,
        color: Colors.black,
        fontSize: 14,
      ),
    ),
  );
}

Widget stepTextWidget(BuildContext context, String step_text) {
  return SizedBox(
    width: width(context) * 0.8,
    child: Text(
      step_text,
      maxLines: 4,
      textAlign: TextAlign.center,
      style: GoogleFonts.ubuntu(
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.w500,
        color: Colors.green,
        fontSize: 22,
      ),
    ),
  );
}

Widget imageWidget(BuildContext context, double height, String image) {
  return Container(
    decoration: instructionImageDeco(),
    width: width(context) * 0.885,
    alignment: Alignment.center,
    height: height,
    child: Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Image.asset(
            "assets/$image.png",
            width: double.infinity,
            fit: BoxFit.cover,
            height: double.infinity,
          ),
        ),
      ],
    ),
  );
}

Widget disablePinWidget(BuildContext context) {
  return box("list_of_ussd_shortcuts").isEmpty
      ? nothing()
      : box("enable_six_digit_pin") != null && !box("enable_six_digit_pin")
          ? nothing()
          : Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () => changePage(context, const SettingsPage()),
                child: Container(
                  height: 80,
                  width: width(context),
                  color: Colors.white,
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                  child: const Text(
                    "*Disable 6 Digit PIN in settings to use USSD Shortcuts WITHOUT INTERNET.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            );
}

// =============== Styling widgets

Decoration exampleCodeDeco() {
  return BoxDecoration(
    color: Colors.grey[200],
  );
}

Decoration instructionImageDeco() {
  return BoxDecoration(
    color: Colors.grey[200],
    borderRadius: const BorderRadius.all(
      Radius.circular(30),
    ),
  );
}

Decoration tabWidgetDeco() {
  return BoxDecoration(
    color: Colors.grey[200],
    borderRadius: const BorderRadius.all(
      Radius.circular(5),
    ),
  );
}

Decoration customDecor() {
  return BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 1,
        blurRadius: 7,
        offset: const Offset(0, 3),
      ),
    ],
    borderRadius: const BorderRadius.all(
      Radius.circular(50),
    ),
  );
}

Decoration appBarDeco() {
  return BoxDecoration(
    color: Colors.white,
    border: Border(
      bottom: BorderSide(
        color: Colors.grey[200]!,
        width: 0.5,
      ),
    ),
  );
}
