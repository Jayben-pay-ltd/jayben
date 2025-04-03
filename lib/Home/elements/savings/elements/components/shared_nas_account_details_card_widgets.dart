// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
import 'package:flutter/services.dart';
import 'package:jayben/Home/elements/savings/elements/shared_nas_account_transactions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jayben/Utilities/General_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

Widget accountDetailsBody(BuildContext context, Map body_info) {
  // gets all the acc bal share maps for all members
  List<dynamic> members_list = body_info["acc_map"]["account_balance_shares"];
  return Scaffold(
    body: Consumer<SavingsProviderFunctions>(
      builder: (_, value, child) {
        return MediaQuery.removePadding(
          removeTop: true,
          context: context,
          removeBottom: true,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              bottom: 20,
            ),
            children: [
              accountNameWidget(context, body_info),
              hGap(10),
              Container(
                width: width(context),
                alignment: Alignment.center,
                child: Text(
                  members_list.length == 1
                      ? "This account has 1 Member"
                      : "This account has ${members_list.length} Members",
                  textAlign: TextAlign.left,
                  style: googleStyle(
                    weight: FontWeight.w400,
                    color: Colors.grey[500]!,
                    size: 15,
                  ),
                ),
              ),
              hGap(12),
              Text(
                "*created ${timeago.format(DateTime.parse(body_info["acc_map"]["created_at"]).toUtc().toLocal())}",
                textAlign: TextAlign.center,
                maxLines: 1,
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w300,
                  color: Colors.orange[800],
                  fontSize: 12,
                ),
              ),
              hGap(20),
              balanceWidget(context, body_info),
              hGap(20),
              counterWidget(context, body_info),
              hGap(10),
              releaseTextWidget(),
              hGap(15),
              Text(
                "Total days for account: ${body_info["acc_map"]["total_days_for_account"]} days",
                textAlign: TextAlign.center,
                maxLines: 1,
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
              hGap(20),
              joinAccountLinkWidget(context, body_info),
              hGap(20),
              pageChangerWidget(context, body_info),
              hGap(25),
              membersWidget(context, body_info)
            ],
          ),
        );
      },
    ),
  );
}

Widget releaseTextWidget() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Text(
      "*when this timer ends, everyone's contributions will be"
      "\nsent back to their wallets, all at the same time.",
      textAlign: TextAlign.center,
      style: GoogleFonts.ubuntu(
        fontWeight: FontWeight.w300,
        color: Colors.black54,
        fontSize: 13.5,
      ),
    ),
  );
}

Widget memberTile(BuildContext context, Map body_info) {
  double amount = double.parse(body_info["balance"].toString());
  return Padding(
    padding: const EdgeInsets.only(bottom: 20.0),
    child: Row(
      children: [
        body_info["profile_image_url"] == ""
            ? const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage(
                  "assets/ProfileAvatar.png",
                ),
              )
            : CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[200],
                backgroundImage: CachedNetworkImageProvider(
                  body_info["profile_image_url"],
                ),
              ),
        wGap(15),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              body_info["names"],
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.w400,
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            dateJoinedWidget(context, body_info)
          ],
        ),
        const Spacer(),
        Container(
          width: 115,
          height: 50,
          alignment: Alignment.center,
          decoration: memberTileAmountShareDeco(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "contribution",
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w300,
                  color: Colors.grey[900]!,
                  fontSize: 11,
                ),
              ),
              hGap(2),
              Text.rich(
                TextSpan(
                  text: "${body_info["currency_symbol"]} ",
                  children: [
                    TextSpan(
                      text: amount < 100000.0
                          ? amount.toStringAsFixed(2)
                          : (amount >= 100000.0 && amount < 1000000.0
                              ? "${amount.toStringAsFixed(2)[0]}${amount.toStringAsFixed(2)[1]}${amount.toStringAsFixed(2)[2]}k"
                              : (amount > 1000000.0 && amount < 10000000.0
                                  ? "${amount.toStringAsFixed(2)[0]}.${amount.toStringAsFixed(2)[1]}${amount.toStringAsFixed(2)[2]} M"
                                  : (amount > 10000000.0 && amount < 100000000.0
                                      ? "${amount.toStringAsFixed(2)[0]}${amount.toStringAsFixed(2)[1]}.${amount.toStringAsFixed(2)[2]}${amount.toStringAsFixed(2)[3]} M"
                                      : "${amount.toStringAsFixed(2)[0]}${amount.toStringAsFixed(2)[1]}${amount.toStringAsFixed(2)[2]}.${amount.toStringAsFixed(2)[3]}${amount.toStringAsFixed(2)[4]} M"))),
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[900]!,
                        fontSize: 15,
                      ),
                    )
                  ],
                ),
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[900]!,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        wGap(10),
      ],
    ),
  );
}

Widget accountNameWidget(BuildContext context, Map body_info) {
  return Container(
    width: width(context) * 0.8,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Text(
      body_info["acc_map"]["account_name"],
      maxLines: 3,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.ubuntu(
        fontWeight: FontWeight.bold,
        color: Colors.green[900],
        fontSize: 30,
      ),
    ),
  );
}

