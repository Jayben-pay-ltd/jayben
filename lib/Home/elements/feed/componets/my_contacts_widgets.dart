// ignore_for_file: non_constant_identifier_names
import 'package:jayben/Home/elements/drawer/elements/components/kyc_verification_widgets.dart';
import 'package:jayben/Home/elements/send_money/elements/components/select_receiver_widgets.dart';
import 'package:jayben/Home/elements/feed/elements/jayben_user_tile.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

Widget contactsCustomAppBar(BuildContext context) {
  return Consumer<FeedProviderFunctions>(
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
                      "Contacts",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ubuntu(
                        color: const Color.fromARGB(255, 54, 54, 54),
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
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
                    top: 5,
                    child: GestureDetector(
                      onTap: () async {
                        value.toggleIsLoading();
                        await value.getContactsFromPhone();

                        await value.getUploadedContacts();

                        value.toggleIsLoading();

                        showSnackBar(
                            context, "Contacts list has been refresh.");
                      },
                      child: value.returnIsLoading()
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 40, right: 10.0),
                              child: loadingIcon(
                                context,
                                color: Colors.black,
                              ),
                            )
                          : SizedBox(
                              child: Text(
                                "Refresh",
                                style: googleStyle(
                                  color: Colors.green,
                                  size: 20,
                                ),
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
                        onTap: () => value.changeContactsCurrentIndex(0),
                        child: Container(
                          width: width(context) * 0.43,
                          color: value.returnContactsCurrentIndex() == 1
                              ? Colors.transparent
                              : Colors.white,
                          alignment: Alignment.center,
                          child: Text(
                            "With Jayben (${value.returnMyContactsWithJaybenAccs()!.length})",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: value.returnContactsCurrentIndex() == 1
                                  ? Colors.grey[600]!
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      wGap(5),
                      GestureDetector(
                        onTap: () => value.changeContactsCurrentIndex(1),
                        child: Container(
                          width: width(context) * 0.43,
                          color: value.returnContactsCurrentIndex() == 0
                              ? Colors.transparent
                              : Colors.white,
                          alignment: Alignment.center,
                          child: Text(
                            "Invite",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: value.returnContactsCurrentIndex() == 0
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
              "Enable Contacts to interact with\nyour friends in-app",
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
                showSnackBar(context, "Please wait while contacts load.");

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

class ContactsBody extends StatelessWidget {
  const ContactsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProviderFunctions>(
      builder: (_, value, child) {
        return RepaintBoundary(
          child: Container(
            color: Colors.white,
            width: width(context),
            height: height(context),
            alignment: Alignment.center,
            child: value.returnMyUploadedContactsWithoutJaybenAccs()!.isEmpty
                ? noContactsUploadedWidget(context)
                : value.returnMyContactsWithJaybenAccs()!.isEmpty
                    ? ListView.builder(
                        addRepaintBoundaries: true,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 115, bottom: 20),
                        itemCount: value
                            .returnMyUploadedContactsWithoutJaybenAccs()!
                            .length,
                        itemBuilder: (_, i) => inviteContactTileWidget(
                          context,
                          value.returnMyUploadedContactsWithoutJaybenAccs()![i],
                        ),
                      )
                    : ListView.builder(
                        addRepaintBoundaries: true,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 115, bottom: 20),
                        itemCount:
                            value.returnMyContactsWithJaybenAccs()!.length,
                        itemBuilder: (__, i) {
                          Map current_contact_map =
                              value.returnMyContactsWithJaybenAccs()![i];
                          return JaybenUserTile(
                              contact_map: current_contact_map);
                        },
                      ),
          ),
        );
      },
    );
  }
}

class InviteBody extends StatelessWidget {
  const InviteBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProviderFunctions>(
      builder: (_, value, child) {
        return RepaintBoundary(
          child: Container(
            width: width(context),
            color: Colors.white,
            height: height(context),
            alignment: Alignment.center,
            child: value.returnMyUploadedContactsWithoutJaybenAccs()!.isEmpty
                ? noContactsUploadedWidget(context)
                : ListView.builder(
                    addRepaintBoundaries: true,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(top: 115, bottom: 20),
                    itemCount: value
                        .returnMyUploadedContactsWithoutJaybenAccs()!
                        .length,
                    itemBuilder: (_, i) => inviteContactTileWidget(
                      context,
                      value.returnMyUploadedContactsWithoutJaybenAccs()![i],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
