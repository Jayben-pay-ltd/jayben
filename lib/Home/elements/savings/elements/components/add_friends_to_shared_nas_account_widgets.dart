// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jayben/Home/elements/feed/my_contacts.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:share_plus/share_plus.dart';
import '../../../drawer/elements/components/ProfileWidgets.dart';

Widget addFriendsAppBar(BuildContext context, controller) {
  return Consumer<SavingsProviderFunctions>(builder: (_, value, child) {
    return Positioned(
      top: 0,
      child: Column(
        children: [
          Container(
            width: width(context),
            decoration: appBarDeco(),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                wGap(10),
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
                wGap(23),
                Text.rich(
                  const TextSpan(text: "Add Friend"),
                  textAlign: TextAlign.left,
                  style: GoogleFonts.ubuntu(
                    color: const Color.fromARGB(255, 54, 54, 54),
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    if (controller.text.isEmpty) {
                      showSnackBar(context, "enter a username");
                      return;
                    }

                    hideKeyboard();

                    value.toggleIsLoading();

                    // gets a list of results of people that have that username
                    List<dynamic> results =
                        await value.searchUsernameInDB(controller.text);

                    value.toggleIsLoading();

                    if (results.isEmpty) {
                      showSnackBar(
                          context, "Nobody with that username was found");
                    }
                  },
                  child: SizedBox(
                    child: value.returnIsLoading()
                        ? Padding(
                            padding:
                                const EdgeInsets.only(left: 30, right: 10.0),
                            child: loadingIcon(context, color: Colors.black))
                        : Text(
                            "Search",
                            style: googleStyle(
                              color: Colors.green,
                              size: 20,
                            ),
                          ),
                  ),
                ),
                wGap(10),
              ],
            ),
          ),
          usernameTextfield(context, controller),
        ],
      ),
    );
  });
}

