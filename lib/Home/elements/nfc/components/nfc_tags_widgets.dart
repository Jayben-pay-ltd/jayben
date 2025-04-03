// ignore_for_file: non_constant_identifier_names
import 'package:jayben/Home/elements/transactions/all_transactions_page.dart';
import 'package:jayben/Home/elements/nfc/create_pin_bottom_card.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/General_widgets.dart';
import '../elements/nfc_transactions_widget.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


Widget tagsBody(BuildContext context) {
  return SizedBox(
    width: width(context),
    height: height(context),
    child: Stack(
      children: [
        body(context),
        customAppBar(context),
        addCardFloatingWidget(context),
      ],
    ),
  );
}

Widget customAppBar(BuildContext context) {
  return Consumer<NfcProviderFunctions>(
    builder: (_, value, child) {
      return Positioned(
        top: 0,
        child: Stack(
          children: [
            Container(
              width: width(context),
              decoration: appBarDeco(),
              alignment: Alignment.center,
              padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
              child: Text(
                "Cards",
                textAlign: TextAlign.center,
                style: GoogleFonts.ubuntu(
                  color: const Color.fromARGB(255, 54, 54, 54),
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 5,
              child: InkWell(
                onTap: () => goBack(context),
                child: const SizedBox(
                  child: Icon(
                    color: Colors.black,
                    Icons.arrow_back,
                    size: 40,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 5,
              child: GestureDetector(
                onTap: () => showCupertinoModalPopup(
                  builder: (_) => const CreatePinBottomCard(),
                  context: context,
                ),
                child: SizedBox(
                  child: Text(
                    "New Card",
                    style: googleStyle(size: 19, color: Colors.green),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget body(BuildContext context) {
  return Consumer<NfcProviderFunctions>(
    builder: (_, value, child) {
      return value.returnListOfTags() == null || value.returnIsLoading()
          ? loadingScreenPlainNoBackButton(context)
          : Container(
              width: width(context),
              height: height(context),
              alignment: Alignment.center,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 46),
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      cardPreviewWidget(context),
                      hGap(10),
                      viewMoreMoreTransactionsTopWidget(context),
                      hGap(20),
                      const NfcTransactionTile()
                    ],
                  ),
                ],
              ),
            );
    },
  );
}

Widget cardPreviewWidget(BuildContext context) {
  return Consumer<NfcProviderFunctions>(
    builder: (_, value, child) {
      Map current_tag_map =
          value.returnListOfTags()![value.returnCurrentCardIndex()];
      return Container(
        width: width(context),
        color: Colors.grey[200],
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 20, bottom: 25),
        child: Column(
          children: [
            SizedBox(
              height: height(context) * 0.25,
              child: value.returnListOfTags()!.isEmpty
                  ? Text(
                      "No cards linked yet",
                      textAlign: TextAlign.center,
                      style: googleStyle(),
                    )
                  : tagTile(
                      context,
                      current_tag_map,
                    ),
            ),
            optionsRowWidget(context, current_tag_map),
            cardSelectorWidget(context)
          ],
        ),
      );
    },
  );
}

Widget optionsRowWidget(BuildContext context, Map tag_info) {
  return Container(
    width: width(context),
    alignment: Alignment.center,
    padding: const EdgeInsets.only(top: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        minimalListButton("ADD MONEY", Icons.add),
        wGap(15),
        minimalListButton("RESET PIN", Icons.refresh),
      ],
    ),
  );
}

Widget minimalListButton(String text, IconData icon) {
  return Container(
    width: 150,
    height: 40,
    alignment: Alignment.center,
    decoration: minimalistButtonDeco(),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.black87,
          size: 18,
        ),
        wGap(5),
        Text(
          text,
          style: googleStyle(
            weight: FontWeight.w400,
            size: 15),
        ),
      ],
    ),
  );
}

Widget cardSelectorWidget(BuildContext context) {
  return Consumer<NfcProviderFunctions>(builder: (_, value, child) {
    return value.returnListOfTags()!.length < 2
        ? nothing()
        : Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Stack(
              children: [
                Container(
                  height: 21,
                  width: width(context),
                  alignment: Alignment.center,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (var i = 0; i < value.returnListOfTags()!.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: CircleAvatar(
                            backgroundColor: value.returnCurrentCardIndex() == i
                                ? Colors.black
                                : Colors.black26,
                            radius: value.returnCurrentCardIndex() == i ? 6 : 4.5,
                          ),
                        )
                    ],
                  ),
                ),
                value.returnCurrentCardIndex() == 0
                    ? nothing()
                    : Positioned(
                        left: 20,
                        child: GestureDetector(
                          onTap: () {
                            if (value.returnCurrentCardIndex() == 0) {
                              return;
                            }
        
                            value.changeCurrentCardIndex(
                                value.returnCurrentCardIndex() - 1);
                          },
                          child: Container(
                            width: 150,
                            color: Colors.transparent,
                            alignment: Alignment.centerLeft,
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                value.returnCurrentCardIndex() ==
                        value.returnListOfTags()!.length - 1
                    ? nothing()
                    : Positioned(
                        right: 20,
                        child: GestureDetector(
                          onTap: () {
                            if (value.returnCurrentCardIndex() ==
                                value.returnListOfTags()!.length - 1) {
                              return;
                            }
        
                            value.changeCurrentCardIndex(
                                value.returnCurrentCardIndex() + 1);
                          },
                          child: Container(
                            width: 150,
                            color: Colors.transparent,
                            alignment: Alignment.centerRight,
                            child: const RotatedBox(
                              quarterTurns: 2,
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
        );
  });
}

Widget viewMoreMoreTransactionsTopWidget(BuildContext context) {
  return Container(
    width: width(context),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Transactions",
          textAlign: TextAlign.right,
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w400,
            color: Colors.grey[700],
            fontSize: 15,
          ),
        ),
        GestureDetector(
          onTap: () => changePage(context, const AllTransactionsPage()),
          child: SizedBox(
            child: Text(
              "View All",
              textAlign: TextAlign.right,
              style: GoogleFonts.ubuntu(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w400,
                color: Colors.orange[700],
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget tagTile(BuildContext context, Map tag_info) {
  return Stack(
    children: [
      Container(
        decoration: tagTileDeco(),
        width: width(context) * 0.9,
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            text: tag_info["currency"],
            children: [
              TextSpan(
                text: tag_info["balance"] == 0
                    ? " 0.00"
                    : " ${tag_info["balance"].toStringAsFixed(2)}",
                style: GoogleFonts.ubuntu(
                  color: Colors.white,
                  fontSize: 30,
                ),
              )
            ],
          ),
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      Positioned(
        top: 15,
        left: 15,
        child: Shimmer.fromColors(
          baseColor: Colors.white,
          period: const Duration(milliseconds: 3000),
          highlightColor: const Color.fromARGB(255, 137, 137, 137),
          child: Image.asset(
            "assets/logo_name.png",
            height: 20,
          ),
        ),
      ),
      Positioned(
        top: 15,
        right: 15,
        child: Text(
          "*NFC only card",
          style: googleStyle(
            weight: FontWeight.w400,
            color: Colors.white,
            size: 10,
          ),
        ),
      ),
      Positioned(
        bottom: 15,
        left: 15,
        child: Text(
          tag_info["tag_name"].toUpperCase(),
          style: googleStyle(
            weight: FontWeight.w400,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      Positioned(
        bottom: 15,
        right: 15,
        child: Container(
          color: Colors.transparent,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.close,
                color: Colors.orange,
                size: 19,
              ),
              wGap(2),
              Text(
                "Freeze",
                style: googleStyle(
                  weight: FontWeight.w400,
                  color: Colors.orange,
                  size: 15,
                ),
              )
            ],
          ),
        ),
      ),
    ],
  );
}

Widget addCardFloatingWidget(BuildContext context) {
  return Positioned(
    bottom: 50,
    child: GestureDetector(
      onTap: () => showCupertinoModalPopup(
        builder: (_) => const CreatePinBottomCard(),
        context: context,
      ),
      child: Container(
        width: width(context),
        alignment: Alignment.center,
        child: Container(
          height: 50,
          decoration: customDecor(),
          alignment: Alignment.center,
          width: width(context) * 0.8,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "More card settings",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[800]!,
                    fontSize: 15,
                  ),
                ),
                wGap(10),
                Icon(
                  Icons.settings,
                  color: Colors.green[400]!,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// ================= styling widgets

Decoration appDownloadLinkDeco() {
  return BoxDecoration(
    color: Colors.green[700]!,
    borderRadius: const BorderRadius.all(
      Radius.circular(20),
    ),
  );
}

Decoration minimalistButtonDeco() {
  return const BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(
      Radius.circular(20),
    ),
  );
}

Decoration tagTileDeco() {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Colors.grey[800]!,
        Colors.black,
      ],
    ),
    borderRadius: const BorderRadius.all(
      Radius.circular(20),
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
  return const BoxDecoration(
    color: Colors.white,
    // border: Border(
    //   bottom: BorderSide(
    //     color: Colors.black,
    //     width: 0.2,
    //   ),
    // ),
  );
}
