// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
import 'package:jayben/Home/elements/feed/elements/view_photo_post.dart';
import 'package:jayben/Home/elements/feed/elements/view_video_post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

Widget myPostTileBody(BuildContext context, Map post_map) {
  return SizedBox(
    width: width(context),
    child: Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    profilephotoWidget(post_map),
                    wGap(12),
                    nameAndDateWidget(context, post_map)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 65.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      postCaption(context, post_map),
                      postMediaPreviewWidget(context, post_map),
                      reactionWidgets(context, post_map),
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Divider(
                          color: Colors.grey[300],
                          thickness: 0.5,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        deletePostButton(context, post_map)
      ],
    ),
  );
}

Widget deletePostButton(BuildContext context, Map post_map) {
  return Consumer<FeedProviderFunctions>(
    builder: (_, value, child) {
      return Positioned(
        right: 20,
        top: 0,
        child: GestureDetector(
          onTap: () async {
            value.toggleIsLoading();

            await value.deletePost(post_map['post_id']);
            await value.getOnlyMyFeedTransactions();

            value.toggleIsLoading();

            showSnackBar(context, "Post Deleted", duration: 5);
          },
          child: SizedBox(
            child: Icon(
              Icons.delete_forever_rounded,
              color: Colors.red[900],
              size: 30,
            ),
          ),
        ),
      );
    },
  );
}

Widget profilephotoWidget(Map post_map) {
  return Stack(
    children: [
      Container(
        child: post_map["post_owner_details"]["profile_image_url"] == "" ||
                post_map["post_owner_details"]["profile_image_url"] == null
            ? Image.asset(
                "assets/ProfileAvatar.png",
                color: Colors.grey[300],
                height: 48,
              )
            : CircleAvatar(
                radius: 25,
                backgroundColor: Colors.grey[200],
                backgroundImage: CachedNetworkImageProvider(
                  post_map["post_owner_details"]["profile_image_url"],
                ),
              ),
      ),
      !post_map["post_owner_details"]["account_kyc_is_verified"]
          ? nothing()
          : Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.white,
                child: Image.asset(
                  "assets/verify.png",
                  height: 20,
                ),
              ),
            )
    ],
  );
}

Widget nameAndDateWidget(BuildContext context, Map post_map) {
  return Padding(
    padding: const EdgeInsets.only(left: 3.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        infoWidget(context, post_map),
        datePostedWidget(context, post_map),
      ],
    ),
  );
}

// ====================== Post Preview widgets

Widget infoWidget(BuildContext context, Map post_map) {
  String post_transaction_type =
      post_map["transaction_details"]["transaction_type"];
  String post_transaction_sent_received =
      post_map["transaction_details"]["sent_received"];
  return post_transaction_type == "Transfer" &&
          post_transaction_sent_received == "Sent"
      ? p2pTransferInfoWidget(context, post_map)
      : post_transaction_type == "Savings Transfer"
          ? savingsTransferWidget(context, post_map)
          : post_transaction_type == "Withdrawal"
              ? withdrawInforWidget(context, post_map)
              : depositInforWidget(context, post_map);
}

