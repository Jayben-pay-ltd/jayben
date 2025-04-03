// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'package:jayben/Home/elements/drawer/elements/Settings.dart';
import 'package:jayben/Home/elements/feed/elements/my_posts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../drawer/elements/components/ProfileWidgets.dart';
import 'package:jayben/Home/elements/feed/my_contacts.dart';
import 'package:jayben/Home/components/cashier_card.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'feed_tile.dart';

Widget customAppBar(BuildContext context) {
  return Consumer<FeedProviderFunctions>(
    builder: (_, value, child) {
      return Positioned(
        top: 0,
        child: Container(
          decoration: appBarDeco(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: width(context),
                    decoration: appBarDeco(),
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                    child: Text.rich(
                      TextSpan(
                        text: "Timeline",
                        children: [
                          TextSpan(
                            text: "\nposts from your friends",
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                        fontSize: 20,
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
                    right: 20,
                    top: 5,
                    child: GestureDetector(
                      onTap: () async {
                        value.toggleIsLoading();
                        value.clearCurrentTimelimePrivacySettings();
                        await value.getCurrentTimelinePrivacySetting();
                        await value.getUploadedContacts();
                        value.toggleIsLoading();
                      },
                      child: SizedBox(
                        child: menuButtonWidget(context),
                      ),
                    ),
                  ),
                ],
              ),
              storiesRow(context)
            ],
          ),
        ),
      );
    },
  );
}

Widget feedBody(BuildContext context, ScrollController controller) {
  return Consumer<FeedProviderFunctions>(
    builder: (_, value, child) {
      return value.returnMyUploadedContactsWithoutJaybenAccs()!.isEmpty
          ? noContactsUploadedWidget(context)
          : RepaintBoundary(
              child: Container(
                color: Colors.white,
                width: width(context),
                alignment: Alignment.center,
                child: RefreshIndicator(
                  displacement: 140,
                  onRefresh: () async {
                    // plays refresh sound
                    await playSound('refresh.mp3');

                    return value.getFeedTransactions();
                  },
                  child: value.returnFeedTransactions()!.isEmpty
                      ? noTimelinePostsWidget(context)
                      : Scrollbar(
                          interactive: true,
                          controller: controller,
                          child: ListView.builder(
                            addRepaintBoundaries: true,
                            controller: controller,
                            physics: const BouncingScrollPhysics(),
                            itemCount: value.returnFeedTransactions()!.length,
                            padding:
                                const EdgeInsets.only(top: 120, bottom: 20),
                            itemBuilder: (__, i) {
                              Map post_map = value.returnFeedTransactions()![i];
                              return FeedTile(post_map: post_map);
                            },
                          ),
                        ),
                ),
              ),
            );
    },
  );
}

Widget storiesRow(BuildContext context) {
  return Consumer<FeedProviderFunctions>(
    builder: (_, value, child) {
      return value.returnHideStoryWidget()
          ? nothing()
          : value.returnMyContactsWithJaybenAccs()!.isEmpty
              ? noContactsWithJaybenAccsWidgetFeed(context)
              : AnimatedOpacity(
                  curve: Curves.bounceInOut,
                  duration: const Duration(seconds: 1),
                  opacity: !value.returnHideStoryWidget() ? 1.0 : 0.0,
                  child: SizedBox(
                    height: 108,
                    width: width(context),
                    child: RepaintBoundary(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(left: 10),
                          itemCount:
                              value.returnMyContactsWithJaybenAccs()!.length,
                          itemBuilder: (_, i) => storyWidget(context,
                              value.returnMyContactsWithJaybenAccs()![i]),
                        ),
                      ),
                    ),
                  ),
                );
    },
  );
}

