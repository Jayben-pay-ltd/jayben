// ignore_for_file: non_constant_identifier_names
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jayben/Home/elements/qr_scanner/scan_page.dart';
import 'package:provider/provider.dart';
import '../elements/messages/messages.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:jayben/Home/components/cashier_card.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import '../elements/transactions/all_transactions_page.dart';
import '../elements/savings/components/savings_page_widgets.dart';
import 'package:jayben/Home/elements/feed/componets/feed_tile.dart';
import 'package:jayben/Home/elements/feed/componets/feed_widgets.dart';
import '../elements/transactions/components/home_transaction_tile.dart';
import '../elements/transactions/components/initiated_payment_tile.dart';
import '../elements/savings/components/savings_accounts_list_widget.dart';
import '../elements/transactions/components/time_limited_transaction_tile.dart';
import 'package:jayben/Home/elements/drawer/elements/components/ProfileWidgets.dart';
import 'package:jayben/Home/elements/deposit_money/deposit_money_to_wallet_page.dart';

Widget homeBodyWidget(BuildContext context, scaffoldKey, _scroll_controller) {
  return Consumer<HomeProviderFunctions>(
    builder: (_, value, child) {
      return SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Container(
              width: width(context),
              height: height(context),
              decoration: customGrandientDecor(),
              child: RepaintBoundary(
                child: RefreshIndicator(
                  onRefresh: () async {
                    value.toggleIsLoading();

                    // plays refresh sound
                    await playSound('refresh.mp3');

                    await Future.wait([
                      context
                          .read<FeedProviderFunctions>()
                          .getFeedTransactions(),
                      value.updateNotificationToken(),
                      value.getHomeSavingsAccounts(),
                      value.checkAppVersion(context),
                      value.getHomeTransactions(),
                      value.loadDetailsToHive(),
                    ]);

                    value.toggleIsLoading();
                  },
                  displacement: 70,
                  child: Scrollbar(
                    controller: _scroll_controller,
                    child: ListView(
                      shrinkWrap: true,
                      controller: _scroll_controller,
                      padding: const EdgeInsets.only(top: 45),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        homeButtons(context),
                        walletBalanceWidget(context),
                        pageChangerWidget(context),
                        homeBody(context)
                      ],
                    ),
                  ),
                ),
              ),
            ),
            floatingCashierWidget(context, _scroll_controller),
            customAppBar(context, scaffoldKey),
          ],
        ),
      );
    },
  );
}