Widget savingsTransferWidget(BuildContext context, Map post_map) {
  String senders_names = "${post_map["post_owner_details"]["first_name"]} "
      "${post_map["post_owner_details"]["last_name"][0].toUpperCase()}";
  return SizedBox(
    width: width(context) * 0.6,
    child: Text.rich(
      TextSpan(
        text: post_map["post_owner_details"]["user_id"] == box("user_id")
            ? "You"
            : senders_names,
        children: [
          TextSpan(
            text: post_map["post_owner_details"]["user_id"] == box("user_id")
                ? " added to your savings"
                : " added to their savings",
            style: GoogleFonts.ubuntu(
              color: const Color.fromARGB(255, 162, 147, 61),
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ],
      ),
      style: GoogleFonts.ubuntu(
        fontWeight: FontWeight.w600,
        color: Colors.black,
        fontSize: 18,
      ),
    ),
  );
}

Widget p2pTransferInfoWidget(BuildContext context, Map post_map) {
  String senders_names =
      "${post_map["post_owner_details"]["first_name"]} ${post_map["post_owner_details"]["last_name"][0].toUpperCase()}";
  String receivers_names =
      "${post_map["transaction_details"]["p2p_recipient_details"]["full_names"].split(" ")[0]} ${post_map["transaction_details"]["p2p_recipient_details"]["full_names"].split(" ")[1][0].toUpperCase()}";
  return SizedBox(
    width: width(context) * 0.6,
    child: Text.rich(
      TextSpan(
        text: post_map["post_owner_details"]["user_id"] == box("user_id")
            ? "You"
            : senders_names,
        children: [
          TextSpan(
            text: " paid ",
            style: GoogleFonts.ubuntu(
              color: const Color.fromARGB(255, 162, 147, 61),
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
          TextSpan(
            text: post_map["transaction_details"]["p2p_recipient_details"]
                        ["user_id"] ==
                    box("user_id")
                ? "You"
                : receivers_names,
            style: GoogleFonts.ubuntu(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ],
      ),
      style: GoogleFonts.ubuntu(
        fontWeight: FontWeight.w600,
        color: Colors.black,
        fontSize: 18,
      ),
    ),
  );
}

Widget withdrawInforWidget(BuildContext context, Map post_map) {
  String senders_names =
      "${post_map["post_owner_details"]["first_name"]} ${post_map["post_owner_details"]["last_name"][0].toUpperCase()}";
  String receivers_names =
      "${post_map["transaction_details"]["p2p_recipient_details"]["full_names"].split(" ")[0]} ${post_map["transaction_details"]["p2p_recipient_details"]["full_names"].split(" ")[1][0].toUpperCase()}";
  return SizedBox(
    width: width(context) * 0.6,
    child: Text.rich(
      TextSpan(text: "$senders_names withdrew a 💰"),
      style: GoogleFonts.ubuntu(
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
        fontSize: 20,
      ),
    ),
  );
}

Widget depositInforWidget(BuildContext context, Map post_map) {
  String senders_names = "${post_map["post_owner_details"]["first_name"]} "
      "${post_map["post_owner_details"]["last_name"][0].toUpperCase()}";
  return SizedBox(
    width: width(context) * 0.7,
    child: Text.rich(
      TextSpan(
        text: post_map["post_owner_details"]["user_id"] == box("user_id")
            ? "You"
            : senders_names,
        children: [
          TextSpan(
            text: " deposited to wallet",
            style: GoogleFonts.ubuntu(
              color: const Color.fromARGB(255, 162, 147, 61),
              fontWeight: FontWeight.w400,
              fontSize: 18,
            ),
          ),
        ],
      ),
      style: GoogleFonts.ubuntu(
        fontWeight: FontWeight.w600,
        color: Colors.black,
        fontSize: 18,
      ),
    ),
  );
}

Widget datePostedWidget(BuildContext context, Map post_map) {
  bool isPostOwner = post_map["user_id"] == box("user_id");
  return Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Text(
      isPostOwner
          ? timeago.format(DateTime.parse(post_map["created_at"]),
              locale: 'en_short')
          : timeago.format(DateTime.parse(post_map["created_at"]),
              locale: 'en_short'),
      textAlign: TextAlign.left,
      maxLines: 1,
      style: GoogleFonts.ubuntu(
        color: Colors.green[800],
        fontSize: 15,
      ),
    ),
  );
}

Widget postCaption(BuildContext context, Map post_map) {
  return post_map["post_caption"] == ""
      ? hGap(10)
      : Container(
          width: width(context),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(bottom: 15.0, top: 5),
          child: Text(
            post_map["post_caption"],
            style: googleStyle(
              weight: FontWeight.w200,
              size: 18,
            ),
          ),
        );
}

Widget postMediaPreviewWidget(BuildContext context, Map post_map) {
  return post_map["post_type"] == "text"
      ? nothing()
      : GestureDetector(
          onTap: () {
            // if post is a photo post
            if (post_map["post_type"] == "photo") {
              changePage(context, ViewPhotoPage(post_map: post_map));

              return;
            }

            changePage(context, ViewVideoPage(post_map: post_map));
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: width(context),
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    height: height(context) * 0.35,
                    child: loadingIcon(
                      context,
                      color: Colors.green,
                    ),
                  ),
                  CachedNetworkImage(
                    imageUrl: post_map["post_type"] == "video"
                        ? post_map["media_details"][0]["thumbnail_url"]
                        : post_map["media_details"][0]["media_url"],
                    height: height(context) * 0.35,
                    width: width(context),
                    fit: BoxFit.cover,
                  ),
                  post_map["post_type"] == "video"
                      ? const CircleAvatar(
                          radius: 29,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 27,
                            backgroundColor: Colors.green,
                            child: Icon(
                              color: Colors.white,
                              Icons.play_arrow,
                              size: 30,
                            ),
                          ),
                        )
                      : nothing()
                ],
              ),
            ),
          ),
        );
}

