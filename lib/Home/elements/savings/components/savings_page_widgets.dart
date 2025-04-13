// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/savings/elements/components/create_shared_no_access_account_dialogue.dart';

Widget createSavingsAccountWidget(BuildContext context) {
  return Consumer<HomeProviderFunctions>(
    builder: (_, value, child) {
      double amount = value.returnTotalSavingsBalance();
      return Container(
        // color: Colors.red,
        width: width(context),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Total Savings",
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    text: "${box("currency")} ",
                    children: [
                      TextSpan(
                        text: amount < 100000.0
                            ? amount.toStringAsFixed(2)
                            : (amount >= 100000.0 && amount < 1000000.0
                                ? "${amount.toStringAsFixed(2)[0]}${amount.toStringAsFixed(2)[1]}${amount.toStringAsFixed(2)[2]}k"
                                : (amount > 1000000.0 && amount < 10000000.0
                                    ? "${amount.toStringAsFixed(2)[0]}.${amount.toStringAsFixed(2)[1]}${amount.toStringAsFixed(2)[2]} M"
                                    : (amount > 10000000.0 &&
                                            amount < 100000000.0
                                        ? "${amount.toStringAsFixed(2)[0]}${amount.toStringAsFixed(2)[1]}.${amount.toStringAsFixed(2)[2]}${amount.toStringAsFixed(2)[3]} M"
                                        : "${amount.toStringAsFixed(2)[0]}${amount.toStringAsFixed(2)[1]}${amount.toStringAsFixed(2)[2]}.${amount.toStringAsFixed(2)[3]}${amount.toStringAsFixed(2)[4]} M"))),
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 26,
                        ),
                      )
                    ],
                  ),
                  style: GoogleFonts.ubuntu(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                )
              ],
            ),
            wGap(20),
            GestureDetector(
              onTap: () => showDialogue(
                  context, const CreateSharedNoAccessAccountDialogue()),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "New Account",
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                        fontSize: 18,
                      ),
                    ),
                    wGap(8),
                    Icon(
                      Icons.add,
                      color: Colors.orange[700],
                      size: 30,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget accountTypeFilterWidget(BuildContext context) {
  return Consumer2<SavingsProviderFunctions, HomeProviderFunctions>(
    builder: (_, value, value1, child) {
      return Container(
        width: width(context),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                value.changeSavingsFilterIndex(0);

                await Future.wait([
                  value1.loadDetailsToHive(context),
                  value1.getHomeTransactions(),
                  value1.getHomeSavingsAccounts(),
                  value1.updateNotificationToken(),
                ]);
              },
              child: Container(
                height: 30,
                width: 150,
                alignment: Alignment.center,
                decoration: accountFilterDeco(
                    value.returnCurrentSavingsFilterIndex(), 0),
                child: Text(
                  "My Accounts",
                  style: googleStyle(
                    weight: FontWeight.w400,
                    color: value.returnCurrentSavingsFilterIndex() == 0
                        ? Colors.white
                        : Colors.grey[900]!,
                    size: 15,
                  ),
                ),
              ),
            ),
            wGap(15),
            GestureDetector(
              onTap: () async {
                value.changeSavingsFilterIndex(1);

                await Future.wait([
                  value1.loadDetailsToHive(context),
                  value1.getHomeTransactions(),
                  value1.getHomeSavingsAccounts(),
                  value1.updateNotificationToken(),
                ]);
              },
              child: Container(
                width: 150,
                height: 30,
                alignment: Alignment.center,
                decoration: accountFilterDeco(
                    value.returnCurrentSavingsFilterIndex(), 1),
                child: Text(
                  "Top 20 Accounts",
                  style: googleStyle(
                    weight: FontWeight.w400,
                    color: value.returnCurrentSavingsFilterIndex() == 1
                        ? Colors.white
                        : Colors.grey[900]!,
                    size: 15,
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

Widget loadingWidget(BuildContext context) {
  return Container(
    width: width(context),
    color: Colors.transparent,
    height: height(context) * 0.5,
    child: Center(
      child: CircularProgressIndicator(
        color: Colors.grey[700],
        strokeWidth: 2,
      ),
    ),
  );
}

// ======== styling widgets

Decoration accountFilterDeco(int current_filter_index, int index) {
  return BoxDecoration(
    color: current_filter_index == index ? Colors.black : Colors.grey[200],
    borderRadius: const BorderRadius.all(
      Radius.circular(40),
    ),
  );
}

Decoration homeSavingsBodyDeco() {
  return const BoxDecoration(
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(40),
      topLeft: Radius.circular(40),
    ),
  );
}