Widget balanceWidget(BuildContext context, Map body_info) {
  double amount = double.parse(body_info["acc_map"]["balance"].toString());
  double my_share_amount =
      double.parse(body_info["user_map"]["balance"].toString());
  return Container(
    height: 100,
    width: width(context) * 0.9,
    alignment: Alignment.center,
    decoration: balanceWidgetDeco(),
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Account Balance",
                style: googleStyle(
                  color: Colors.grey[900]!,
                  weight: FontWeight.w400,
                  size: 17,
                ),
              ),
              hGap(10),
              Text.rich(
                TextSpan(
                  text: "${body_info["acc_map"]["currency"]} ",
                  children: [
                    TextSpan(
                      text: amount < 100000.0
                          ? amount.toStringAsFixed(2)
                          : (amount >= 100000.0 && amount < 1000000.0
                              ? "${amount.toStringAsFixed(2)[0]}${amount.toStringAsFixed(2)[1]}${amount.toStringAsFixed(2)[2]}k"
                              : (amount > 1000000.0 && amount < 10000000.0
                                  ? "${amount.toStringAsFixed(2)[0]}.${amount.toStringAsFixed(2)[1]}${amount.toStringAsFixed(2)[2]} M"
                                  : (amount > 10000000.0 && amount < 100000000.0
                                      ? "${amount.toStringAsFixed(2)[0]}${amount.toStringAsFixed(2)[1]}.${amount.toStringAsFixed(2)[2]}${amount.toStringAsFixed(2)[3]} M"
                                      : "${amount.toStringAsFixed(2)[0]}${amount.toStringAsFixed(2)[1]}${amount.toStringAsFixed(2)[2]}.${amount.toStringAsFixed(2)[3]}${amount.toStringAsFixed(2)[4]} M"))),
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[900]!,
                        fontSize: 20,
                      ),
                    )
                  ],
                ),
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[900]!,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        wGap(10),
        SizedBox(
          width: 5,
          height: 100,
          child: VerticalDivider(
            color: Colors.grey[500]!,
            thickness: 0.2,
          ),
        ),
        wGap(10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "My Contribution",
                style: googleStyle(
                  color: Colors.grey[900]!,
                  weight: FontWeight.w400,
                  size: 17,
                ),
              ),
              hGap(10),
              Text.rich(
                TextSpan(
                  text: "${body_info["acc_map"]["currency"]} ",
                  children: [
                    TextSpan(
                      text: my_share_amount < 100000.0
                          ? my_share_amount.toStringAsFixed(2)
                          : (my_share_amount >= 100000.0 &&
                                  my_share_amount < 1000000.0
                              ? "${my_share_amount.toStringAsFixed(2)[0]}${my_share_amount.toStringAsFixed(2)[1]}${my_share_amount.toStringAsFixed(2)[2]}k"
                              : (my_share_amount > 1000000.0 &&
                                      my_share_amount < 10000000.0
                                  ? "${my_share_amount.toStringAsFixed(2)[0]}.${my_share_amount.toStringAsFixed(2)[1]}${my_share_amount.toStringAsFixed(2)[2]} M"
                                  : (my_share_amount > 10000000.0 &&
                                          my_share_amount < 100000000.0
                                      ? "${my_share_amount.toStringAsFixed(2)[0]}${my_share_amount.toStringAsFixed(2)[1]}.${my_share_amount.toStringAsFixed(2)[2]}${my_share_amount.toStringAsFixed(2)[3]} M"
                                      : "${my_share_amount.toStringAsFixed(2)[0]}${my_share_amount.toStringAsFixed(2)[1]}${my_share_amount.toStringAsFixed(2)[2]}.${my_share_amount.toStringAsFixed(2)[3]}${my_share_amount.toStringAsFixed(2)[4]} M"))),
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[900]!,
                        fontSize: 20,
                      ),
                    )
                  ],
                ),
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[900]!,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget pageChangerWidget(BuildContext context, Map body_info) {
  return Consumer<SavingsProviderFunctions>(builder: (_, value, child) {
    return Container(
      width: width(context),
      alignment: Alignment.center,
      child: Container(
        height: 50,
        width: width(context) * 0.9,
        decoration: pageChangerDeco(),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => value.updateCurrentIndex(0),
              child: Container(
                width: width(context) * 0.432,
                decoration: innerPageChangerDeco(value.returnCurrentIndex(), 0),
                alignment: Alignment.center,
                child: Text(
                  "Members (${body_info["acc_map"]["number_of_members"]})",
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
              onTap: () => changePage(
                  context,
                  SharedNasAccountTransactionsPage(
                      savingsAccID: body_info["acc_map"]["account_id"])),
              child: Container(
                width: width(context) * 0.432,
                decoration: innerPageChangerDeco(value.returnCurrentIndex(), 1),
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
          ],
        ),
      ),
    );
  });
}

Widget joinAccountLinkWidget(BuildContext context, Map body_info) {
  return Consumer<SavingsProviderFunctions>(builder: (_, value, child) {
    return GestureDetector(
      onTap: () async {
        value.toggleIsLoading();

        // generates a join link
        String link = await context
            .read<SavingsProviderFunctions>()
            .generateSharedNasJoinLink(body_info["acc_map"]["account_id"]);

        value.toggleIsLoading();

        // copies link to clipboard
        await Clipboard.setData(ClipboardData(text: link));

        showSnackBar(context, "Join Link Copied", color: Colors.grey[700]!);

        goBack(context);
      },
      child: Container(
        width: width(context),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 50,
          decoration: joinLinkDeco(),
          alignment: Alignment.center,
          width: width(context) * 0.9,
          child: value.returnIsLoading()
              ? loadingIcon(context)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      color: Colors.white,
                      Icons.link,
                      size: 22,
                    ),
                    wGap(20),
                    Text(
                      "Invite friends & family via Join Link",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    wGap(20),
                    const Icon(
                      color: Colors.white,
                      Icons.copy,
                      size: 17,
                    ),
                  ],
                ),
        ),
      ),
    );
  });
}

