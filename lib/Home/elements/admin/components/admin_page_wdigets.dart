// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/components/home_page_widgets.dart';
import 'package:jayben/Home/elements/admin/elements/admin_card.dart';

Widget appBar(BuildContext context, tab_controller) {
  return Consumer<AdminProviderFunctions>(builder: (_, value, child) {
    return Positioned(
      top: 0,
      child: Container(
        width: width(context),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 0.5,
            ),
          ),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(bottom: 0, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => goBack(context),
                  child: const SizedBox(
                    child: Icon(
                      color: Colors.black,
                      Icons.arrow_back,
                      size: 40,
                    ),
                  ),
                ),
                const Spacer(),
                wGap(30),
                Text.rich(
                  const TextSpan(text: "God View"),
                  textAlign: TextAlign.left,
                  style: GoogleFonts.ubuntu(
                    color: const Color.fromARGB(255, 54, 54, 54),
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    value.toggleIsLoading();

                    await Future.wait([
                      // value.callSupabaseDailyMetricAPI()
                      value.getPendingVerificationRequests(),
                      value.getPendingWithdrawalsFirebase(),
                      value.getAdminMetricsDocument(),
                      value.getPendingWithdrawals(),
                      value.getCountableMetrics(),
                    ]);

                    value.toggleIsLoading();
                  },
                  child: SizedBox(
                    child: value.returnIsLoading()
                        ? Padding(
                            padding:
                                const EdgeInsets.only(right: 10.0, left: 40),
                            child: loadingIcon(
                              color: Colors.black,
                              context,
                            ),
                          )
                        : Text(
                            "Refresh",
                            style: googleStyle(
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            TabBar(
              controller: tab_controller,
              labelColor: Colors.grey[700],
              indicatorColor: Colors.green,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: "Metrics"),
                Tab(text: "Verifications"),
                Tab(text: "Withdrawals"),
              ],
            )
          ],
        ),
      ),
    );
  });
}

