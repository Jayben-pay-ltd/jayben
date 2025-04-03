// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'package:jayben/Home/elements/feed/componets/my_posts_tile.dart';
import '../../../drawer/elements/components/ProfileWidgets.dart';
import 'package:jayben/Home/components/cashier_card.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

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
                        text: "My Timeline Posts",
                        children: [
                          TextSpan(
                            text: "\nthese are your public transactions",
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
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget myPostsBody(BuildContext context) {
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
                  displacement: 20,
                  onRefresh: () async => value.getOnlyMyFeedTransactions(),
                  child: value.returnMyFeedPosts()!.isEmpty
                      ? noTimelinePostsWidget(context)
                      : ListView.builder(
                          addRepaintBoundaries: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: value.returnMyFeedPosts()!.length,
                          padding: const EdgeInsets.only(top: 15, bottom: 20),
                          itemBuilder: (__, i) {
                            Map post_map = value.returnMyFeedPosts()![i];
                            return MyPostsTile(post_map: post_map);
                          },
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
              "When you any make public transactions, \nyou will be able to see them here...",
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
