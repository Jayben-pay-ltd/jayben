// ignore_for_file: non_constant_identifier_names
import 'package:jayben/Home/elements/send_money/elements/components/select_receiver_widgets.dart';
import 'package:jayben/Home/elements/drawer/elements/components/kyc_verification_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'active_agent_tile.dart';

Widget agentsAppbar(BuildContext context) {
  return Consumer<AgentProviderFunctions>(
    builder: (_, value, child) {
      return Positioned(
        top: 0,
        child: Container(
          width: width(context),
          decoration: appBarDeco(),
          padding: const EdgeInsets.only(bottom: 10, top: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    width: width(context),
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    child: Text(
                      "Choose an Agent",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ubuntu(
                        color: const Color.fromARGB(255, 54, 54, 54),
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 5,
                    child: InkWell(
                      onTap: () => goBack(context),
                      child: const SizedBox(
                        child: Icon(
                          color: Colors.black,
                          Icons.arrow_back,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 25,
                    top: 0,
                    child: GestureDetector(
                      onTap: () async {
                        if (value.returnIsLoading()) return;

                        value.toggleIsLoading();

                        await value.getActiveAgents();

                        value.toggleIsLoading();

                        showSnackBar(context, "Agents list has been refresh.");
                      },
                      child: value.returnIsLoading()
                          ? Padding(
                              padding: const EdgeInsets.only(
                                right: 10.0,
                                left: 40,
                              ),
                              child: loadingIcon(
                                context,
                                color: Colors.black,
                              ),
                            )
                          : const SizedBox(
                            child: Icon(
                              color: Colors.black,
                              Icons.refresh,
                              size: 30,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
              hGap(5),
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
                        onTap: () => value.changeAgentsCurrentIndex(0),
                        child: Container(
                          width: width(context) * 0.43,
                          color: value.returnAgentsCurrentIndex() == 1
                              ? Colors.transparent
                              : Colors.white,
                          alignment: Alignment.center,
                          child: Text(
                            "Active Agents (${value.returnActiveAgents()!.length})",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: value.returnAgentsCurrentIndex() == 1
                                  ? Colors.grey[600]!
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      wGap(5),
                      GestureDetector(
                        onTap: () => value.changeAgentsCurrentIndex(1),
                        child: Container(
                          width: width(context) * 0.43,
                          color: value.returnAgentsCurrentIndex() == 0
                              ? Colors.transparent
                              : Colors.white,
                          alignment: Alignment.center,
                          child: Text(
                            "Orders",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: value.returnAgentsCurrentIndex() == 0
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

Widget noActiveAgentsAvailable(BuildContext context) {
  return Consumer<AgentProviderFunctions>(
    builder: (_, value, child) {
      return Container(
        width: width(context),
        alignment: Alignment.center,
        height: height(context) * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/box.png", height: 80),
            hGap(20),
            Text(
              "No active agents currently",
              textAlign: TextAlign.center,
              style: googleStyle(
                color: Colors.grey[800]!,
                weight: FontWeight.w400,
                size: 16.5,
              ),
            ),
            hGap(20),
            Text(
              "Please try again abit later",
              textAlign: TextAlign.center,
              style: googleStyle(
                color: Colors.grey[600]!,
                weight: FontWeight.w300,
                size: 13,
              ),
            ),
          ],
        ),
      );
    },
  );
}

class AgentsBody extends StatelessWidget {
  const AgentsBody({super.key, required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Consumer<AgentProviderFunctions>(
      builder: (_, value, child) {
        return RepaintBoundary(
          child: Container(
            color: Colors.white,
            width: width(context),
            height: height(context),
            alignment: Alignment.center,
            child: value.returnActiveAgents()!.isEmpty
                ? noActiveAgentsAvailable(context)
                : ListView.builder(
                    addRepaintBoundaries: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: value.returnActiveAgents()!.length,
                    padding: const EdgeInsets.only(top: 115, bottom: 20),
                    itemBuilder: (__, i) {
                      Map current_agent_map = value.returnActiveAgents()![i];
                      return ActiveAgentTile(agent_map: current_agent_map);
                    },
                  ),
          ),
        );
      },
    );
  }
}

class ActiveOrders extends StatelessWidget {
  const ActiveOrders({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AgentProviderFunctions>(
      builder: (_, value, child) {
        return value.returnActiveOrders() == null
            ? loadingScreenPlainNoBackButton(context)
            : RepaintBoundary(
                child: Container(
                  width: width(context),
                  color: Colors.white,
                  height: height(context),
                  alignment: Alignment.center,
                  child: value.returnActiveOrders()!.isEmpty
                      ? noActiveAgentsAvailable(context)
                      : ListView.builder(
                          addRepaintBoundaries: true,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(top: 115, bottom: 20),
                          itemCount: value.returnActiveOrders()!.length,
                          itemBuilder: (_, i) => inviteContactTileWidget(
                            context,
                            value.returnActiveOrders()![i],
                          ),
                        ),
                ),
              );
      },
    );
  }
}