Widget walletBalanceWidget(BuildContext context) {
  return Consumer<HomeProviderFunctions>(
    builder: (_, value, child) {
      return value.returnCurrentHomeState() == "Wallet"
          ? Container(
              width: width(context),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: value.returnIsLoading()
                  ? SizedBox(
                      width: width(context),
                      height: height(context) * 0.15,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () async {
                        value.toggleIsLoading();

                        // plays refresh sound
                        await playSound('refresh.mp3');

                        await Future.wait([
                          value.loadDetailsToHive(),
                          value.getHomeTransactions(),
                          value.getHomeSavingsAccounts(),
                          value.updateNotificationToken(),
                          value.checkAppVersion(context),
                        ]);

                        value.toggleIsLoading();
                      },
                      child: SizedBox(
                        width: width(context),
                        height: height(context) * 0.2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text.rich(
                              TextSpan(
                                text: box("balance") == null
                                    ? "..."
                                    : "${box("currency")} ",
                                children: [
                                  TextSpan(
                                    text: box("balance") == null
                                        ? "0"
                                        : "${box("balance")}",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.black,
                                      fontSize: 40,
                                    ),
                                  )
                                ],
                              ),
                              style: GoogleFonts.ubuntu(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                            hGap(10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 5),
                              decoration: customPointsBoxDecor(),
                              child: Text.rich(
                                TextSpan(
                                  text: "Points ",
                                  children: [
                                    TextSpan(
                                      text: box("points") == null
                                          ? "0"
                                          : box("points").toStringAsFixed(0),
                                      style: GoogleFonts.ubuntu(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[100],
                                        fontSize: 20,
                                      ),
                                    )
                                  ],
                                ),
                                style: GoogleFonts.ubuntu(
                                  color: Colors.grey[100],
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            hGap(15),
                            InkWell(
                              onTap: () async {
                                value.toggleIsLoading();

                                // plays refresh sound
                                await playSound('refresh.mp3');

                                await Future.wait([
                                  context
                                      .read<FeedProviderFunctions>()
                                      .getFeedTransactions(),
                                  value.updateNotificationToken(),
                                  value.getHomeSavingsAccounts(),
                                  value.checkAppVersion(context),
                                  value.getHomeTransactions(),
                                  value.loadDetailsToHive(),
                                ]);

                                value.toggleIsLoading();
                              },
                              child: Icon(
                                Icons.refresh,
                                color: Colors.grey[500],
                                size: 25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            )
          : nothing();
    },
  );
}

Widget homeButtons(BuildContext context) {
  return Container(
    width: width(context),
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        walletButton(),
        savingsButton(),
      ],
    ),
  );
}

Widget walletButton() {
  return Consumer<HomeProviderFunctions>(builder: (_, value, child) {
    return Expanded(
      child: GestureDetector(
        onTap: () => value.changeHomeState("Wallet"),
        child: Container(
          decoration: BoxDecoration(
            color: value.returnCurrentHomeState() == "Wallet"
                ? Colors.grey[200]
                : Colors.transparent,
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(40),
              topRight: Radius.circular(5),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/purse.png", height: 50, width: 50),
              hGap(11),
              Text(
                "Wallet",
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  fontSize: 18,
                ),
              )
            ],
          ),
        ),
      ),
    );
  });
}

Widget savingsButton() {
  return Consumer<HomeProviderFunctions>(
    builder: (context, value, child) {
      return Expanded(
        child: GestureDetector(
          onTap: () async {
            if (["Agent", "Merchant"].contains(box("account_type"))) {
              showSnackBar(
                  context, "Savings not available for Agents & Merchants");
              return;
            }

            value.changeHomeState("Savings");

            await Future.wait([
              value.loadDetailsToHive(),
              value.getHomeTransactions(),
              value.getHomeSavingsAccounts(),
              value.updateNotificationToken(),
              value.checkAppVersion(context),
            ]);
          },
          child: Container(
            decoration: BoxDecoration(
              color: value.returnCurrentHomeState() == "Savings"
                  ? Colors.grey[200]
                  : Colors.transparent,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                topLeft: Radius.circular(5),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/piggy-bank.png", height: 53, width: 53),
                hGap(10),
                Text(
                  "Savings",
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    fontSize: 18,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget homeBody(BuildContext context) {
  return Consumer<HomeProviderFunctions>(
    builder: (_, value, child) {
      return value.returnCurrentHomeState() != "Savings"
          ? value.returnCurrentHomeBodyIndex() == 0
              ? homeTransactionsBody(context)
              : timelineBody(context)
          : homeSavingsBody(context);
    },
  );
}

Widget timelineBody(BuildContext context) {
  return Consumer<FeedProviderFunctions>(
    builder: (_, value, child) {
      return value.returnMyUploadedContactsWithoutJaybenAccs() == null
          ? nothing()
          : value.returnMyUploadedContactsWithoutJaybenAccs()!.isEmpty
              ? noContactsWithJaybenAccsWidgetFeed(context)
              : value.returnFeedTransactions() == null
                  ? nothing()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        timelinePrivacyWidget(context),
                        hGap(10),
                        Divider(
                          color: Colors.grey[300],
                          thickness: 0.4,
                        ),
                        // storiesRow(context),
                        // hGap(10),
                        RepaintBoundary(
                          child: value.returnFeedTransactions()!.isEmpty
                              ? noTimelinePostsWidget(context)
                              : ListView.builder(
                                  shrinkWrap: true,
                                  addRepaintBoundaries: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 140),
                                  itemCount:
                                      value.returnFeedTransactions()!.length,
                                  itemBuilder: (__, i) {
                                    Map post_map =
                                        value.returnFeedTransactions()![i];
                                    return FeedTile(post_map: post_map);
                                  },
                                ),
                        ),
                      ],
                    );
    },
  );
}

Widget depositWidget(BuildContext context) {
  return Container(
    alignment: Alignment.center,
    height: height(context) * 0.31,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Deposit Cash to your wallet',
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        hGap(10),
        Text(
          'Via Mobile Money or Credit/Debit Card',
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w300,
            color: Colors.grey[900],
            fontSize: 17,
          ),
        ),
        hGap(15),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.green),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ),
          onPressed: () => changePage(context, const DepositPage()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: Text(
              "ADD MONEY",
              style: GoogleFonts.ubuntu(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        )
      ],
    ),
  );
}

Widget homeTransactionsBody(BuildContext context) {
  return Consumer<HomeProviderFunctions>(
    builder: (_, value, child) {
      return value.returnHomeTransactions() == null
          ? ["Agent", "Merchant"].contains(box("account_type"))
              ? Container(
                  alignment: Alignment.center,
                  height: height(context) * 0.31,
                  child: Text(
                    "Welcome to Jayben! \nStart transacting today.",
                    textAlign: TextAlign.center,
                    style: googleStyle(
                      size: 16,
                    ),
                  ),
                )
              : depositWidget(context)
          : Padding(
              padding: const EdgeInsets.only(bottom: 150),
              child: Column(
                children: [
                  viewMoreMoreTransactionsTopWidget(context),
                  // const InitiatedPaymentTile(),
                  // const TimeLtdTranxTile(),
                  const TransactionTile(),
                  viewMoreTransactionsBottomWidget(context),
                ],
              ),
            );
    },
  );
}

Widget homeSavingsBody(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 40),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        createSavingsAccountWidget(context),
        !box("show_app_wide_top_20_nas_accounts")
            ? nothing()
            : Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: accountTypeFilterWidget(context),
              ),
        const SavingsAccountsListWidget(),
      ],
    ),
  );
}

