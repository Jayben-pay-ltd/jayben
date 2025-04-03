// ignore_for_file: non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget chatroomImageWidget(BuildContext context, String profileUrl) {
  return Container(
    child: profileUrl.isEmpty
        ? Image.asset(
            "assets/ProfileAvatar.png",
            color: Colors.grey[300],
            height: 45,
          )
        : CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[200],
            backgroundImage: CachedNetworkImageProvider(
              profileUrl,
            ),
          ),
  );
}

Widget chtroomName(BuildContext context, String other_person_name) {
  return SizedBox(
    width: width(context) * 0.6,
    child: Text.rich(
      TextSpan(text: other_person_name),
      style: GoogleFonts.ubuntu(
        fontWeight: FontWeight.bold,
        color: Colors.grey[700],
        fontSize: 20,
      ),
    ),
  );
}

Widget lastMessageBody(BuildContext context, Map chatroom_map) {
  return SizedBox(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        sentIconWidget(context, chatroom_map),
        messagePreview(context, chatroom_map),
      ],
    ),
  );
}

Widget lastMessageDateWidget(BuildContext context, Map chatroom_map) {
  return Container(
    alignment: Alignment.center,
    // width: 50,
    height: 50,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            text: DateFormat.Hm().format(
              DateTime.parse(
                chatroom_map["last_message_date"],
              ),
            ),
          ),
          textAlign: TextAlign.center,
          style: GoogleFonts.ubuntu(
            color: Colors.grey[800],
            fontSize: 12,
          ),
        ),
        !chatroom_map["users_that_have_muted_this_chatroom"]
                .contains(box("user_id"))
            ? nothing()
            : Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Image.asset(
                  "assets/mute.png",
                  color: Colors.grey[600],
                  height: 20,
                ),
              )
      ],
    ),
  );
}

// ========= sub widgets

Widget messagePreview(BuildContext context, Map chatroom_map) {
  return Consumer<MessageProviderFunctions>(
    builder: (_, value, child) {
      List<dynamic> temp_messages = value.returnTemporaryMessages();
      temp_messages.removeWhere(
          (user) => user['chatroom_id'] != chatroom_map["chatroom_id"]);
      return Container(
        width: width(context) * 0.52,
        alignment: Alignment.centerLeft,
        height: 20,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            lastMessageTypeWidget(context, chatroom_map["last_message_type"]),
            SizedBox(
              width: width(context) * 0.52,
              child: Text(
                temp_messages.isNotEmpty
                    ? temp_messages[temp_messages.length - 1]["message_details"]
                        ["message"]
                    : chatroom_map["last_message"],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            )
          ],
        ),
      );
    },
  );
}

Widget lastMessageTypeWidget(BuildContext context, String lastMessageType) {
  return lastMessageType == "text" || lastMessageType == "prompt"
      ? nothing()
      : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Icon(
            lastMessageType == "photo"
                ? Icons.camera
                : (lastMessageType == "video"
                    ? Icons.video_call
                    : (lastMessageType == "audio"
                        ? Icons.speaker
                        : (lastMessageType == "deposit"
                            ? Icons.send
                            : (lastMessageType == "withdrawal"
                                ? Icons.send
                                : (lastMessageType == "payment"
                                    ? Icons.send
                                    : (lastMessageType == "file"
                                        ? Icons.file_copy
                                        : (lastMessageType == "location"
                                            ? Icons.location_pin
                                            : (lastMessageType == "contact"
                                                ? Icons.person
                                                : (lastMessageType == "prompt"
                                                    ? Icons.speaker
                                                    : null))))))))),
            color: Colors.grey[700],
            size: 12,
          ),
        );
}

Widget sentIconWidget(BuildContext context, Map chatroom_map) {
  return chatroom_map["last_message_sender_details"]["user_id"] ==
          box("user_id")
      ? sentIconDetails(context, chatroom_map)
      : nothing();
}

Widget sentIconDetails(context, Map chatroom_map) {
  String lastMessageType = chatroom_map["last_message_type"];
  return Consumer<MessageProviderFunctions>(builder: (cont_, value, child) {
    List<dynamic> temp_messages = value.returnTemporaryMessages();
    temp_messages.removeWhere(
        (user) => user['chatroom_id'] != chatroom_map["chatroom_id"]);
    return lastMessageType == "prompt"
        ? nothing()
        : lastMessageType == "deposit"
            ? nothing()
            : lastMessageType == "withdrawal"
                ? nothing()
                : Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(
                      temp_messages.isNotEmpty
                          ? Icons.watch_later_outlined
                          : Icons.done,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                  );
  });
}
