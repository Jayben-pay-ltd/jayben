// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/savings/elements/components/edit_nas_account_dialogue.dart';
import 'package:jayben/Home/elements/savings/elements/components/extend_shared_nas_account_card.dart';

class SharedNasAccountMenuCard extends StatefulWidget {
  const SharedNasAccountMenuCard({super.key, required this.account_map});

  final Map account_map;

  @override
  State<SharedNasAccountMenuCard> createState() =>
      _SharedNasAccountMenuCardState();
}

class _SharedNasAccountMenuCardState extends State<SharedNasAccountMenuCard> {
  bool is_loading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width(context),
      child: is_loading
          ? Container(
              width: width(context),
              decoration: cardDeco(),
              alignment: Alignment.center,
              height: height(context) * 0.15,
              child: loadingIcon(context, color: Colors.black),
            )
          : SizedBox(
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
                      GestureDetector(
                        onTap: () async => showDialogue(
                          context,
                          EditExistinNasAccountNameDialogue(
                            account_map: widget.account_map,
                          ),
                        ),
                        child: Container(
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 23,
                                backgroundColor: Colors.grey[200],
                                child: Image.asset(
                                  'assets/edit.png',
                                  height: 25,
                                  width: 25,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Edit Name",
                                    style: GoogleFonts.ubuntu(
                                      color: const Color(0xFF616161),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Change the existing account name",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.grey[600],
                                      fontSize: 13,
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
                        onTap: () async => showBottomCard(
                          context,
                          ExtendSharedNasAccountCard(
                            account_map: widget.account_map,
                          ),
                        ),
                        child: Container(
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 23,
                                backgroundColor: Colors.grey[200],
                                child: Image.asset(
                                  'assets/sign.png',
                                  height: 25,
                                  width: 25,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add Days",
                                    style: GoogleFonts.ubuntu(
                                      color: const Color(0xFF616161),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Add more days to the account's days left",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.grey[600],
                                      fontSize: 13,
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
                        onTap: () async {
                          setState(() => is_loading = true);

                          // generates a join link
                          String link = await context
                              .read<SavingsProviderFunctions>()
                              .generateSharedNasJoinLink(
                                  widget.account_map["account_id"]);

                          setState(() => is_loading = false);

                          // copies link to clipboard
                          await Clipboard.setData(ClipboardData(text: link));

                          showSnackBar(context, "Join Link Copied",
                              color: Colors.green[600]!);

                          goBack(context);
                        },
                        child: Container(
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 23,
                                backgroundColor: Colors.grey[200],
                                child: Image.asset(
                                  'assets/add-user.png',
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Share Join Link",
                                    style: GoogleFonts.ubuntu(
                                      color: const Color(0xFF616161),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Add friends & family to account via link",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.grey[600],
                                      fontSize: 13,
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
                        onTap: () async {
                          setState(() => is_loading = true);

                          String donation_url = await context
                              .read<SavingsProviderFunctions>()
                              .generateSharedNasDonationLink(
                                  widget.account_map["account_id"]);

                          setState(() => is_loading = false);

                          // copies link to clipboard
                          await Clipboard.setData(
                              ClipboardData(text: donation_url));

                          showSnackBar(context, "Donation Link Copied",
                              color: Colors.green[600]!);

                          goBack(context);
                        },
                        child: Container(
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 23,
                                backgroundColor: Colors.grey[200],
                                child: Image.asset(
                                  'assets/donation.png',
                                  height: 25,
                                  width: 25,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Share Donation Link",
                                    style: GoogleFonts.ubuntu(
                                      color: const Color(0xFF616161),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Collect donations without adding people",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.grey[600],
                                      fontSize: 13,
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
            ),
    );
  }

  // =============== styling widgets

  Decoration cardDeco() {
    return const BoxDecoration(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(40),
        topLeft: Radius.circular(40),
      ),
      color: Colors.white,
    );
  }
}
