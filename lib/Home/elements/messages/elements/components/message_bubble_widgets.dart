// ignore_for_file: non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Widget messageBody(BuildContext context, Map message_info) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
    shape: customShapes(message_info),
    color: customColors(message_info),
    child: Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom:
                message_info["message_details"]["message_type"] == "document"
                    ? 5
                    : 25,
            right: 2,
            left: 2,
            top: 5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              replyBody(context, message_info),
              message_info["message_details"]["message_type"] == "document"
                  ? documentMessageBody(context, message_info)
                  : Padding(
                      padding: const EdgeInsets.only(
                        right: 8,
                        left: 8,
                        top: 8,
                      ),
                      child: message_info["message_details"]["message_type"] ==
                                  "photo" ||
                              message_info["message_details"]["message_type"] ==
                                  "video"
                          ? photoVideoMessageBody(context, message_info)
                          : textOnlyMessageBody(context, message_info),
                    ),
            ],
          ),
        ),
        timeAndReadReceipts(message_info),
        documentExtenstionWidget(message_info)
      ],
    ),
  );
}

// ========== sub widgets

Widget textOnlyMessageBody(BuildContext context, Map message_info) {
  return ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: width(context) - 40,
      maxHeight: double.infinity,
      minWidth: 30,
    ),
    child: Text(
      message_info["message_details"]["message"],
      textAlign: TextAlign.left,
      style: GoogleFonts.ubuntu(
        color: Colors.grey[200],
        fontSize: 18,
      ),
    ),
  );
}

Widget photoVideoMessageBody(BuildContext context, Map message_info) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: width(context) * 0.5,
            height: height(context) * 0.4,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          message_info["message_details"]["message_type"] == "photo"
              ? nothing()
              // const CircleAvatar(
              //     radius: 15,
              //     backgroundColor: Colors.transparent,
              //     child: CircularProgressIndicator(
              //         color: Colors.white),
              //   )
              : message_info["message_details"]["message_type"] == "video"
                  ? Container(
                      width: width(context) * 0.5,
                      height: height(context) * 0.4,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Center(
                        child: GestureDetector(
                            onTap: () {
                              //Navigator.push(context, MaterialPageRoute(builder: (builder) => FullScreen(chatRoomId: chatRoomId, VideoController: _VideoController, initializeVideoPlayerFuture: _initializeVideoPlayerFuture, timeStamp: timeStamp)));
                            },
                            child: nothing()),
                        // _VideoController!.value.isInitialized
                        //     ? AspectRatio(
                        //         child: VideoPlayer(_VideoController!),
                        //         aspectRatio: _VideoController!.value.aspectRatio,
                        //       )
                        //     : const Center(
                        //         child: CircularProgressIndicator(),
                        //       )),
                      ))
                  : Text(
                      message_info["message_details"]["message"],
                      maxLines: 20,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.ubuntu(
                        color: Colors.grey[800],
                        fontSize: 16,
                      ),
                    ),
          GestureDetector(
            onTap: () {
              if (message_info["message_details"]["message_type"] == "video") {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (builder) => FullScreen(
                //      VideoController: _VideoController,
                //      initializeVideoPlayerFuture: _initializeVideoPlayerFuture,
                //      timeStamp: timeStamp)));
              } else if (message_info["message_details"]["message_type"] ==
                  "photo") {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(builder: (builder) => FullScreen(chatRoomId: chatRoomId, image: message, timeStamp: timeStamp)));
              }
            },
            child: message_info["message_details"]["message_type"] == "video"
                ? const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 13,
                  )
                : CachedNetworkImage(
                    width: width(context) * 0.5,
                    height: height(context) * 0.4,
                    imageUrl: message_info["message_details"]["message"],
                    errorWidget: (_, url, error) =>
                        const Icon(Icons.error, color: Colors.red),
                    imageBuilder: (_, imageProvider) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      hGap(message_info["message_details"]["caption"] == "" ? 0 : 5),
      message_info["message_details"]["caption"] == ""
          ? hGap(3)
          : Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 10, right: 10),
              child: Text(
                message_info["message_details"]["caption"],
                maxLines: 20,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ubuntu(
                  color: Colors.grey[200],
                  fontSize: 16,
                ),
              ),
            )
    ],
  );
}