Widget addFriendsBody(BuildContext context, Map account_map) {
  return Consumer2<SavingsProviderFunctions, FeedProviderFunctions>(
    builder: (_, value, value1, child) {
      return GestureDetector(
        onTap: () => hideKeyboard(),
        child: SizedBox(
          width: width(context),
          height: height(context),
          child: value.returnIsLoading()
              ? loadingScreenPlainNoBackButton(context)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    value.returnUsernameSearchResults().isEmpty
                        ? nothing()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            padding:
                                const EdgeInsets.only(top: 125, bottom: 20),
                            itemCount:
                                value.returnUsernameSearchResults().length,
                            itemBuilder: (_, i) {
                              print(value.returnUsernameSearchResults()[i]);
                              return userTileWidget(
                                context,
                                {
                                  "user_map":
                                      value.returnUsernameSearchResults()[i],
                                  "account_map": account_map,
                                },
                              );
                            },
                          ),
                    value.returnUsernameSearchResults().isEmpty
                        ? nothing()
                        : Divider(
                            color: Colors.grey[500],
                            thickness: 0.2,
                          ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 20.0,
                          right: 19,
                          top: value.returnUsernameSearchResults().isEmpty
                              ? 125
                              : 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select from contacts",
                            style: googleStyle(
                              color: Colors.grey[600]!,
                              size: 18,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                changePage(context, const MyContactsPage()),
                            child: SizedBox(
                              child: Text(
                                "Contact Settings",
                                style: GoogleFonts.ubuntu(
                                  decoration: TextDecoration.underline,
                                  color: Colors.black,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    value1.returnMyContactsWithJaybenAccs() == null
                        ? nothing()
                        : value1
                                .returnMyUploadedContactsWithoutJaybenAccs()!
                                .isEmpty
                            ? noContactsUploadedWidget(context)
                            : value1.returnMyContactsWithJaybenAccs()!.isEmpty
                                ? Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, bottom: 0),
                                      child: MediaQuery.removePadding(
                                        context: context,
                                        removeTop: true,
                                        child: ListView.builder(
                                          // shrinkWrap: true,
                                          addRepaintBoundaries: true,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: value1
                                              .returnMyUploadedContactsWithoutJaybenAccs()!
                                              .length,
                                          itemBuilder: (_, i) =>
                                              inviteContactTileWidget(
                                            context,
                                            value1.returnMyUploadedContactsWithoutJaybenAccs()![
                                                i],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, bottom: 0),
                                      child: MediaQuery.removePadding(
                                        context: context,
                                        removeTop: true,
                                        removeBottom: true,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          addRepaintBoundaries: true,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          itemCount: value1
                                              .returnMyContactsWithJaybenAccs()!
                                              .length,
                                          itemBuilder: (_, i) => contactTileWidget(
                                              context,
                                              value1.returnMyContactsWithJaybenAccs()![
                                                  i],
                                              account_map),
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

Widget noContactsUploadedWidget(BuildContext context) {
  return GestureDetector(
    onTap: () => hideKeyboard(),
    child: Container(
      alignment: Alignment.center,
      height: height(context) * 0.7,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset("assets/group_of_people.png", height: 90),
          hGap(20),
          Text(
            "Add a friend so you can together",
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w700,
              color: Colors.black,
              fontSize: 15,
            ),
          ),
          hGap(8),
          Text(
            "Save For Vacations 🏖, Birthdays 🎁 or New Years 🍷",
            textAlign: TextAlign.center,
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 13,
            ),
          ),
          hGap(10),
          Text(
            "When the timer is up, the money saved up"
            "\nis sent back according to how much"
            "\neach person contributed...",
            textAlign: TextAlign.center,
            style: googleStyle(
              color: Colors.black54,
              size: 15,
            ),
          ),
          hGap(20),
          joinAccountLinkWidget(context)
        ],
      ),
    ),
  );
}

Widget userTileWidget(BuildContext context, Map body_info) {
  return Consumer<SavingsProviderFunctions>(builder: (_, value, child) {
    return Container(
      width: width(context),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          body_info["user_map"]["profile_image_url"] == ""
              ? const CircleAvatar(
                  radius: 27,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage(
                    "assets/ProfileAvatar.png",
                  ),
                )
              : CircleAvatar(
                  radius: 27,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: CachedNetworkImageProvider(
                    body_info["user_map"]["profile_image_url"],
                  ),
                ),
          wGap(15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${body_info["user_map"]["first_name"]} ${body_info["user_map"]["last_name"]}",
                style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w600, fontSize: 20),
              ),
              hGap(5),
              Text(
                "@${body_info["user_map"]["username_searchable"]}",
                style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w300, fontSize: 15),
              )
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              if (value.returnIsLoading()) {
                showSnackBar(context, "Adding friend... Please wait patiently");
                return;
              }

              value.toggleIsAddingFriend();

              // adds selected friend to the list
              await value.addPersonToSharedNasAccount({
                "account_map": body_info["account_map"],
                "user_map": body_info["user_map"],
                "context": context,
              });

              value.toggleIsAddingFriend();
            },
            child: SizedBox(
              child: value.returnIsAddingFriend()
                  ? Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: loadingIcon(context, color: Colors.orange))
                  : Text(
                      "ADD",
                      style: googleStyle(
                        weight: FontWeight.w400,
                        color: Colors.orange,
                        size: 18,
                      ),
                    ),
            ),
          )
        ],
      ),
    );
  });
}

