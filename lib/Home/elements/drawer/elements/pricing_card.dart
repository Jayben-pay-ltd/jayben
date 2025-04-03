// ignore_for_file: non_constant_identifier_names
import 'package:jayben/Home/elements/transactions/components/home_transaction_tile.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PricingCard extends StatefulWidget {
  const PricingCard({Key? key}) : super(key: key);

  @override
  State<PricingCard> createState() => _PricingCardState();
}

class _PricingCardState extends State<PricingCard> {
  @override
  Widget build(BuildContext context) {
    double withdrawFeeCapAmount =
        double.parse("${box("WithdrawFeeCapAmount")}");

    double WithdrawFeeCapThresholdAmountKwacha =
        double.parse("${box("WithdrawFeeCapThresholdAmountKwacha")}");

    double withdrawFeePercent = double.parse("${box("WithdrawFeePercent")}");
    return SizedBox(
      width: width(context),
      child: Container(
        padding: EdgeInsets.only(
            bottom: Platform.isIOS ? 40 : 25, right: 30, left: 30, top: 20),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/dollar.png",
              height: 40,
              width: 40,
            ),
            hGap(10),
            Text(
              "Our Withdraw Fees",
              style: googleStyle(
                color: Colors.grey[800]!,
                weight: FontWeight.w600,
                size: 20,
              ),
            ),
            hGap(10),
            Text(
              "You only get charged when withdrawing.",
              style: googleStyle(
                color: Colors.grey[800]!,
                weight: FontWeight.w300,
                size: 12,
              ),
            ),
            hGap(30),
            Container(
              alignment: Alignment.center,
              width: width(context) * 0.9,
              decoration: detailsPreviewDeco(),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        "For amounts between K1 - K${WithdrawFeeCapThresholdAmountKwacha.toStringAsFixed(0)}",
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w300,
                          fontSize: 13.5,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${withdrawFeePercent.toStringAsFixed(1)}% fee",
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  hGap(15),
                  Row(
                    children: [
                      Text(
                        "For amounts larger than K${WithdrawFeeCapThresholdAmountKwacha.toStringAsFixed(0)}",
                        style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w300,
                          fontSize: 13.5,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "K${withdrawFeeCapAmount.toStringAsFixed(1)} flat fee",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: 12.5,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            hGap(30),
          ],
        ),
      ),
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
