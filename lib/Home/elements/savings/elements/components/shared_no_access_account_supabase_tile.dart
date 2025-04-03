// ignore_for_file: non_constant_identifier_names
import 'package:jayben/Home/elements/savings/elements/components/shared_nas_account_menu_card.dart';
import 'package:jayben/Home/elements/savings/elements/add_friend_to_shared_nas_account.dart';
import 'package:jayben/Home/elements/savings/elements/shared_nas_account_details_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:signed_spacing_flex/signed_spacing_flex.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../add_money_to_savings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SharedNoAccessSavAccTileSupabase extends StatelessWidget {
  const SharedNoAccessSavAccTileSupabase({Key? key, required this.account_info})
      : super(key: key);

  final Map account_info;

  @override
  Widget build(BuildContext context) {
    double amount = double.parse(account_info["balance"].toString());

    double days_left =
        double.parse(account_info["number_of_minutes_left"].toString()) /
            60 /
            24;

    double number_of_hours_left =
        double.parse("0.${days_left.toString().split(".")[1]}") * 24;

    double number_of_minutes_left =
        double.parse("0.${number_of_hours_left.toString().split(".")[1]}") * 60;
    return Stack(
      children: [
        GestureDetector(
          onTap: () async => showCupertinoModalPopup(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) =>
                  SharedNasAccDetailsCard(account_map: account_info)),
          child: Container(
            width: width(context),
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 30),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                account_info["number_of_members"] == 1
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/lock.png",
                            color: Colors.grey[600],
                            height: 15,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "No Access Savings Account",
                            style: GoogleFonts.ubuntu(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                        ],
                      )
                    : account_info["account_balance_shares"].length > 7
                        ? multipMemberImagesWidget(context, account_info)
                        : memberImagesWidget(context, account_info),
                hGap(10),
                Text(
                  account_info["account_name"],
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                    fontSize: 25,
                  ),
                ),
                hGap(15),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: "${account_info["currency"]} ",
                      children: [
                        TextSpan(
                          text: amount.toStringAsFixed(2),
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                            fontSize: 26,
                          ),
                        )
                      ],
                    ),
                    style: GoogleFonts.ubuntu(
                      color: Colors.grey[700],
                      fontSize: 20,
                    ),
                  ),
                ),
                hGap(15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: days_left.toString().split(".")[0],
                        children: [
                          TextSpan(
                            text: days_left == 1 ? " day " : " days ",
                            style: GoogleFonts.ubuntu(
                              color: Colors.grey[500],
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
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
                              color: Colors.grey[500],
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        fontSize: 26,
                      ),
                    ),
                    wGap(5),
                    Text.rich(
                      TextSpan(
                        text: number_of_minutes_left.toString().split(".")[0],
                        children: [
                          TextSpan(
                            text: number_of_minutes_left == 1
                                ? " min left"
                                : " mins left",
                            style: GoogleFonts.ubuntu(
                              color: Colors.grey[500],
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                        fontSize: 26,
                      ),
                    ),
                  ],
                ),
                hGap(20),
                GestureDetector(
                  onTap: () => changePage(
                    context,
                    TransferToSavingsPage(
                      accountName: account_info["account_name"],
                      accountID: account_info["account_id"],
                      backendType: "Supabase",
                      accountType: "Shared",
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[300],
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, color: Colors.white),
                        wGap(5),
                        Text(
                          "add money",
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                hGap(10),
                GestureDetector(
                  onTap: () => changePage(
                    context,
                    AddFriendPage(account_map: account_info),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.grey[400]!,
                          Colors.grey[500]!,
                        ],
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_2, color: Colors.white),
                        wGap(5),
                        Text(
                          "add friend",
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        menuButtom(context, account_info)
      ],
    );
  }

  Widget menuButtom(BuildContext context, Map account_map) {
    return Positioned(
      top: 45,
      right: 10,
      child: GestureDetector(
        onTap: () => showBottomCard(
          context,
          SharedNasAccountMenuCard(account_map: account_map),
        ),
        child: Container(
          color: Colors.transparent,
          height: 40,
          width: 40,
          child: const Icon(
            Icons.more_vert_rounded,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget memberImagesWidget(BuildContext context, Map body_info) {
    // gets all the acc bal share maps for all members
    List<dynamic> members_list = body_info["account_balance_shares"];
    return Container(
      width: width(context) * 0.7,
      alignment: Alignment.center,
      child: SignedSpacingRow(
        spacing: -16.0,
        mainAxisSize: MainAxisSize.min,
        stackingOrder: StackingOrder.lastOnTop,
        children: [
          for (var i = 0; i < members_list.length; i++)
            imageWidget(members_list[i]["profile_image_url"])
        ],
      ),
    );
  }

  Widget multipMemberImagesWidget(BuildContext context, Map body_info) {
    // gets all the acc bal share maps for all members
    List<dynamic> members_list = body_info["account_balance_shares"];
    return Container(
      width: width(context) * 0.7,
      alignment: Alignment.center,
      child: SignedSpacingRow(
        spacing: -16.0,
        mainAxisSize: MainAxisSize.min,
        stackingOrder: StackingOrder.lastOnTop,
        children: [
          for (var i = 0; i < 7; i++)
            imageWidget(members_list[i]["profile_image_url"]),
          remainingImagesCountWidget(members_list.length - 7)
        ],
      ),
    );
  }

  Widget remainingImagesCountWidget(int remaning_number) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey[200],
      child: CircleAvatar(
        radius: 19,
        backgroundColor: Colors.grey[600],
        child: Text(
          "+$remaning_number",
          style: googleStyle(
            weight: FontWeight.w800,
            color: Colors.white,
            size: 14,
          ),
        ),
      ),
    );
  }

  Widget imageWidget(String profile_image_url) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey[200],
      child: profile_image_url == ""
          ? const CircleAvatar(
              radius: 19,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(
                "assets/ProfileAvatar.png",
              ),
            )
          : CircleAvatar(
              radius: 19,
              backgroundColor: Colors.white,
              backgroundImage: CachedNetworkImageProvider(profile_image_url),
            ),
    );
  }
}