Widget contactTileWidget(
    BuildContext context, Map contact_map, Map account_map) {
  return Consumer2<SavingsProviderFunctions, FeedProviderFunctions>(
      builder: (_, value, value1, child) {
    return Container(
      width: width(context),
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          contact_map["contacts_jayben_account_details"]["profile_image_url"] ==
                  ""
              ? CircleAvatar(
                  radius: 27,
                  backgroundColor: Colors.grey[100],
                  backgroundImage: const AssetImage(
                    "assets/ProfileAvatar.png",
                  ),
                )
              : CircleAvatar(
                  radius: 27,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: CachedNetworkImageProvider(
                    contact_map["contacts_jayben_account_details"]
                        ["profile_image_url"],
                  ),
                ),
          wGap(15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: width(context) * 0.6,
                child: Text(
                  contact_map["contacts_display_name"],
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ),
              hGap(5),
              Text(
                "@${contact_map["contacts_jayben_account_details"]["username_searchable"]}",
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w300,
                  color: Colors.green[700],
                  fontSize: 15,
                ),
              )
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              if (value.returnIsLoading()) {
                showSnackBar(context, "Adding friend... Please wait patiently");
                return;
              }

              value.toggleIsAddingFriend();

              // adds selected friend to the list
              await value.addPersonToSharedNasAccount({
                "user_map": contact_map["contacts_jayben_account_details"],
                "account_map": account_map,
                "context": context,
              });

              value.toggleIsAddingFriend();
            },
            child: SizedBox(
              child: Text(
                "ADD",
                style: googleStyle(
                  weight: FontWeight.w400,
                  color: Colors.orange,
                  size: 18,
                ),
              ),
            ),
          )
        ],
      ),
    );
  });
}

Widget inviteContactTileWidget(BuildContext context, Map contact_map) {
  return Consumer2<PaymentProviderFunctions, FeedProviderFunctions>(
      builder: (_, value, value1, child) {
    return Container(
      width: width(context),
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Colors.grey[100],
            backgroundImage: const AssetImage(
              "assets/ProfileAvatar.png",
            ),
          ),
          wGap(15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: width(context) * 0.6,
                child: Text(
                  contact_map["contacts_display_name"],
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
              ),
              hGap(5),
              Text(
                "Invite to Jayben",
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w300,
                  color: Colors.green[700],
                  fontSize: 15,
                ),
              )
            ],
          ),
          const Spacer(),
          GestureDetector(
            //   onTap: () async => Share.share(
            //       "Hi, have you tried out this app called Jayben? I've been using it to save money and its really cool."),
            child: SizedBox(
              child: Text(
                "INVITE",
                style: googleStyle(
                  weight: FontWeight.w400,
                  color: Colors.green,
                  size: 18,
                ),
              ),
            ),
          )
        ],
      ),
    );
  });
}

Widget joinAccountLinkWidget(BuildContext context) {
  return Consumer<FeedProviderFunctions>(builder: (_, value, child) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        backgroundColor: MaterialStateProperty.all(
          !box("nas_deposits_are_allowed") ? Colors.grey : Colors.green,
        ),
      ),
      onPressed: () async {
        value.toggleIsLoading();
        await value.getContactsFromPhone();

        await context.read<FeedProviderFunctions>().getUploadedContacts();

        value.toggleIsLoading();

        showSnackBar(context, "Contacts have been enabled");
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
        child: value.returnIsLoading()
            ? loadingIcon(context)
            : Text(
                "Enable Contacts",
                style: GoogleFonts.ubuntu(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
      ),
    );
  });
}

Widget usernameTextfield(BuildContext context, controller) {
  return Consumer<SavingsProviderFunctions>(builder: (_, value, child) {
    return SizedBox(
      width: width(context),
      child: TextField(
        cursorHeight: 24,
        cursorColor: Colors.grey[400],
        maxLines: 1,
        onChanged: (String? text) async {
          await value.searchUsernameInDB(text!);
        },
        keyboardType: TextInputType.text,
        inputFormatters: [
          FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
        ],
        textAlign: TextAlign.left,
        style: GoogleFonts.ubuntu(
          fontWeight: FontWeight.w400,
          color: Colors.black,
          fontSize: 24,
        ),
        controller: controller,
        decoration: InputDecoration(
          hintText: "Enter their username here",
          isDense: true,
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.fromLTRB(12, 15, 12, 15),
          border: const UnderlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide.none,
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide.none,
          ),
          disabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide.none,
          ),
          hintStyle: GoogleFonts.ubuntu(
            color: Colors.grey[500],
            fontSize: 22,
          ),
        ),
      ),
    );
  });
}

// ================= styling widgets

Decoration addFriendJoinLinkDeco() {
  return BoxDecoration(
    color: Colors.grey[700]!,
    borderRadius: const BorderRadius.all(
      Radius.circular(20),
    ),
  );
}
