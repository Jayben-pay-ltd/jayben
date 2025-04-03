// ignore_for_file: non_constant_identifier_names
import 'package:jayben/Home/elements/drawer/elements/achievements_card.dart';
import 'package:jayben/Home/elements/drawer/elements/kyc_verification.dart';
import 'package:jayben/Home/elements/drawer/elements/pricing_card.dart';
import 'package:jayben/Home/elements/drawer/elements/feedback.dart';
import 'package:jayben/Home/elements/drawer/elements/help.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jayben/Home/elements/referrals/referrals.dart';
import 'package:jayben/Home/elements/admin/admin_page.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'elements/MyQRCode.dart';
import 'elements/Settings.dart';
import 'elements/Profile.dart';
import 'dart:io';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 70.0, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                goBack(context);
                changePage(context, const ProfilePage());
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[100]!,
                      Colors.grey[200]!,
                    ],
                  ),
                ),
                padding: const EdgeInsets.only(left: 12, top: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    box("profile_image_url") == ""
                        ? const CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.transparent,
                            backgroundImage: AssetImage(
                              "assets/ProfileAvatar.png",
                            ),
                          )
                        : CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            backgroundImage: CachedNetworkImageProvider(
                              box("profile_image_url"),
                            ),
                          ),
                    wGap(10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        fullNamesWidget(),
                        hGap(4),
                        Text(
                          ["Agent", "Merchant"].contains(box("AccountType"))
                              ? '${box("AccountType")} account'
                              : '@${box('Username_searchable')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w300,
                            color: Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ["Agent"].contains(box("AccountType"))
                        ? nothing()
                        : GestureDetector(
                            onTap: () =>
                                changePage(context, const UserQRCodePage()),
                            child: Icon(
                              Icons.qr_code_scanner,
                              color: Colors.grey[600]!,
                              size: 25,
                            ),
                          ),
                    wGap(15)
                  ],
                ),
              ),
            ),
            ["Agent", "Merchant"].contains(box("AccountType"))
                ? nothing()
                : ListTile(
                    horizontalTitleGap: 0,
                    leading: const Icon(Icons.emoji_events),
                    title: Text('Achievements',
                        style: GoogleFonts.ubuntu(fontSize: 15)),
                    onTap: () =>
                        showBottomCard(context, const AchievementsCard()),
                  ),
            box("isVerified")
                ? nothing()
                : ListTile(
                    horizontalTitleGap: 0,
                    leading: const Icon(Icons.verified_sharp),
                    title: Text('Verification',
                        style: GoogleFonts.ubuntu(fontSize: 15)),
                    onTap: () =>
                        changePage(context, const KycVerificationPage()),
                  ),
            ["Agent", "Merchant"].contains(box("AccountType"))
                ? nothing()
                : ListTile(
                    horizontalTitleGap: 0,
                    leading: const Icon(Icons.monetization_on_rounded),
                    title: Text('Earn Cash',
                        style: GoogleFonts.ubuntu(fontSize: 15)),
                    onTap: () => changePage(context, const ReferralsPage()),
                  ),
            ListTile(
                horizontalTitleGap: 0,
                leading: const Icon(Icons.settings),
                title:
                    Text('Settings', style: GoogleFonts.ubuntu(fontSize: 15)),
                onTap: () => changePage(context, const SettingsPage())),
            ![...box("UsersCapableOfSeeingSecretDashboard")]
                    .contains(box("user_id"))
                ? nothing()
                : ListTile(
                    horizontalTitleGap: 0,
                    leading: const Icon(Icons.space_dashboard),
                    title:
                        Text('Admin', style: GoogleFonts.ubuntu(fontSize: 15)),
                    onTap: () => changePage(context, const AdminPage())),
            const Spacer(),
            ["Agent", "Merchant"].contains(box("AccountType"))
                ? nothing()
                : ListTile(
                    title: Text('Give us feedback',
                        style: GoogleFonts.ubuntu(fontSize: 15)),
                    onTap: () => changePage(context, const FeedbackPage()),
                  ),
            ListTile(
                title:
                    Text('Need Help?', style: GoogleFonts.ubuntu(fontSize: 15)),
                onTap: () => changePage(context, const HelpPage())),
            ["Agent", "Merchant"].contains(box("AccountType"))
                ? nothing()
                : ListTile(
                    title: Text('Our Fees',
                        style: GoogleFonts.ubuntu(fontSize: 15)),
                    onTap: () => showBottomCard(context, const PricingCard()),
                  ),
            hGap(Platform.isIOS ? 20 : 0),
          ],
        ),
      ),
    );
  }

  Widget fullNamesWidget() {
    return box("isVerified")
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${box('FirstName')} ${box('LastName')}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
              wGap(2.5),
              Image.asset("assets/verify.png", height: 15)
            ],
          )
        : Text(
            '${box('FirstName')} ${box('LastName')}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontSize: 15,
            ),
          );
  }
}
