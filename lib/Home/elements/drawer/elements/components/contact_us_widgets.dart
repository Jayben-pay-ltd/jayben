// ignore_for_file: non_constant_identifier_names
import 'ProfileWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

Widget aboutUsAppBar(BuildContext context) {
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
            const TextSpan(text: "Contact Us"),
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

Widget contactUsWidget(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        "assets/logo_name.png",
        color: Colors.green,
        height: 100,
        width: 160,
      ),
      SizedBox(
        width: width(context) * 0.8,
        child: Text(
          "Owned and operated by \nJayben Technologies Zambia\nLimited. "
          "\n\nA Registered Entity in the Republic Of Zambia."
          "\n\nCompany Number: 120230058802",
          textAlign: TextAlign.center,
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w300,
            color: Colors.grey[800],
            fontSize: 18,
          ),
        ),
      ),
      hGap(20),
      Divider(
        color: Colors.grey[300]!,
      ),
      hGap(10),
      Text(
        "Customer Support Information",
        textAlign: TextAlign.center,
        style: googleStyle(
          weight: FontWeight.w700,
          color: Colors.black,
          size: 20,
        ),
      ),
      hGap(10),
      Divider(
        color: Colors.grey[300]!,
      ),
      hGap(20),
      selectContactTypeWidget(context),
      hGap(20),
      contactWidget(context),
    ],
  );
}

