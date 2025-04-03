// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/feed/my_contacts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../drawer/elements/components/ProfileWidgets.dart';
import 'package:jayben/Home/elements/send_money/send_money_confirmation_username.dart';

Widget selectReceiversAppBar(BuildContext context, controller) {
  return Consumer<PaymentProviderFunctions>(builder: (_, value, child) {
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
                wGap(10),
                Text.rich(
                  const TextSpan(text: "Send to who?"),
                  textAlign: TextAlign.left,
                  style: GoogleFonts.ubuntu(
                    color: const Color.fromARGB(255, 54, 54, 54),
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                const Spacer(),
                Text(
                  "${box("CurrencySymbol")}${double.parse(value.returnAmountString()).toStringAsFixed(2)}",
                  style: googleStyle(
                    color: Colors.green,
                    size: 20,
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

Widget selectReceiversBody(BuildContext context) {
  return Consumer2<PaymentProviderFunctions, FeedProviderFunctions>(
    builder: (_, value, value1, child) {
      return GestureDetector(
        onTap: () => hideKeyboard(),
        child: SizedBox(
          width: width(context),
          height: height(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              value.returnUsernameSearchResults().isEmpty
                  ? nothing()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 125, bottom: 10),
                      itemCount: value.returnUsernameSearchResults().length,
                      itemBuilder: (_, i) => userTileWidget(
                        context,
                        value.returnUsernameSearchResults()[i],
                      ),
                    ),
              value.returnUsernameSearchResults().isEmpty
                  ? nothing()
                  : Divider(
                      color: Colors.grey[500],
                      thickness: 0.2,
                    ),
              // Padding(
              //   padding: EdgeInsets.only(
              //       left: 20.0,
              //       right: 19,
              //       top:
              //           value.returnUsernameSearchResults().isEmpty ? 125 : 15),
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(
              //         "Select from contacts",
              //         style: googleStyle(
              //           color: Colors.grey[600]!,
              //           size: 18,
              //         ),
              //       ),
              //       GestureDetector(
              //         onTap: () => changePage(context, const MyContactsPage()),
              //         child: SizedBox(
              //           child: Text(
              //             "Contact Settings",
              //             style: GoogleFonts.ubuntu(
              //               decoration: TextDecoration.underline,
              //               color: Colors.black,
              //               fontSize: 15,
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              value1.returnMyContactsWithJaybenAccs() == null
                  ? nothing()
                  : value1.returnMyUploadedContactsWithoutJaybenAccs()!.isEmpty
                      ? noContactsUploadedWidget(context)
                      : value1.returnMyContactsWithJaybenAccs()!.isEmpty
                          ? Flexible(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 20),
                                child: MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  child: ListView.builder(
                                    // shrinkWrap: true,
                                    addRepaintBoundaries: true,
                                    physics: const BouncingScrollPhysics(),
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
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 20),
                                child: MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  removeBottom: true,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    addRepaintBoundaries: true,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: value1
                                        .returnMyContactsWithJaybenAccs()!
                                        .length,
                                    itemBuilder: (_, i) => contactTileWidget(
                                      context,
                                      value1
                                          .returnMyContactsWithJaybenAccs()![i],
                                    ),
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

Widget userTileWidget(BuildContext context, Map body_info) {
  return Consumer<PaymentProviderFunctions>(builder: (_, value, child) {
    return Container(
      width: width(context),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          body_info["profile_image_url"] == ""
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
                    body_info["profile_image_url"],
                  ),
                ),
          wGap(15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${body_info["first_name"]} ${body_info["last_name"]}",
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              hGap(5),
              Text(
                "@${body_info["username_searchable"]}",
                style: GoogleFonts.ubuntu(
                  fontWeight: FontWeight.w300,
                  fontSize: 15,
                ),
              )
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              // route user to payment confirmation page
              changePage(
                context,
                PaymentConfirmationUsernamePage(
                  paymentInfo: {
                    "amount": double.parse(value.returnAmountString()),
                    "payment_means": "Username",
                    "receiver_map": body_info,
                  },
                ),
              );
            },
            child: SizedBox(
              child: Text(
                "SEND",
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

Widget contactTileWidget(BuildContext context, Map contact_map) {
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
              // route user to payment confirmation page
              changePage(
                context,
                PaymentConfirmationUsernamePage(
                  paymentInfo: {
                    "receiver_map":
                        contact_map["contacts_jayben_account_details"],
                    "amount": double.parse(value.returnAmountString()),
                    "payment_means": "Username",
                  },
                ),
              );
            },
            child: SizedBox(
              child: Text(
                "SEND",
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
              // onTap: () async => Share.share(
              //     "Hi ${contact_map["contacts_display_name"].split(" ")[0]}, have you tried out this app called Jayben? "
              //     "I've been using it to save money and its really cool."),
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
    },
  );
}

Widget usernameTextfield(BuildContext context, controller) {
  return Consumer<PaymentProviderFunctions>(
    builder: (_, value, child) {
      return SizedBox(
        width: width(context),
        child: TextField(
          cursorHeight: 24,
          cursorColor: Colors.grey[400],
          maxLines: 1,
          onChanged: (String? text) async {
            await value.searchUsername(text!);
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
            suffixIcon: GestureDetector(
              onTap: () async {
                if (controller.text.isEmpty) {
                  showSnackBar(context, "enter a username");
                  return;
                }

                hideKeyboard();

                value.toggleIsLoading();

                // gets a list of results of people that have that username
                List<dynamic> results =
                    await value.searchUsername(controller.text);

                value.toggleIsLoading();

                if (results.isEmpty) {
                  showSnackBar(context, "Nobody with that username was found");
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: value.returnIsLoading()
                    ? Padding(
                        padding: const EdgeInsets.only(left: 30, right: 10.0),
                        child: loadingWidget(context))
                    : Icon(
                        color: Colors.grey[500],
                        Icons.search,
                        size: 25,
                      ),
              ),
            ),
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
    },
  );
}

Widget noContactsUploadedWidget(BuildContext context) {
  return Consumer<FeedProviderFunctions>(
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
            Image.asset("assets/friendship.png", height: 80),
            hGap(20),
            Text(
              "Enable Contacts\nto send cash to your friends",
              textAlign: TextAlign.center,
              style: googleStyle(
                color: Colors.grey[800]!,
                weight: FontWeight.w400,
                size: 16.5,
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

                showSnackBar(context, "Contacts have been enabled");
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
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
            )
          ],
        ),
      );
    },
  );
}

Widget loadingWidget(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    height: 5,
    width: 20,
    child: Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.grey[500],
      ),
    ),
  );
}

// ================= styling widgets

Decoration selectReceiverJoinLinkDeco() {
  return BoxDecoration(
    color: Colors.grey[700]!,
    borderRadius: const BorderRadius.all(
      Radius.circular(20),
    ),
  );
}
