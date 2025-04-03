// ignore_for_file: non_constant_identifier_names
import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class AchievementsCard extends StatefulWidget {
  const AchievementsCard({Key? key}) : super(key: key);

  @override
  State<AchievementsCard> createState() => _AchievementsCardState();
}

class _AchievementsCardState extends State<AchievementsCard> {
  @override
  void initState() {
    context.read<UserProviderFunctions>().getUserAchievements();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProviderFunctions>(
      builder: (_, value, child) {
        return value.returnTotalAmountEverDeposited() == null
            ? Container(
                width: width(context),
                decoration: cardDeco(),
                alignment: Alignment.center,
                height: height(context) * 0.15,
                child: loadingIcon(context, color: Colors.black),
              )
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Container(
                  padding: EdgeInsets.only(
                      bottom: Platform.isIOS ? 40 : 25,
                      right: 30,
                      left: 30,
                      top: 20),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/trophy-star.png",
                        height: 40,
                        width: 40,
                      ),
                      hGap(10),
                      Text(
                        "Achievements",
                        style: googleStyle(
                          color: Colors.grey[800]!,
                          weight: FontWeight.w600,
                          size: 20,
                        ),
                      ),
                      hGap(30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          achievementWidget(context, {
                            "achievement_type": "Deposits Ever",
                            "achievement_value": value
                                .returnTotalAmountEverDeposited()!
                                .toStringAsFixed(2),
                            "achievement_unit": box("Currency"),
                          }),
                          wGap(10),
                          achievementWidget(context, {
                            "achievement_type": "Saved Ever",
                            "achievement_value": value
                                .returnTotalAmountEverSaved()!
                                .toStringAsFixed(2),
                            "achievement_unit": box("Currency"),
                          }),
                        ],
                      ),
                      hGap(20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          achievementWidget(context, {
                            "achievement_type": "Total Transactions",
                            "achievement_value":
                                value.returnNumOfTotalTransactions(),
                            "achievement_unit": "transactions",
                          }),
                          wGap(10),
                          achievementWidget(context, {
                            "achievement_type": "Days Since Joined",
                            "achievement_value":
                                value.returnNumOfDaysAsAUser(),
                            "achievement_unit": "days",
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}

Widget achievementWidget(BuildContext context, Map body_info) {
  return Container(
    decoration: deco(),
    width: width(context) * 0.4,
    alignment: Alignment.center,
    height: height(context) * 0.1,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          body_info["achievement_type"],
          textAlign: TextAlign.center,
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontSize: 15,
          ),
        ),
        hGap(10),
        Text(
          "${body_info["achievement_value"]} ${body_info["achievement_unit"]}",
          textAlign: TextAlign.center,
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w300,
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
      ],
    ),
  );
}

Decoration cardDeco() {
  return const BoxDecoration(
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(40),
      topLeft: Radius.circular(40),
    ),
    color: Colors.white,
  );
}

Decoration deco() {
  return BoxDecoration(
      color: Colors.grey[100],
      borderRadius: const BorderRadius.all(Radius.circular(20)));
}
