// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jayben/Home/home_page.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:signed_spacing_flex/signed_spacing_flex.dart';
import 'package:cached_network_image/cached_network_image.dart';

class JoinSharedNasAccountCard extends StatefulWidget {
  const JoinSharedNasAccountCard({super.key, required this.account_id});

  final String account_id;

  @override
  State<JoinSharedNasAccountCard> createState() =>
      _JoinSharedNasAccountCardState();
}

class _JoinSharedNasAccountCardState extends State<JoinSharedNasAccountCard> {
  @override
  void initState() {
    super.initState();
    onDialogueLoad();
  }

  /// gets the account's details as Map
  Future<void> onDialogueLoad() async {
    Map result = await context
        .read<SavingsProviderFunctions>()
        .getSharedNasAccountDetails(widget.account_id);

    if (!mounted) return;

    setState(() => account_map = result);
  }

  Map? account_map;

  @override
  Widget build(BuildContext context) {
    return Consumer2<SavingsProviderFunctions, HomeProviderFunctions>(
        builder: (_, value, value1, child) {
      return SizedBox(
        width: width(context),
        child: account_map == null
            ? Container(
                width: width(context),
                decoration: cardDeco(),
                alignment: Alignment.center,
                height: height(context) * 0.3,
                child: loadingIcon(context, color: Colors.black),
              )
            : Builder(builder: (_) {
                double amount =
                    double.parse(account_map!["balance"].toString());

                double days_left = double.parse(
                        account_map!["number_of_minutes_left"].toString()) /
                    60 /
                    24;

                double number_of_hours_left =
                    double.parse("0.${days_left.toString().split(".")[1]}") *
                        24;

                double number_of_minutes_left = double.parse(
                        "0.${number_of_hours_left.toString().split(".")[1]}") *
                    60;
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
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        account_map!["number_of_members"] == 1
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
                            : account_map!["account_balance_shares"].length > 7
                                ? multipMemberImagesWidget(context)
                                : memberImagesWidget(context),
                        hGap(10),
                        Text(
                          account_map!["account_name"],
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ubuntu(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                            fontSize: 30,
                          ),
                        ),
                        hGap(20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 3, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Text.rich(
                            TextSpan(
                              text: "${account_map!["currency"]} ",
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
                                text: number_of_hours_left
                                    .toString()
                                    .split(".")[0],
                                children: [
                                  TextSpan(
                                    text: number_of_hours_left == 1
                                        ? " hr "
                                        : " hrs ",
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
                                text: number_of_minutes_left
                                    .toString()
                                    .split(".")[0],
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
                        Divider(
                          color: Colors.grey[400],
                          thickness: 0.4,
                        ),
                        hGap(15),
                        Text(
                          "PLEASE NOTE",
                          textAlign: TextAlign.center,
                          style: googleStyle(
                            color: Colors.grey[800]!,
                            weight: FontWeight.w700,
                            size: 20,
                          ),
                        ),
                        hGap(20),
                        Text(
                          "When the timer is up, the money saved up is sent"
                          "\nback to you according to what you contributed. \n\n*THE OWNER DOESN'T KEEP YOUR MONEY",
                          textAlign: TextAlign.center,
                          style: googleStyle(
                            color: Colors.black,
                            size: 15,
                          ),
                        ),
                        hGap(20),
                        ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all(
                                account_map!["user_ids_able_to_view_accounts"]
                                        .contains(box("user_id"))
                                    ? Colors.green[300]
                                    : Colors.green),
                          ),
                          onPressed: () async {
                            if (!account_map!["is_active"]) {
                              showSnackBar(context,
                                  "This no access account is not active");

                              goBack(context);
                              return;
                            }

                            if (value.returnIsAddingFriend()) return;

                            value.toggleIsAddingFriend();

                            // adds selected friend to the list
                            bool has_joined = await value.joinSharedNasAccount(
                                account_map!["account_id"]);

                            if (has_joined) {
                              showSnackBar(context, "Group NAS Account joined",
                                  color: Colors.grey[600]!);

                              changePage(context, const HomePage(), type: "pr");
                            } else {
                              showSnackBar(
                                  context, "Failed to join group NAS Account");
                            }

                            value.toggleIsAddingFriend();
                          },
                          child: Container(
                            width: width(context) * 0.5,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: value.returnIsAddingFriend()
                                ? loadingIcon(context)
                                : Text(
                                    "Join No Access Account",
                                    style: GoogleFonts.ubuntu(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
      );
    });
  }

  Widget memberImagesWidget(BuildContext context) {
    // gets all the acc bal share maps for all members
    List<dynamic> members_list = account_map!["account_balance_shares"];
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

  Widget multipMemberImagesWidget(BuildContext context) {
    // gets all the acc bal share maps for all members
    List<dynamic> members_list = account_map!["account_balance_shares"];
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