Widget storyWidget(BuildContext context, Map contact_map) {
  return GestureDetector(
    onTap: () => changePage(context, const MyContactsPage()),
    child: Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.green[900],
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: contact_map["contacts_jayben_account_details"]
                          ["profile_image_url"] ==
                      ""
                  ? CircleAvatar(
                      radius: 29,
                      backgroundColor: Colors.grey[100],
                      backgroundImage: const AssetImage(
                        "assets/ProfileAvatar.png",
                      ),
                    )
                  : CircleAvatar(
                      radius: 29,
                      backgroundColor: Colors.grey[100],
                      backgroundImage: CachedNetworkImageProvider(
                        contact_map["contacts_jayben_account_details"]
                            ["profile_image_url"],
                      ),
                    ),
            ),
          ),
          hGap(10),
          Container(
            alignment: Alignment.center,
            width: width(context) * 0.18,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text(
              contact_map["contacts_display_name"],
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.w300,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget noContactsWithJaybenAccsWidgetFeed(BuildContext context) {
  return Container(
    height: 108,
    width: width(context),
    alignment: Alignment.center,
    child: Text(
      "Non of your contacts have Jayben yet.",
      style: googleStyle(
        color: Colors.grey[500]!,
        size: 16.5,
      ),
    ),
  );
}

Widget noContactsUploadedWidget(BuildContext context) {
  return Consumer<FeedProviderFunctions>(
    builder: (_, value, child) {
      return Container(
        width: width(context),
        height: height(context),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/friendship.png", height: 80),
            hGap(20),
            Text(
              "Enable Contacts to see transactions\nyour friends make",
              textAlign: TextAlign.center,
              style: googleStyle(
                color: Colors.grey[800]!,
                weight: FontWeight.w400,
                size: 16.5,
              ),
            ),
            hGap(10),
            Text(
              "When your friends make public transactions, \nyou will be able to spy on them here...",
              textAlign: TextAlign.center,
              style: googleStyle(
                color: Colors.grey[600]!,
                weight: FontWeight.w300,
                size: 12,
              ),
            ),
            hGap(20),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(
                  !box("Investments") ? Colors.grey : Colors.green,
                ),
              ),
              onPressed: () async {
                value.toggleIsLoading();
                await value.getContactsFromPhone();

                await value.getUploadedContacts();

                value.toggleIsLoading();

                showSnackBar(context, "Contacts list has been refresh.");
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: Text(
                  "Enable Contacts",
                  style: GoogleFonts.ubuntu(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}

Widget noTimelinePostsWidget(BuildContext context) {
  return Consumer<FeedProviderFunctions>(
    builder: (_, value, child) {
      return Container(
        width: width(context),
        height: height(context),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/friendship.png", height: 60),
            hGap(20),
            Text(
              "When your friends make public transactions, \nyou will be able to see them here...",
              textAlign: TextAlign.center,
              style: googleStyle(
                color: Colors.grey[600]!,
                weight: FontWeight.w300,
                size: 15,
              ),
            ),
            hGap(20),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(
                  Colors.black,
                ),
              ),
              onPressed: () => showBottomCard(context, cashierCard(context)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                child: Text(
                  "Make a transaction",
                  style: GoogleFonts.ubuntu(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}

Widget menuButtonWidget(BuildContext context) {
  return Consumer<FeedProviderFunctions>(
    builder: (_, value2, child) {
      return DropdownButtonHideUnderline(
        child: DropdownButton2(
          customButton: const Icon(
            Icons.more_vert_sharp,
            color: Colors.black,
            size: 25,
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
      );
    },
  );
}

Widget noPostPlaceHolder(context) {
  return Container(
    alignment: Alignment.center,
    height: height(context) * 0.8,
    padding: const EdgeInsets.symmetric(vertical: 30),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/newsfeed.png", height: 40, color: Colors.white70),
        hGap(10),
        Text("No Friend Posts", style: GoogleFonts.ubuntu(color: Colors.white)),
      ],
    ),
  );
}

class MenuItem {
  const MenuItem({
    required this.text,
  });

  final String text;
}

abstract class MenuItems {
  static const List<MenuItem> firstItems = [
    my_posts,
    my_contacts,
    goto_settings
  ];

  static const goto_settings = MenuItem(text: 'Settings');
  static const my_contacts = MenuItem(text: 'Contacts');
  static const my_posts = MenuItem(text: 'My Posts');

  static Widget buildItem(MenuItem item) {
    return Text(
      item.text,
      style: const TextStyle(
        color: Colors.black,
      ),
    );
  }

  static void onChanged(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.my_contacts:
        changePage(context, const MyContactsPage());
        break;
      case MenuItems.goto_settings:
        changePage(context, const SettingsPage());
        break;
      case MenuItems.my_posts:
        changePage(context, const MyPostsPage());
        break;
    }
  }
}
