// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:jayben/Utilities/General_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:permission_handler/permission_handler.dart';

class ChooseSimCard extends StatefulWidget {
  const ChooseSimCard({super.key, required this.shortcut_map});

  final Map shortcut_map;

  @override
  State<ChooseSimCard> createState() => _ChooseSimCardState();
}

class _ChooseSimCardState extends State<ChooseSimCard> {
  @override
  void initState() {
    onCardLoad();
    super.initState();
  }

  Future<void> onCardLoad() async {
    await [Permission.phone].request();

    if (!await Permission.phone.request().isGranted) {
      showSnackBar(context, "Accept phone permission to use USSD shortcuts");

      goBack(context);

      await [Permission.phone].request();

      return;
    }

    List<SimCard>? simCards = await MobileNumber.getSimCards;

    if (simCards == null) {
      showSnackBar(context,
          "No sim cards detected. If this problem persists, please contact customer support.");
      goBack(context);

      return;
    }

    if (!mounted) return;

    setState(() => available_sim_cards = simCards);
  }

  List<SimCard>? available_sim_cards = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<UssdProviderFunctions>(builder: (_, value, child) {
      return SizedBox(
        width: width(context),
        child: available_sim_cards == null
            ? Center(child: loadingScreenPlainNoBackButton(context))
            : Container(
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
                      for (var sim in available_sim_cards!)
                        GestureDetector(
                          onTap: () async {
                            goBack(context);
                            try {
                              await value.runShortcut({
                                "carrier_display_name": sim.displayName,
                                "country_code": sim.countryPhonePrefix,
                                "subscription": sim.slotIndex! + 1,
                                "country_prefix": sim.countryIso,
                                "carrier_name": sim.carrierName,
                                "sim_number": sim.number,
                                ...widget.shortcut_map
                              });
                            } on Exception catch (e) {
                              showSnackBar(context,
                                  "An error occured: $e. If issue persists, please contact customer support.",
                                  duration: 10);
                            }
                          },
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.only(
                                bottom:
                                    available_sim_cards!.length == 1 ? 0 : 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                simCardIcon(sim.slotIndex!),
                                wGap(10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "SIM ${sim.slotIndex! + 1}",
                                      style: GoogleFonts.ubuntu(
                                        color: const Color(0xFF616161),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    hGap(2),
                                    Text(
                                      sim.carrierName!,
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
                        )
                    ],
                  ),
                ),
              ),
      );
    });
  }

  Widget simCardIcon(int sim_index) {
    int num = sim_index + 1;
    return CircleAvatar(
      radius: 23,
      backgroundColor: Colors.grey[200],
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            height: 30,
            width: 30,
            'assets/sim-card.png',
            color: num == 1
                ? Colors.purple
                : num == 2
                    ? Colors.green
                    : num == 3
                        ? Colors.orange
                        : num == 4
                            ? Colors.blue
                            : Colors.green,
          ),
          Image.asset(
            height: 15,
            width: 15,
            'assets/number-$num.png',
            color: num == 1
                ? Colors.purple
                : num == 2
                    ? Colors.green
                    : num == 3
                        ? Colors.orange
                        : num == 4
                            ? Colors.blue
                            : Colors.green,
          ),
        ],
      ),
    );
  }
}