Widget pageChangerWidget(BuildContext context) {
  return Consumer<HomeProviderFunctions>(builder: (_, value, child) {
    return box("enable_timeline_feed") == null
        ? nothing()
        : value.returnCurrentHomeState() == "Savings" ||
                ["Agent", "Merchant"].contains(box("account_type")) ||
                !box("enable_timeline_feed")
            ? nothing()
            : Container(
                width: width(context),
                alignment: Alignment.center,
                child: Container(
                  height: 50,
                  width: width(context) * 0.9,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: homePageTimelineChangerDeco(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => value.changeCurrentHomeBodyIndex(0),
                        child: Container(
                          width: width(context) * 0.432,
                          decoration: innerTimelineChangerDeco(
                              value.returnCurrentHomeBodyIndex(), 0),
                          alignment: Alignment.center,
                          child: Text(
                            "Transactions",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[900]!,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      wGap(5),
                      GestureDetector(
                        onTap: () => value.changeCurrentHomeBodyIndex(1),
                        child: Container(
                          width: width(context) * 0.432,
                          decoration: innerTimelineChangerDeco(
                              value.returnCurrentHomeBodyIndex(), 1),
                          alignment: Alignment.center,
                          child: Text(
                            "Timeline",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[900]!,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
  });
}

Widget viewMoreMoreTransactionsTopWidget(BuildContext context) {
  return Container(
    width: width(context),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "My Transactions",
          textAlign: TextAlign.right,
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w400,
            color: Colors.grey[700],
            fontSize: 12,
          ),
        ),
        GestureDetector(
          onTap: () => changePage(context, const AllTransactionsPage()),
          child: SizedBox(
            child: Text(
              "View All",
              textAlign: TextAlign.right,
              style: GoogleFonts.ubuntu(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w400,
                color: Colors.orange[700],
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget timelinePrivacyWidget(BuildContext context) {
  return Container(
    width: width(context),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Transactions from friends",
          textAlign: TextAlign.right,
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w400,
            color: Colors.grey[700],
            fontSize: 12,
          ),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton2(
            customButton: Text(
              "View Options",
              textAlign: TextAlign.right,
              style: GoogleFonts.ubuntu(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                fontSize: 12,
              ),
            ),
            items: [
              ...MenuItems.firstItems.map(
                (item) => DropdownMenuItem<MenuItem>(
                  value: item,
                  child: MenuItems.buildItem(item),
                ),
              ),
            ],
            onChanged: (value) {
              MenuItems.onChanged(context, value!);
            },
            dropdownStyleData: DropdownStyleData(
              width: 160,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
              ),
              offset: const Offset(0, 8),
            ),
            menuItemStyleData: MenuItemStyleData(
              customHeights: [
                ...List<double>.filled(MenuItems.firstItems.length, 48),
              ],
              padding: const EdgeInsets.only(left: 16, right: 16),
            ),
          ),
        )
      ],
    ),
  );
}

Widget viewMoreTransactionsBottomWidget(BuildContext context) {
  return GestureDetector(
    onTap: () => changePage(context, const AllTransactionsPage()),
    child: Container(
      padding: const EdgeInsets.only(top: 10),
      width: width(context),
      child: Text(
        "Click 'view all' to view more transactions",
        textAlign: TextAlign.center,
        style: GoogleFonts.ubuntu(
          fontWeight: FontWeight.w300,
          color: Colors.grey[700],
          fontSize: 16,
        ),
      ),
    ),
  );
}

Widget floatingCashierWidget(
    BuildContext context, ScrollController _scroll_controller) {
  return Consumer<HomeProviderFunctions>(
    builder: (_, value, child) {
      return value.returnCurrentHomeState() == "Savings" ||
              ["Agent", "Merchant"].contains(box("account_type"))
          ? nothing()
          : Positioned(
              bottom: Platform.isIOS ? 35 : 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  !value.returnShowBackToTopButton()
                      ? nothing()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: FloatingActionButton.small(
                            backgroundColor: Colors.grey[600]!.withOpacity(0.9),
                            onPressed: () {
                              // stops list from scrolling (if is currently scrolling)
                              _scroll_controller
                                  .jumpTo(_scroll_controller.position.pixels);

                              // scrolls to top
                              _scroll_controller.animateTo(0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.decelerate);

                              // hides the scroll to top button
                              value.toggleShowBackToTopButton(false);
                            },
                            child: const Icon(
                              Icons.arrow_upward_sharp,
                            ),
                          ),
                        ),
                  GestureDetector(
                    onTap: () => showBottomCard(context, cashierCard(context)),
                    child: Container(
                      width: width(context),
                      alignment: Alignment.center,
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        width: width(context) * 0.8,
                        decoration: floatingNavBarDeco(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset("assets/dollar.png", height: 27),
                            wGap(10),
                            Text(
                              "Cashier",
                              style: googleStyle(
                                weight: FontWeight.w500,
                                color: Colors.white,
                                size: 20,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
    },
  );
}

Widget customAppBar(BuildContext context, _scaffoldKey) {
  return Consumer<MessageProviderFunctions>(
    builder: (_, value, child) {
      return Positioned(
        top: 0,
        child: Container(
          width: width(context),
          decoration: appBarDeco(),
          padding: const EdgeInsets.only(bottom: 5, top: 7),
          child: Stack(
            children: [
              Container(
                width: width(context),
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                    bottom: 10, left: 10, right: 10, top: 2),
                child: Image.asset(
                  "assets/logo_name.png",
                  color: Colors.black,
                  height: 22,
                ),
              ),
              Positioned(
                left: 20,
                bottom: 5,
                child: InkWell(
                  onTap: () => _scaffoldKey.currentState!.openDrawer(),
                  child: SizedBox(
                    child: Image.asset(
                      "assets/menu-bar.png",
                      color: Colors.black,
                      height: 30,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 15,
                top: 0,
                child: InkWell(
                  onTap: () => changePage(context, const QRScannerPage()),
                  child: SizedBox(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          "Scan Code",
                          style: googleStyle(
                            color: Colors.green,
                            size: 18,
                          ),
                        )
                        // Image.asset(
                        //   "assets/comments.png",
                        //   color: Colors.black,
                        //   height: 25,
                        // ),
                        // Image.asset(
                        //   "assets/send-gradient.png",
                        //   height: 30,
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ====================== styling widgets

Decoration homePageTimelineChangerDeco() {
  return BoxDecoration(
    color: Colors.grey[200],
    borderRadius: const BorderRadius.all(
      Radius.circular(25),
    ),
  );
}

Decoration innerTimelineChangerDeco(int current_index, int page_index) {
  return BoxDecoration(
    color: current_index == page_index ? Colors.white : Colors.transparent,
    borderRadius: const BorderRadius.all(
      Radius.circular(19),
    ),
  );
}

Decoration floatingNavBarDeco() {
  return BoxDecoration(
    color: Colors.black,
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.65),
        spreadRadius: 5,
        blurRadius: 7,
        offset: const Offset(0, 3),
      ),
    ],
    borderRadius: const BorderRadius.all(
      Radius.circular(50),
    ),
  );
}

Decoration homeBodyDeco() {
  return const BoxDecoration(
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(40),
      topLeft: Radius.circular(40),
    ),
  );
}

BoxDecoration customGrandientDecor() {
  return const BoxDecoration(color: Colors.white);
}

BoxDecoration customPointsBoxDecor() {
  return const BoxDecoration(
    color: Colors.black,
    borderRadius: BorderRadius.all(
      Radius.circular(20),
    ),
  );
}
