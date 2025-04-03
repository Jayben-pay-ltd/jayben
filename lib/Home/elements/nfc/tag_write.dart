// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/drawer/elements/contact_us.dart';
import 'package:shimmer/shimmer.dart';

class WriteTageCard extends StatefulWidget {
  const WriteTageCard({super.key});

  @override
  State<WriteTageCard> createState() => _WriteTageCardState();
}

class _WriteTageCardState extends State<WriteTageCard> {
  @override
  void initState() {
    context.read<NfcProviderFunctions>().updateCurrentNfcListenerState("write");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NfcProviderFunctions>(
      builder: (_, value, child) {
        return Stack(
          children: [
            SizedBox(
              width: width(context),
              child: value.returnIsLoading()
                  ? _loadingWidget(context)
                  : Builder(
                      builder: (_) {
                        return Container(
                          decoration: cardDeco(),
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: Platform.isIOS ? 40 : 25,
                              right: 30,
                              left: 30,
                              top: 30,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Step 2 of 2",
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.w300,
                                    color: Colors.green,
                                    fontSize: 18,
                                  ),
                                ),
                                hGap(10),
                                Text(
                                  "Ready to link card",
                                  style: GoogleFonts.ubuntu(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                                const Spacer(),
                                Shimmer.fromColors(
                                  baseColor: Colors.black,
                                  period: const Duration(milliseconds: 3000),
                                  highlightColor: const Color.fromARGB(255, 180, 171, 93),
                                  child: Text(
                                    "Touch card to the\nmiddle backside of phone\nfor 3 seconds...",
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.ubuntu(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => changePage(
                                      context, const ContactUsPage()),
                                  child: SizedBox(
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Want a new card?  ",
                                            style: GoogleFonts.ubuntu(
                                              fontWeight: FontWeight.w300,
                                              color: Colors.grey[600],
                                              fontSize: 15,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Contact Support',
                                            style: GoogleFonts.ubuntu(
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                hGap(20)
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Positioned(
              right: 20,
              top: 20,
              child: GestureDetector(
                onTap: () {
                  context
                      .read<NfcProviderFunctions>()
                      .updateCurrentNfcListenerState("read");

                  goBack(context);
                },
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.grey[200],
                  child: Icon(
                    Icons.close,
                    color: Colors.grey[600],
                    size: 19,
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _loadingWidget(BuildContext context) {
    return Container(
      width: width(context),
      decoration: cardDeco(),
      alignment: Alignment.center,
      height: height(context) * 0.3,
      child: loadingIcon(
        context,
        color: Colors.black,
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
