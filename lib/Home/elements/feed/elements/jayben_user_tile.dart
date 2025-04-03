// ignore_for_file: non_constant_identifier_names, must_be_immutable


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';


class JaybenUserTile extends StatelessWidget {
  const JaybenUserTile({super.key, required this.contact_map});

  final Map contact_map;

  @override
  Widget build(BuildContext context) {
    return Consumer<PaymentProviderFunctions>(builder: (_, value, child) {
      return Container(
        width: width(context),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            contact_map["contacts_jayben_account_details"]
                        ["profile_image_url"] ==
                    ""
                ? CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.grey[100],
                    backgroundImage: const AssetImage(
                      "assets/ProfileAvatar.png",
                    ),
                  )
                : CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: CachedNetworkImageProvider(
                      contact_map["contacts_jayben_account_details"]
                          ["profile_image_url"],
                    ),
                  ),
            wGap(15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: width(context) * 0.732,
                  child: Text(
                    contact_map["contacts_display_name"] ?? contact_map["contacts_phone_number"],
                    style: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                ),
                hGap(5),
                Text(
                  "Hi there, I am on Jayben.",
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w300,
                    fontSize: 15,
                  ),
                )
              ],
            ),
            const Spacer(),
            // GestureDetector(
            //   onTap: () async {
            // route user to payment confirmation page
            // changePage(
            //   context,
            //   PaymentConfirmationUsernamePage(
            //     paymentInfo: {
            //       "amount": double.parse(value.returnAmountString()),
            //       "payment_means": "Username",
            //       "receiver_map": contact_map,
            //     },
            //   ),
            // );
            //   },
            //   child: SizedBox(
            //     child: Text(
            //             "SEND",
            //             style: googleStyle(
            //               weight: FontWeight.w400,
            //               color: Colors.orange,
            //               size: 18,
            //             ),
            //           ),
            //   ),
            // )
          ],
        ),
      );
    });
  }
}