Widget metricsBody(BuildContext context) {
  return Consumer<AdminProviderFunctions>(builder: (_, value, child) {
    // Map metrics_info = value.returnAdminMetricsDocument()!.data() as Map;
    return RefreshIndicator(
      displacement: 150,
      onRefresh: () async {
        // plays refresh sound
        await playSound('refresh.mp3');

        value.toggleIsLoading();

        await Future.wait([
          value.getPendingVerificationRequests(),
          value.getAdminMetricsDocument(),
          value.getPendingWithdrawals(),
          value.getCountableMetrics(),
        ]);

        value.toggleIsLoading();
      },
      child: ListView(
        shrinkWrap: true,
        addRepaintBoundaries: true,
        padding: const EdgeInsets.only(top: 105),
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            width: width(context),
            padding: const EdgeInsets.only(left: 40, right: 40, bottom: 80),
            child: GridView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1.3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                crossAxisCount: 2,
              ),
              children: [
                gridTile(context, {
                  "metric_name": "Registered Users",
                  "metric_figure": value.returnNumberOfRegisteredUsers(),
                  "metric_unit": "users",
                }),
                // gridTile(context, {
                //   "metric_name": "New Users Today",
                //   "metric_figure": metrics_info["dailyNewUserSignUps"],
                //   "metric_unit": "users",
                // }),
                gridTile(context, {
                  "metric_name": "Daily Active Users",
                  "metric_figure":
                      value.returnNumberOfDailyActiveUsersTodaySoFar(),
                  "metric_unit": "users",
                }),
                gridTile(context, {
                  "metric_name": "Weekly Active Users",
                  "metric_figure": value.returnWeeklyActiveUsers(),
                  "metric_unit": "users",
                }),
                gridTile(context, {
                  "metric_name": "Monthly Active Users",
                  "metric_figure":
                      value.returnNumberOfMonthlyActiveUsersTodaySoFar(),
                  "metric_unit": "users",
                }),
                gridTile(context, {
                  "metric_name": "New Users This Month",
                  "metric_figure": value.returnNumberOfNewUsersInLast30Days(),
                  "metric_unit": "users",
                }),
                gridTile(context, {
                  "metric_name": "Money Ever Deposited",
                  "metric_figure": value.returnTotalAmountEverDeposited(),
                  "metric_unit": "ZMW",
                }),
                gridTile(context, {
                  "metric_name": "Total User Money ",
                  "metric_figure":
                      value.returnTotalAmountOfUserMoneyInOurPossession(),
                  "metric_unit": "ZMW",
                }),
                gridTile(context, {
                  "metric_name": "Total Transactions Ever",
                  "metric_figure":
                      value.returnTotalNumberOfTransactionsProcessedEver(),
                  "metric_unit": "transactions",
                }),
                gridTile(context, {
                  "metric_name": "Transactions Today",
                  "metric_figure":
                      value.returnNumberOfTransactionsProcessedToday(),
                  "metric_unit": "transactions",
                }),
                gridTile(context, {
                  "metric_name": "Total User Wallet Bals",
                  "metric_figure": value.returnTotalAmountInWallets(),
                  "metric_unit": "ZMW",
                }),
                gridTile(context, {
                  "metric_name": "Amount Active NAS Accs",
                  "metric_figure": value.returnTotalAmountInPersonalNasAccs(),
                  "metric_unit": "ZMW",
                }),
                gridTile(context, {
                  "metric_name": "Active NAS Accounts",
                  "metric_figure": value.returnNumberOfActivePersonalNasAccs(),
                  "metric_unit": "accounts",
                }),
                gridTile(context, {
                  "metric_name": "Amount Saved In Active Shared NAS Accs",
                  "metric_figure":
                      value.returnTotalAmountInActiveSharedAccounts(),
                  "metric_unit": "ZMW",
                }),
                gridTile(context, {
                  "metric_name": "Num Of Active Shared NAS Accounts",
                  "metric_figure":
                      value.returnNumberOfActiveFundedSharedNasAccounts(),
                  "metric_unit": "accounts",
                }),
                // gridTile(context, {
                //   "metric_name": "Total Deposits Today",
                //   "metric_figure": metrics_info["dailyDepositsTotalProcessed"],
                //   "metric_unit": "ZMW",
                // }),
                // gridTile(context, {
                //   "metric_name": "Deposits Made Today",
                //   "metric_figure": metrics_info["dailyNumberOfDepositsMade"],
                //   "metric_unit": "deposits",
                // }),
                gridTile(context, {
                  "metric_name": "Transfers To NAS Accs Today",
                  "metric_figure":
                      value.returnNumberOfTransfersToPersonalNasAccs(),
                  "metric_unit": "transfers",
                }),
                gridTile(context, {
                  "metric_name": "Total NAS Acc Savings Today",
                  "metric_figure":
                      value.returnTotalAmountSavedInPersonalNasAccsTodaySoFar(),
                  "metric_unit": "ZMW",
                }),
                gridTile(context, {
                  "metric_name": "Total Withdrawals Today",
                  "metric_figure": value.returnTotalAmountWithdrawnTodaySoFar(),
                  "metric_unit": "ZMW",
                }),
                // gridTile(context, {
                //   "metric_name": "Withdraws Made Today",
                //   "metric_figure": metrics_info["dailyNumberOfWithdrawalsMade"],
                //   "metric_unit": "withdraws",
                // }),
                gridTile(context, {
                  "metric_name": "Pending Withdraws",
                  "metric_figure": value.returnNumberOfPendingWithdraws(),
                  "metric_unit": "withdraws",
                }),
              ],
            ),
          )
        ],
      ),
    );
  });
}

Widget floatingWidget(BuildContext context) {
  return Consumer<HomeProviderFunctions>(
    builder: (_, value, child) {
      return value.returnCurrentHomeState() == "Savings"
          ? nothing()
          : Positioned(
              bottom: Platform.isIOS ? 35 : 20,
              child: GestureDetector(
                onTap: () =>
                    showBottomCard(context, const AdminDashboardCard()),
                child: Container(
                  width: width(context),
                  alignment: Alignment.center,
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    width: width(context) * 0.8,
                    decoration: floatingNavBarDeco(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "More Options",
                      style: googleStyle(
                        weight: FontWeight.w500,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            );
    },
  );
}

Widget gridTile(BuildContext context, Map metric_map) {
  return Container(
    width: 150,
    height: 200,
    decoration: deco(),
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            metric_map["metric_name"],
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w400,
              color: Colors.black,
              fontSize: 13,
            ),
          ),
        ),
        hGap(10),
        Text(
          double.parse(metric_map["metric_figure"].toString())
              .toStringAsFixed(1),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w500,
            color: Colors.green,
            fontSize: 17,
          ),
        ),
        hGap(10),
        Text(
          metric_map["metric_unit"],
          textAlign: TextAlign.center,
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w300,
            color: Colors.grey[600],
            fontSize: 15,
          ),
        ),
      ],
    ),
  );
}

// ================ styling widgets

Decoration deco() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    color: Colors.grey[200],
  );
}