Widget membersWidget(BuildContext context, Map body_info) {
  // gets all the acc bal share maps for all members
  List<dynamic> members_list = body_info["acc_map"]["account_balance_shares"];
  return Container(
    width: width(context),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: ListView.builder(
        reverse: true,
        shrinkWrap: true,
        itemCount: members_list.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, i) => memberTile(context, members_list[i])),
  );
}

Widget counterWidget(BuildContext context, Map body_info) {
  double days_left =
      double.parse(body_info["acc_map"]["number_of_minutes_left"].toString()) /
          60 /
          24;

  double number_of_hours_left =
      double.parse("0.${days_left.toString().split(".")[1]}") * 24;

  double number_of_minutes_left =
      double.parse("0.${number_of_hours_left.toString().split(".")[1]}") * 60;
  return Container(
    width: width(context),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text.rich(
          TextSpan(
            text: days_left.toString().split(".")[0],
            children: [
              TextSpan(
                text: days_left == 1 ? " day " : " days ",
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  fontSize: 15,
                ),
              )
            ],
          ),
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 26,
          ),
        ),
        wGap(5),
        Text.rich(
          TextSpan(
            text: number_of_hours_left.toString().split(".")[0],
            children: [
              TextSpan(
                text: number_of_hours_left == 1 ? " hr " : " hrs ",
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  fontSize: 15,
                ),
              )
            ],
          ),
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 26,
          ),
        ),
        wGap(5),
        Text.rich(
          TextSpan(
            text: number_of_minutes_left.toString().split(".")[0],
            children: [
              TextSpan(
                text: number_of_minutes_left == 1 ? " min left" : " mins",
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  fontSize: 15,
                ),
              )
            ],
          ),
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 26,
          ),
        ),
      ],
    ),
  );
}

Widget dateJoinedWidget(BuildContext context, Map user_map) {
  bool is_map_owner = user_map["user_id"] == box("user_id");
  return Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Text(
      is_map_owner
          ? "You Joined ${timeago.format(DateTime.parse(user_map['date_user_joined_account']).toUtc().toLocal())}"
          : "Joined ${timeago.format(DateTime.parse(user_map["date_user_joined_account"]).toUtc().toLocal())}",
      textAlign: TextAlign.left,
      maxLines: 1,
      style: GoogleFonts.ubuntu(
        fontWeight: FontWeight.w300,
        color: Colors.grey[800],
        fontSize: 13,
      ),
    ),
  );
}

// ====================== Style widgets

Decoration memberTileAmountShareDeco() {
  return BoxDecoration(
    color: Colors.grey[200],
    borderRadius: const BorderRadius.all(
      Radius.circular(15),
    ),
  );
}

Decoration pageChangerDeco() {
  return BoxDecoration(
    color: Colors.grey[200],
    borderRadius: const BorderRadius.all(
      Radius.circular(20),
    ),
  );
}

Decoration innerPageChangerDeco(int current_index, int page_index) {
  return BoxDecoration(
    color: current_index == page_index ? Colors.white : Colors.transparent,
    borderRadius: const BorderRadius.all(
      Radius.circular(16),
    ),
  );
}

Decoration joinLinkDeco() {
  return BoxDecoration(
    color: Colors.grey[900]!,
    borderRadius: const BorderRadius.all(
      Radius.circular(20),
    ),
  );
}

Decoration balanceWidgetDeco() {
  return BoxDecoration(
    color: Colors.grey[200],
    borderRadius: const BorderRadius.all(
      Radius.circular(25),
    ),
  );
}

Decoration menuCardDeco() {
  return const BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(50),
      topLeft: Radius.circular(0),
    ),
  );
}

Decoration postMediaPreviewDeco() {
  return BoxDecoration(
    color: Colors.grey[100],
    borderRadius: const BorderRadius.all(
      Radius.circular(20),
    ),
  );
}
