// ignore_for_file: non_constant_identifier_names
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/General_widgets.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

Widget referralsBody(BuildContext context) {
  return SizedBox(
    width: width(context),
    height: height(context),
    child: Stack(
      children: [
        body(context),
        customAppBar(context),
        floatingSettings(context),
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
          padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
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
                    const TextSpan(text: "Referrals"),
                    textAlign: TextAlign.left,
                    style: GoogleFonts.ubuntu(
                      color: const Color.fromARGB(255, 54, 54, 54),
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      value.toggleIsLoading();

                      await Future.wait([
                        value.getMyReferralCommissions(),
                        context
                            .read<HomeProviderFunctions>()
                            .loadDetailsToHive()
                      ]);

                      value.toggleIsLoading();
                    },
                    child: const Icon(
                      color: Colors.black,
                      Icons.refresh,
                      size: 30,
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
                            "Analytics",
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
                            "Commissions",
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
      return value.returnReferralCommissions() == null ||
              value.returnIsLoading()
          ? loadingScreenPlainNoBackButton(context)
          : value.returnCurrentIndex() == 0
              ? myReferralCodePage(context)
              : commissionsListBuilder(context);
    },
  );
}

Widget myReferralCodePage(BuildContext context) {
  return Consumer<ReferralProviderFunctions>(builder: (_, value, child) {
    return Container(
      width: width(context),
      height: height(context),
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
        width: height(context) * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/earnings.png",
              height: 100,
            ),
            hGap(20),
            Text(
              "Earn upto ${box("ReferralCommissionPercentage")}% from each deposit"
              "\nyour friends make starting today!",
              textAlign: TextAlign.center,
              style: googleStyle(
                weight: FontWeight.w400,
                color: Colors.green[900]!,
                size: 19,
              ),
            ),
            hGap(10),
            Text(
              "simply ask them to enter your referral code as a\nreferrer when they are signing up!",
              textAlign: TextAlign.center,
              style: googleStyle(
                weight: FontWeight.w300,
                color: Colors.black54,
                size: 15,
              ),
            ),
            hGap(20),
            appDownloadtLinkWidget(context),
            hGap(20),
            Text(
              value.returnNumberOfPeopleReferred() == 1
                  ? "You have referred"
                      "\n1 friend so far 🥳"
                  : "You have referred"
                      "\n${value.returnNumberOfPeopleReferred()} friends so far 🥳",
              textAlign: TextAlign.center,
              style: googleStyle(
                weight: FontWeight.w300,
                color: Colors.black,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  });
}

Widget commissionsListBuilder(BuildContext context) {
  return Consumer<ReferralProviderFunctions>(
    builder: (_, value, child) {
      return value.returnReferralCommissions()!.isEmpty
          ? const Center(child: Text("No commissions paid yet"))
          : SizedBox(
              width: width(context),
              height: height(context),
              child: RefreshIndicator(
                onRefresh: () async {
                  await value.getMyReferralCommissions();
                },
                displacement: 140,
                child: MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  removeBottom: true,
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    itemCount: value.returnReferralCommissions()!.length,
                    padding: const EdgeInsets.only(top: 120, bottom: 120),
                    itemBuilder: (_, index) {
                      Map ds = value.returnReferralCommissions()![index];
                      var amount = double.parse(ds['amount'].toString());
                      return Container(
                        width: width(context),
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        color: const Color.fromARGB(255, 251, 246, 217),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: Row(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ds["method"]),
                                hGap(5),
                                SizedBox(
                                  width: width(context) * 0.5,
                                  child: Text(
                                    "${ds["description"]}",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                hGap(5),
                                Text(
                                  ds["status"],
                                  style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.bold,
                                    color: ds["status"] == "Pending"
                                        ? Colors.orange[700]
                                        : ds["status"] == "Completed"
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "+ ${ds["currency"]} ${amount.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                hGap(5),
                                Row(
                                  children: [
                                    Text(
                                      DateFormat.yMMMd().format(
                                        DateTime.parse(
                                          ds["created_at"],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      " - ${DateFormat.Hm().format(DateTime.parse(ds["created_at"]).toUtc().toLocal())}",
                                    )
                                  ],
                                ),
                                hGap(5),
                                Text(
                                  ds['transaction_type'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
    },
  );
}

Widget appDownloadtLinkWidget(BuildContext context) {
  return Consumer<SavingsProviderFunctions>(builder: (_, value, child) {
    return GestureDetector(
      onTap: () async {
        hideKeyboard();

        value.toggleIsLoading();

        // generates a join link
        String link = await context
            .read<ReferralProviderFunctions>()
            .generateAppDownloadLink();

        value.toggleIsLoading();

        // copies link to clipboard
        await Clipboard.setData(ClipboardData(text: link));

        showSnackBar(context, "App Download Link Copied",
            color: Colors.green[600]!);
      },
      child: Container(
        width: width(context) * 0.6,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          height: 50,
          width: width(context),
          alignment: Alignment.center,
          decoration: appDownloadLinkDeco(),
          child: value.returnIsLoading()
              ? loadingIcon(context)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      color: Colors.white,
                      Icons.link,
                      size: 22,
                    ),
                    wGap(15),
                    Text(
                      "Invite friends via Link",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    wGap(15),
                    const Icon(
                      color: Colors.white,
                      Icons.copy,
                      size: 17,
                    ),
                  ],
                ),
        ),
      ),
    );
  });
}

Widget floatingSettings(BuildContext context) {
  return Positioned(
    bottom: 50,
    child: GestureDetector(
      onTap: () async {
        await Clipboard.setData(
            ClipboardData(text: box("username_searchable")));

        showSnackBar(context, "Referral Code Copied");
      },
      child: Container(
        width: width(context),
        alignment: Alignment.center,
        child: Container(
          height: 50,
          decoration: customDecor(),
          alignment: Alignment.center,
          width: width(context) * 0.8,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              referralCode(context),
              copyCode(context),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget referralCode(BuildContext context) {
  return Consumer<ReferralProviderFunctions>(
    builder: (_, value, child) {
      return GestureDetector(
        onTap: () async {
          await Clipboard.setData(
              ClipboardData(text: box("username_searchable")));

          showSnackBar(context, "Referral Code Copied");
        },
        child: const SizedBox(
          child: Text(
            "My Referral Code:",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ),
      );
    },
  );
}

Widget copyCode(BuildContext context) {
  return Consumer<ReferralProviderFunctions>(
    builder: (_, value, child) {
      return GestureDetector(
        onTap: () async {
          await Clipboard.setData(
              ClipboardData(text: box("username_searchable")));

          showSnackBar(context, "Referral Code Copied");
        },
        child: SizedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                box("username_searchable"),
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[800]!,
                  fontSize: 17,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.copy,
                color: Colors.grey[800]!,
                size: 17,
              ),
            ],
          ),
        ),
      );
    },
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
  );
}
