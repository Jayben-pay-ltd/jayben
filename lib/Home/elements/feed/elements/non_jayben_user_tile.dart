// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class NonJaybenUserTile extends StatelessWidget {
  const NonJaybenUserTile({super.key, required this.contact_map});

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
            CircleAvatar(
              radius: 27,
              backgroundColor: Colors.grey[300],
              backgroundImage: const AssetImage(
                "assets/ProfileAvatar.png",
              ),
            ),
            wGap(15),
            SizedBox(
              width: width(context) * 0.5,
              child: Text(
                contact_map["contacts_display_name"] ?? contact_map["contacts_phone_number"],
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {},
              child: SizedBox(
                child: Text(
                  "Invite",
                  style: googleStyle(
                    weight: FontWeight.w400,
                    color: Colors.orange,
                    size: 18,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
