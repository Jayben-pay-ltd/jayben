import 'package:jayben/Home/elements/deposit_money/deposit_money_to_wallet_page.dart';
import 'package:jayben/Home/elements/buy_airtime/buy_airtime_page.dart';
import 'package:jayben/Home/elements/send_money/send_money_page.dart';
import 'package:jayben/Home/elements/qr_scanner/scan_page.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/nfc/nfc_tags.dart';
import '../elements/withdraw_money/withdraw_page.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:io';

Widget cashierCard(BuildContext context) {
  return SizedBox(
    width: width(context),
    child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          topLeft: Radius.circular(40),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: Platform.isIOS ? 40 : 25,
          right: 30,
          left: 30,
          top: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => changePage(context, const AirtimePage()),
                  child: SizedBox(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundColor: Colors.grey[100],
                          child: Image.asset(
                            "assets/smartphones.png",
                            height: 29,
                          ),
                        ),
                        hGap(5),
                        Text(
                          "Airtime",
                          style: googleStyle(
                            color: const Color(0xFF616161),
                            weight: FontWeight.w400,
                            size: 15,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                wGap(20),
                // GestureDetector(
                //   onTap: () => changePage(context, const AirtimePage()),
                //   child: SizedBox(
                //     child: Column(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         CircleAvatar(
                //           radius: 27,
                //           backgroundColor: Colors.grey[100],
                //           child: Image.asset(
                //             "assets/lightning.png",
                //             color: const Color.fromARGB(255, 246, 170, 49),
                //             height: 27,
                //           ),
                //         ),
                //         hGap(5),
                //         Text(
                //           "Zesco",
                //           style: googleStyle(
                //             color: const Color(0xFF616161),
                //             weight: FontWeight.w400,
                //             size: 15,
                //           ),
                //         )
                //       ],
                //     ),
                //   ),
                // ),
                const Spacer(),
                GestureDetector(
                  onTap: () => changePage(context, const NfcTagsPage()),
                  child: SizedBox(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundColor: Colors.grey[100],
                          child: Image.asset(
                            "assets/credit-card (1).png",
                            height: 39,
                          ),
                        ),
                        hGap(5),
                        Text(
                          "Cards",
                          style: googleStyle(
                            color: const Color(0xFF616161),
                            weight: FontWeight.w400,
                            size: 15,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 40,
                  child: VerticalDivider(
                    color: Colors.grey[400],
                    thickness: 0.4,
                  ),
                ),
                GestureDetector(
                  onTap: () => changePage(context, const QRScannerPage()),
                  child: SizedBox(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 27,
                          backgroundColor: Colors.grey[200],
                          child: Image.asset(
                            "assets/qr.png",
                            height: 25,
                          ),
                        ),
                        hGap(5),
                        Text(
                          "Scan",
                          style: googleStyle(
                            color: const Color(0xFF616161),
                            weight: FontWeight.w400,
                            size: 15,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            hGap(10),
            Divider(
              color: Colors.grey[300],
              thickness: 0.5,
            ),
            hGap(15),
            // GestureDetector(
            //   onTap: () => changePage(context, const SendGiftPage()),
            //   child: Container(
            //     color: Colors.white,
            //     margin: const EdgeInsets.only(bottom: 20),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.start,
            //       children: [
            //         CircleAvatar(
            //           radius: 23,
            //           backgroundColor: Colors.grey[200],
            //           child: Image.asset(
            //             'assets/gift-box.png',
            //             height: 22,
            //             width: 22,
            //           ),
            //         ),
            //         const SizedBox(width: 10),
            //         Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               "Gift",
            //               style: GoogleFonts.ubuntu(
            //                 color: const Color(0xFF616161),
            //                 fontWeight: FontWeight.bold,
            //                 fontSize: 20,
            //               ),
            //             ),
            //             hGap(2),
            //             Text(
            //               "Send to friends",
            //               style: GoogleFonts.ubuntu(
            //                 color: Colors.grey[600],
            //                 fontSize: 15,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // GestureDetector(
            //   onTap: () => changePage(context, const USSDPage()),
            //   child: Platform.isIOS
            //       ? nothing()
            //       : Container(
            //           color: Colors.white,
            //           margin: const EdgeInsets.only(bottom: 20),
            //           child: Row(
            //             mainAxisAlignment: MainAxisAlignment.start,
            //             children: [
            //               CircleAvatar(
            //                 radius: 23,
            //                 backgroundColor: Colors.grey[200],
            //                 child: Image.asset(
            //                   'assets/hashtag.png',
            //                   height: 22,
            //                   width: 22,
            //                 ),
            //               ),
            //               const SizedBox(width: 10),
            //               Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Text(
            //                     "Dial it",
            //                     style: GoogleFonts.ubuntu(
            //                       color: const Color(0xFF616161),
            //                       fontWeight: FontWeight.bold,
            //                       fontSize: 20,
            //                     ),
            //                   ),
            //                   hGap(2),
            //                   Text(
            //                     "Run USSD shortcuts automatically",
            //                     style: GoogleFonts.ubuntu(
            //                       color: Colors.grey[600],
            //                       fontSize: 15,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ],
            //           ),
            //         ),
            // ),
            GestureDetector(
              onTap: () => changePage(context, const SendMoneyByUsername()),
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 23,
                      backgroundColor: Colors.grey[200],
                      child: Image.asset(
                        'assets/send.png',
                        height: 25,
                        width: 25,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Send",
                          style: GoogleFonts.ubuntu(
                            color: const Color(0xFF616161),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        hGap(2),
                        Text(
                          "to friends & family",
                          style: GoogleFonts.ubuntu(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            hGap(20),
            GestureDetector(
              onTap: () => changePage(context, const DepositPage()),
              child: Container(
                color: Colors.white,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 23,
                      backgroundColor: Colors.grey[200],
                      child: Image.asset(
                        "assets/deposit.png",
                        height: 25,
                        width: 25,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Deposit",
                          style: GoogleFonts.ubuntu(
                            color: const Color(0xFF616161),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        hGap(2),
                        Text(
                          "into your Jayben wallet",
                          style: GoogleFonts.ubuntu(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            hGap(20),
            GestureDetector(
              onTap: () => changePage(context, const WithdrawalPage()),
              child: Container(
                color: Colors.white,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 23,
                      backgroundColor: Colors.grey[200],
                      child: Image.asset(
                        "assets/money-withdrawal.png",
                        height: 22,
                        width: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Withdraw",
                          style: GoogleFonts.ubuntu(
                            color: const Color(0xFF616161),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        hGap(2),
                        Text(
                          "to Airtel, MTN or Zamtel Money",
                          style: GoogleFonts.ubuntu(
                            color: Colors.grey[600],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