Widget reactionWidgets(BuildContext context, Map post_map) {
  return Consumer<FeedProviderFunctions>(
    builder: (_, value, child) {
      Color color = Colors.grey[400]!;
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              LikeButton(
                size: 27,
                isLiked: null,
                circleColor: CircleColor(
                    start: Colors.orange[600]!, end: Colors.yellow[600]!),
                bubblesColor: BubblesColor(
                  dotPrimaryColor: Colors.orange[400]!,
                  dotSecondaryColor: Colors.orange[600]!,
                ),
                onTap: (bool? isLiked) async {
                  if (post_map["post_owner_user_id"] == box("user_id")) {
                    showSnackBar(context, "Cannot like your own posts",
                        color: Colors.grey[700]!);

                    return value
                        .returnLikedPostsPostIds()
                        .contains(post_map["post_id"]);
                  }

                  if (value
                      .returnLikedPostsPostIds()
                      .contains(post_map["post_id"])) {
                    await value.unLikePost({...post_map});
                    return value
                        .returnLikedPostsPostIds()
                        .contains(post_map["post_id"]);
                  }

                  await value.likePost({...post_map});

                  return value
                      .returnLikedPostsPostIds()
                      .contains(post_map["post_id"]);
                },
                likeBuilder: (bool isLiked) {
                  return Image.asset(
                    "assets/fire.png",
                    color: value
                            .returnLikedPostsPostIds()
                            .contains(post_map["post_id"])
                        ? Colors.orange[600]
                        : Colors.grey,
                    height: 27,
                  );
                },
              ),
              post_map["post_owner_user_id"] != box("user_id") &&
                      !value
                          .returnLikedPostsPostIds()
                          .contains(post_map["post_id"])
                  ? nothing()
                  : GestureDetector(
                      onTap: () async {
                        if (post_map["post_owner_user_id"] == box("user_id")) {
                          showSnackBar(context, "Cannot like your own posts",
                              color: Colors.grey[700]!);

                          return;
                        }

                        if (value
                            .returnLikedPostsPostIds()
                            .contains(post_map["post_id"])) {
                          await value.unLikePost({...post_map});
                          return;
                        }

                        await value.likePost({...post_map});
                      },
                      child: Container(
                        height: 20,
                        width: 30,
                        color: Colors.red.withOpacity(0.0),
                      ),
                    )
            ],
          ),
          wGap(3),
          Text(
            post_map["number_of_likes"] == 1
                ? "1 like"
                : "${post_map["number_of_likes"]} likes",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: color,
              fontSize: 17,
            ),
          ),
        ],
      );
    },
  );
}

// ====================== Style widgets

Decoration menuCardDeco() {
  return const BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(40),
      topRight: Radius.circular(40),
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