Widget selectContactTypeWidget(BuildContext context) {
  return Consumer<UserProviderFunctions>(builder: (_, value, child) {
    return SizedBox(
      width: width(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => value.changeCurrentContactType("WhatsApp"),
            child: Container(
              width: 90,
              height: 40,
              alignment: Alignment.center,
              decoration: contactTypeDeco(),
              child: Text(
                "WhatsApp",
                style: googleStyle(
                  weight: value.returnCurrentContactType() == "WhatsApp"
                      ? FontWeight.w800
                      : FontWeight.w300,
                  color: Colors.black,
                  size: 13,
                ),
              ),
            ),
          ),
          wGap(20),
          GestureDetector(
            onTap: () => value.changeCurrentContactType("Calls/Text"),
            child: Container(
              width: 90,
              height: 40,
              alignment: Alignment.center,
              decoration: contactTypeDeco(),
              child: Text(
                "Calls/Text",
                style: googleStyle(
                  weight: value.returnCurrentContactType() == "Calls/Text"
                      ? FontWeight.w800
                      : FontWeight.w300,
                  color: Colors.black,
                  size: 13,
                ),
              ),
            ),
          ),
          wGap(20),
          GestureDetector(
            onTap: () => value.changeCurrentContactType("Email"),
            child: Container(
              width: 90,
              height: 40,
              alignment: Alignment.center,
              decoration: contactTypeDeco(),
              child: Text(
                "Email",
                style: googleStyle(
                  weight: value.returnCurrentContactType() == "Email"
                      ? FontWeight.w800
                      : FontWeight.w300,
                  color: Colors.black,
                  size: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  });
}

Widget contactWidget(BuildContext context) {
  return Consumer<UserProviderFunctions>(builder: (_, value, child) {
    return Container(
      alignment: Alignment.center,
      width: width(context) * 0.87,
      decoration: customerSupportDeco(),
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width(context),
            child: Text(
              value.returnCurrentContactType() == "Calls/Text"
                  ? "Calls & Text"
                  : value.returnCurrentContactType() == "WhatsApp"
                      ? "WhatsApp Line"
                      : "Email Address",
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 18,
              ),
            ),
          ),
          hGap(20),
          SizedBox(
            width: width(context),
            child: Text(
              value.returnCurrentContactType() == "Calls/Text"
                  ? "${box("JaybenHotline")}\n${box("JaybenSecondaryHotLine")}"
                  : value.returnCurrentContactType() == "WhatsApp"
                      ? "wa.me/${box("JaybenWhatsAppLine").replaceAll("+", "")}"
                      : box("JaybenEmailAddress"),
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                color: Colors.grey[500],
                fontSize: 20,
              ),
            ),
          ),
          hGap(20),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.green),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            ),
            onPressed: () async {
              if (value.returnCurrentContactType() == "WhatsApp") {
                final _url = Uri.parse(
                    "https://wa.me/${box("JaybenWhatsAppLine").replaceAll("+", "")}");
                if (!await launchUrl(_url,
                    mode: LaunchMode.externalApplication)) {
                  showSnackBar(context, 'Could not open $_url');
                }
                return;
              }

              if (value.returnCurrentContactType() == "Calls/Text" ||
                  value.returnCurrentContactType() == "Email") {
                await Clipboard.setData(ClipboardData(
                    text: value.returnCurrentContactType() == "Calls/Text"
                        ? "${box("JaybenSecondaryHotLine")} ${box("JaybenHotline")}"
                        : box("JaybenEmailAddress")));

                showSnackBar(context, "Copied", color: Colors.green);

                return;
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  value.returnCurrentContactType() == "WhatsApp"
                      ? const Icon(
                          Icons.link_rounded,
                          color: Colors.white,
                          size: 25,
                        )
                      : value.returnCurrentContactType() == "Email"
                          ? const Icon(
                              Icons.email,
                              color: Colors.white,
                              size: 25,
                            )
                          : const Icon(
                              Icons.copy,
                              color: Colors.white,
                              size: 18,
                            ),
                  const SizedBox(width: 10),
                  Text(
                    value.returnCurrentContactType() == "Calls/Text"
                        ? "Copy Line"
                        : value.returnCurrentContactType() == "WhatsApp"
                            ? "Open WhatsApp"
                            : "Copy Email Address",
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w400,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  });
}

Widget faqBody(BuildContext context) {
  return Container(
    width: width(context),
    padding: const EdgeInsets.only(bottom: 20),
    child: RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Frequently Asked Questions",
            textAlign: TextAlign.center,
            style: googleStyle(
              weight: FontWeight.w700,
              color: Colors.black,
              size: 20,
            ),
          ),
          hGap(10),
          Divider(
            color: Colors.grey[300]!,
          ),
          hGap(20),
          questionWidget(
              context,
              "How long are withdrawals?",
              "Each withdrawal submitted is investigated & processed manually "
                  "for anti-money laundering purposes. The average withdrawal time is 2 minutes."
                  "\n\nHowever if any concerns are raised during the investigation, the withrawal time may take upto 24 hours."),
          questionWidget(
              context,
              "Why do we have to verify our accounts before withdrawing money?",
              "KYC (Know Your Customer) Verification is required by Bank Of Zambia (BOZ) for all financial institutions operating in the Republic Of Zambia."
                  "\n\nIt is also required for compliance purposes being anti-fraud & anti-money laundering purposes."),
          questionWidget(
              context,
              "How long are KYC Verification reviews?",
              "Each verification submitted is investigated & processed manually "
                  "for anti-fraud & anti-money laundering purposes. The average verification review time is 5 - 10 minutes."
                  "\n\nHowever if any concerns are raised during the investigation, the verification review time may take upto 24 hours."),
          questionWidget(
              context,
              "Do you charge any fees?",
              "The only fee we charge is a small withdraw fee of ${box("WithdrawFeePercent") ?? 3.5} percent when withdrawing money from your Jayben Wallet to your Mobile Money wallet. \n\nWe currently do"
                  " not charge for deposits, in-app wallet to wallet transactions, or deposits & withdraws to and from No Access Savings (NAS) Accounts."),
          questionWidget(
              context,
              "Can I access money deposited in my NAS accounts inadvance?",
              "No. You can only access money deposited into No Access Savings (NAS) accounts, "
                  "when the number of days you chose have clocked."),
          questionWidget(
              context,
              "Does Jayben use the money we deposit in our wallets and NAS accounts?",
              "No. We do not use any money deposited into your wallets or your No Access Savings Accounts."),
          questionWidget(
              context,
              "Do NAS accounts pay interest?",
              "No! No Access Savings (NAS) accounts do not pay interest. They are soley exist only to "
                  "lock money away and give it back to you when you need it"),
          questionWidget(
              context,
              "What is the maximum and minimum deposit amount for NAS accounts?",
              "There is no maximum amount you can deposit into a No Access Savings (NAS) account. \n\nHowever, the "
                  "minimum amount that can be deposited into a No Access Savings (NAS) account is ${box("Currency") ?? "ZMW"} 1"),
          questionWidget(
              context,
              "What is the maximum and minimum period for NAS accounts?",
              "The maximum period you can set for No Access Savings (NAS) accounts is 9,999 days. \n\nThe "
                  "minimum period that you can set for No Access Savings (NAS) accounts is 1 day"),
          questionWidget(
              context,
              "How to withdraw money from my wallet when the app is down?",
              "You will need to contact customer support and they can guide you on how to withdraw your money during outages."),
          questionWidget(context, "How do we know the app requires an update?",
              "Usually you will receive a notification telling you an update is available. But if you have auto-update turned on, your app will automatically update itself."),
          questionWidget(
              context,
              "How do I gain Points & what can I use them for?",
              "Currently Points have been deactivated. Points can be used to purchase airtime only."),
          questionWidget(
              context,
              "What do I do if I send or withdraw money to the wrong person or phone number?",
              "Contact customer support and they will help you as best as they can to reverse the transaction. "
                  "Please note, you will have to contact customer support as soon as you can if this happens."),
        ],
      ),
    ),
  );
}

Widget questionWidget(
    BuildContext context, String question_text, String answer_text) {
  return RepaintBoundary(
    child: Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 20),
      child: ExpandedTile(
        theme: ExpandedTileThemeData(
          contentBackgroundColor: Colors.white,
          headerColor: Colors.grey[100]!,
        ),
        controller: ExpandedTileController(isExpanded: false),
        title: Text(
          question_text,
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w400,
            color: Colors.grey[700],
            fontSize: 20,
          ),
        ),
        content: Container(
          width: width(context),
          color: Colors.white,
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(bottom: 10, left: 10),
          child: Text(
            answer_text,
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w400,
              color: Colors.grey[500],
              fontSize: 18,
            ),
          ),
        ),
      ),
    ),
  );
}

// ================== styling widgets

Decoration contactTypeDeco() {
  return BoxDecoration(
    color: Colors.grey[200],
    borderRadius: const BorderRadius.all(
      Radius.circular(10),
    ),
  );
}

Decoration customerSupportDeco() {
  return BoxDecoration(
    color: Colors.grey[100],
    borderRadius: const BorderRadius.all(
      Radius.circular(10),
    ),
  );
}