Widget documentMessageBody(BuildContext context, Map message_info) {
  return GestureDetector(
    onTap: () async {},
    child: Container(
      height: 80,
      padding: const EdgeInsets.only(bottom: 23.0, right: 5, left: 5, top: 5),
      child: Container(
        decoration: BoxDecoration(
          color: message_info["user_id"] == box("user_id")
              ? const Color(0xFF1d3752)
              : Colors.grey[800],
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 15, right: 15),
        child: Row(
          children: [
            Icon(
              Icons.file_copy,
              color: Colors.grey[200],
            ),
            wGap(10),
            Expanded(
              child: Text(
                message_info["message_details"]["caption"],
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.ubuntu(
                  color: Colors.grey[200],
                  fontSize: 15,
                ),
              ),
            ),
            wGap(10),
            GestureDetector(
              onTap: () async {
                // _download(message,
                //     caption);
              },
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.grey[700],
                child: const Icon(
                  Icons.download_sharp,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

Widget replyBody(BuildContext context, Map message_info) {
  return Consumer<MessageProviderFunctions>(builder: (_, value, child) {
    return SizedBox(
      height: message_info["reply_message_details"]["reply_message"] == null
          ? 0
          : 62.5,
      child: message_info["reply_message_details"]["reply_message"] == null
          ? nothing()
          : GestureDetector(
              onTap: () => value.scrollToMessage(
                  message_info["reply_message_details"]["reply_message_id"],
                  message_info["messages"],
                  message_info["scroll_controller"]),
              child: Container(
                height: 62.5,
                padding: const EdgeInsets.only(left: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    replyPreviewColorWidget(message_info),
                    replyPreviewPhotoVideoPreviewWidget(message_info),
                    replyPreviewContentWidget(context, message_info),
                  ],
                ),
              ),
            ),
    );
  });
}

Widget replyPreviewColorWidget(Map message_info) {
  return Container(
    width: 5,
    height: 50.5,
    margin: const EdgeInsets.only(right: 5),
    decoration: BoxDecoration(
      color: message_info["reply_message_details"]["reply_message_uid"] !=
              box("user_id")
          ? Colors.pink[300]
          : Colors.teal[300]!,
      borderRadius: const BorderRadius.all(
        Radius.circular(8),
      ),
    ),
    child: wGap(2),
  );
}

Widget replyPreviewPhotoVideoPreviewWidget(Map message_info) {
  String? reply_message_type =
      message_info["reply_message_details"]["reply_message_type"];
  return reply_message_type == "photo" || reply_message_type == "video"
      ? Container(
          width: 50,
          color: Colors.transparent,
          child: CachedNetworkImage(
            imageUrl: message_info["reply_message_details"]
                ["reply_message_thumbnail_url"],
            errorWidget: (_, url, error) =>
                const Icon(Icons.error, color: Colors.red),
            imageBuilder: (_, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            height: 51,
            width: 50,
          ),
        )
      : nothing();
}

Widget replyPreviewContentWidget(BuildContext context, Map message_info) {
  String? reply_message_type =
      message_info["reply_message_details"]["reply_message_type"];
  return Padding(
    padding: const EdgeInsets.only(left: 5, right: 5),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message_info["reply_message_details"]["reply_message_uid"] !=
                  box("user_id")
              ? "${message_info["reply_message_details"]["reply_message_first_name"]}"
              : "You",
          style: googleStyle(
            color: message_info["reply_message_details"]["reply_message_uid"] !=
                    box("user_id")
                ? Colors.pink[300]!
                : Colors.teal[300]!,
            weight: FontWeight.w400,
            size: 15,
          ),
        ),
        hGap(2),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                right: reply_message_type == "text" ? 0 : 5.0,
              ),
              child: reply_message_type == "text"
                  ? nothing()
                  : Icon(
                      reply_message_type == "photo"
                          ? Icons.photo
                          : reply_message_type == "video"
                              ? Icons.video_collection_rounded
                              : reply_message_type == "document"
                                  ? Icons.file_copy
                                  : null,
                      color: Colors.grey[200],
                      size: 15,
                    ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: reply_message_type == "photo" ||
                        reply_message_type == "video"
                    ? message_info["message_details"]["message_type"] ==
                                "photo" ||
                            message_info["message_details"]["message_type"] ==
                                "video"
                        ? width(context) * 0.25
                        : width(context) - 190
                    : width(context) - 100,
                minWidth: width(context) * 0.07,
                maxHeight: 30,
                minHeight: 5,
              ),
              child: Container(
                padding: const EdgeInsets.only(right: 5),
                child: Text(
                  reply_message_type == "text"
                      ? message_info["reply_message_details"]["reply_message"]
                      : message_info["reply_message_details"]["reply_caption"],
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ubuntu(
                    color: Colors.grey[200],
                  ),
                  maxLines: 2,
                ),
              ),
            )
          ],
        )
      ],
    ),
  );
}

Widget timeAndReadReceipts(Map message_info) {
  List<dynamic> filtered_seen_by_people = message_info["is_seen_by"];
  filtered_seen_by_people
      .removeWhere((user) => user['user_id'] != box("user_id"));
  return Positioned(
    bottom: 7,
    right: 7,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          DateFormat.Hm().format(DateTime.parse(message_info["created_at"]).toUtc().toLocal()),
          style: GoogleFonts.ubuntu(
            color: Colors.grey[200],
            fontSize: 13,
          ),
        ),
        wGap(5),
        message_info["user_id"] != box("user_id")
            ? nothing()
            : message_info["is_seen_by"].length ==
                    filtered_seen_by_people.length
                ? Icon(
                    Icons.done,
                    color: Colors.grey[200],
                    size: 19,
                  )
                : Icon(
                    Icons.done_all,
                    color: Colors.blue[800],
                    size: 19,
                  )
      ],
    ),
  );
}

Widget documentExtenstionWidget(Map message_info) {
  return Positioned(
    bottom: 7,
    left: 7,
    child: message_info["message_details"]["message_type"] == "document"
        ? Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Row(
              children: [
                Text(
                  message_info["message_details"]["message_extension"],
                  style: GoogleFonts.ubuntu(
                    color: Colors.grey[500],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ) //document extension
        : nothing(),
  );
}

// ========== bubble style widgets

Alignment customAlignments(Map message_info) {
  return message_info["message_details"]["message_type"] == "date" ||
          message_info["message_details"]["message_type"] == "prompt"
      ? Alignment.center
      : message_info["user_id"] == box("user_id")
          ? Alignment.centerRight
          : Alignment.centerLeft;
}

BoxConstraints customConstraints(BuildContext context, Map message_info) {
  String? message_type = message_info["message_details"]["message_type"];
  return BoxConstraints(
    maxWidth: message_type == "document"
        ? width(context) * 0.7
        : message_type == "date" || message_type == "prompt"
            ? width(context) * 0.7
            : message_type == "photo" || message_type == "video"
                ? width(context) * 0.54
                : width(context) - 45,
    minWidth: message_type == "date" || message_type == "prompt"
        ? width(context) * 0.007
        : width(context) * 0.30,
    maxHeight: message_type == "date" || message_type == "prompt"
        ? width(context) * 0.07
        : double.infinity,
    minHeight: message_type == "date" || message_type == "prompt"
        ? width(context) * 0.07
        : width(context) * 0.13,
  );
}

Color? customColors(Map message_info) {
  String? message_type = message_info["message_details"]["message_type"];
  return message_type == "date" || message_type == "prompt"
      ? Colors.grey[200]
      : message_info["user_id"] == box("user_id")
          ? senderMessageBubbleColor
          : receiverMessageBubbleColor;
}

RoundedRectangleBorder customShapes(Map message_info) {
  double radius = 15.0;
  String? message_type = message_info["message_details"]["message_type"];
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
      bottomLeft: message_type == "date" || message_type == "prompt"
          ? Radius.circular(radius)
          : message_info["user_id"] == box("user_id")
              ? Radius.circular(radius)
              : const Radius.circular(0),
      bottomRight: message_type == "date" || message_type == "prompt"
          ? Radius.circular(radius)
          : message_info["user_id"] == box("user_id")
              ? const Radius.circular(0)
              : Radius.circular(radius),
    ),
  );
}
