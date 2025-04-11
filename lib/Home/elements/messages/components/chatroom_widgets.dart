// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:jayben/Home/elements/messages/elements/temporary_message_bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import '../elements/choose_message_media_card.dart';
import '../elements/prompt_message_bubble.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../Utilities/constants.dart';
import '../elements/message_bubble.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

Widget chatMessages(BuildContext context, scrollController) {
  return Consumer<MessageProviderFunctions>(
    builder: (_, value, child) {
      return StreamBuilder<List<dynamic>?>(
        stream: value.returnMessagesStream()[0],
        builder: (_, snapshot) {
          return !snapshot.hasData
              ? nothing()
              : ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  addAutomaticKeepAlives: false,
                  itemCount: snapshot.data!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    // bottom: value.returnTemporaryMessages().isEmpty ? 0 : 0,
                    top: 50,
                  ),
                  itemBuilder: (_, index) {
                    var message_map = snapshot.data![index];
                    return message_map["message_type"] != "prompt"
                        ? GestureDetector(
                            onTap: () => value.setReplyValue(message_map),
                            child: MessageBubble(
                              message_info: {
                                "scroll_controller": scrollController,
                                "messages": snapshot.data!,
                                ...message_map
                              },
                            ),
                          )
                        : PromptMessageBubble(
                            message: message_map["message"],
                          );
                  },
                );
        },
      );
    },
  );
}

Widget wallpaperWidget(BuildContext context) {
  return Image.asset(
    chat_wallpaper,
    width: double.infinity,
    height: height(context),
    fit: BoxFit.cover,
  );
}

Widget chatInputsField(BuildContext context, Map body_info) {
  return Consumer<MessageProviderFunctions>(builder: (_, value, child) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: width(context),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(chat_wallpaper),
                fit: BoxFit.fitWidth,
              ),
            ),
            alignment: Alignment.center,
            padding: EdgeInsets.only(
                top: 10, bottom: Platform.isIOS ? 35 : 15, left: 5, right: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: width(context) * 0.83,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: chatroom_message_textfield_color,
                  ),
                  child: Column(
                    children: [
                      value.returnIsReplyState()
                          ? reply_messageBody(context)
                          : nothing(),
                      messageTextfield(context, body_info),
                    ],
                  ),
                ),
                wGap(2),
                sendMessageButton(context, body_info),
              ],
            ),
          ),
        ],
      ),
    );
  });
}

// this widget makes sure the chat messages move up as the main chat input grows in height
Widget chatInputsFieldBLANK(BuildContext context, messageController) {
  return Consumer<MessageProviderFunctions>(
    builder: (_, value, child) {
      return Container(
        width: width(context) * 0.83,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.transparent,
        ),
        child: Column(
          children: [
            value.returnIsReplyState()
                ? reply_messageBodyBLANK(context)
                : nothing(),
            textFormFieldBLANK(context, messageController),
          ],
        ),
      );
    },
  );
}

Widget temporaryMessageBubbles(BuildContext context, String chatroom_id) {
  return Consumer<MessageProviderFunctions>(
    builder: (_, value, child) {
      List<dynamic> temp_messages = value.returnTemporaryMessages();
      temp_messages
          .removeWhere((messages) => messages['chatroom_id'] != chatroom_id);
      return value.returnTemporaryMessages().isEmpty
          ? nothing()
          : MediaQuery.removePadding(
              removeBottom: true,
              context: context,
              removeTop: true,
              child: ListView.builder(
                shrinkWrap: true,
                addAutomaticKeepAlives: false,
                // padding: const EdgeInsets.only(bottom: 0),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: value.returnTemporaryMessages().length,
                itemBuilder: (_, index) {
                  var message_map = value.returnTemporaryMessages()[index];
                  return TemporaryMessageBubble(
                    message_info: message_map,
                  );
                },
              ),
            );
    },
  );
}

Widget reply_messageBody(BuildContext context) {
  return Stack(
    children: [
      Container(
        width: width(context) * 0.83,
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
        decoration: customReply_messageBodyStyle(),
        child: Container(
          padding: const EdgeInsets.only(left: 5),
          alignment: Alignment.centerLeft,
          height: 42,
          child: Container(
            height: 42,
            decoration: customReplyPreviewAccent(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                replyPreviewColorWidget(context),
                box("reply_message_type") == "photo" ||
                        box("reply_message_type") == "video"
                    ? Container(
                        color: Colors.black,
                        width: 50,
                        child: Image.network(
                          box("reply_message"),
                          fit: BoxFit.cover,
                        ),
                      )
                    : nothing(),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      replyPreviewFirstNameWidget(context),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          replyPreviewIconWidget(context),
                          replyPreviewTextWidget(context)
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      closeReplyWidget(context),
    ],
  );
}

Widget reply_messageBodyBLANK(BuildContext context) {
  return Container(
    color: Colors.transparent,
    width: width(context) * 0.83,
    alignment: Alignment.topCenter,
    padding: const EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
    child: Container(
      padding: const EdgeInsets.only(left: 5),
      alignment: Alignment.centerLeft,
      color: Colors.transparent,
      child: nothing(),
      height: 40,
    ),
  );
}

Widget messageTextfield(BuildContext context, Map body_info) {
  return TextFormField(
    textCapitalization: TextCapitalization.sentences,
    textAlignVertical: TextAlignVertical.center,
    controller: body_info["message_controller"],
    keyboardType: TextInputType.multiline,
    cursorColor: Colors.green,
    style: GoogleFonts.ubuntu(
      fontWeight: FontWeight.w400,
      color: Colors.white,
      fontSize: 18,
    ),
    autocorrect: true,
    cursorHeight: 20,
    maxLines: 5,
    minLines: 1,
    textAlign: TextAlign.left,
    decoration: InputDecoration(
      border: InputBorder.none,
      hintText: "Message",
      suffixIcon: GestureDetector(
        onTap: () => showBottomCard(
          context,
          ChooseMediaCard(
            chatroom_info: body_info,
          ),
        ),
        child: const Icon(
          Icons.attach_file_outlined,
          color: Colors.white,
        ),
      ),
      hintStyle: GoogleFonts.ubuntu(
        fontWeight: FontWeight.w400,
        color: Colors.white54,
        fontSize: 18,
      ),
      contentPadding: const EdgeInsets.only(
        bottom: 5,
        right: 25,
        left: 25,
        top: 5,
      ),
    ),
  );
}

Widget textFormFieldBLANK(BuildContext context, messageController) {
  return TextFormField(
    style: const TextStyle(color: Colors.transparent),
    textCapitalization: TextCapitalization.sentences,
    textAlignVertical: TextAlignVertical.center,
    keyboardType: TextInputType.multiline,
    cursorColor: Colors.transparent,
    controller: messageController,
    autocorrect: true,
    cursorHeight: 15,
    readOnly: true,
    maxLines: 6,
    minLines: 1,
    decoration: InputDecoration(
      border: InputBorder.none,
      hintText: "",
      hintStyle: GoogleFonts.ubuntu(
        color: Colors.transparent,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.only(
        bottom: 5,
        right: 25,
        left: 25,
        top: 5,
      ),
    ),
  );
}

Widget sendMessageButton(BuildContext context, Map body_info) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4, left: 3.5),
    child: CircleAvatar(
      radius: 24,
      backgroundColor: Colors.green,
      child: Consumer<MessageProviderFunctions>(
        builder: (_, value, child) {
          return IconButton(
            icon: const Icon(
              color: Colors.white,
              Icons.send,
              size: 22,
            ),
            onPressed: () async {
              if (body_info["message_controller"].text == "") return;

              List<dynamic> members =
                  body_info["chatroom_map"]["members_with_their_details"];

              members.removeWhere((user) => user['user_id'] == box("user_id"));

              // creates the no access sav acc
              await value.sendMessage({
                "reply_message_thumbnail_url": box("reply_sent_by_thumbnail_url"),
                "reply_message_first_name": box("reply_sent_by_first_name"),
                "reply_message_last_name": box("reply_sent_by_last_name"),
                "chatroom_id": body_info["chatroom_map"]["chatroom_id"],
                "message_controller": body_info["message_controller"],
                "reply_message_type": box("reply_message_type"),
                "other_person_user_id": members[0]["user_id"],
                "reply_message_uid": box("reply_sent_by_uid"),
                "reply_message_id": box("reply_message_id"),
                "reply_message": box("reply_message"),
                "reply_caption": box("reply_caption"),
                "message_extension": null,
                "message_type": "text",
                "caption": null,
              });

              body_info["scroll_controller"].animateTo(
                body_info["scroll_controller"].position.minScrollExtent,
                duration: const Duration(milliseconds: 100),
                curve: Curves.fastOutSlowIn,
              );
            },
          );
        },
      ),
    ),
  );
}

Widget appbarWidget(BuildContext context, List members) {
  return Consumer<MessageProviderFunctions>(
    builder: (_, value, child) {
      return Positioned(
        top: 0,
        child: Container(
          width: width(context),
          color: chatroom_app_bar_color,
          padding: EdgeInsets.only(bottom: 5, top: Platform.isIOS ? 55 : 35),
          child: Stack(
            children: [
              Container(
                width: width(context),
                height: 45,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                  bottom: 10,
                  right: 10,
                  left: 10,
                  top: 2,
                ),
                child: Text(
                  "",
                  style: GoogleFonts.ubuntu(
                    color: const Color.fromARGB(255, 54, 54, 54),
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 5,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    chatroomIconWidget(
                      context,
                      members[0]["profile_image_url"],
                    ),
                    wGap(10),
                    chatroomNameWidget("${members[0]["first_name"]} "
                        "${members[0]["last_name"]}"),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget chatroomNameWidget(String chatroom_name) {
  return Text(
    chatroom_name,
    overflow: TextOverflow.ellipsis,
    style: GoogleFonts.ubuntu(
      fontWeight: FontWeight.w400,
      color: Colors.grey[400],
      fontSize: 20,
    ),
  );
}

// ================ Reply Body widgets

Widget closeReplyWidget(BuildContext context) {
  return Positioned(
    top: 10,
    right: 15,
    child: InkWell(
      onTap: () => context.read<MessageProviderFunctions>().removeReplyWidget(),
      child: Icon(
        color: Colors.grey[500],
        Icons.close,
        size: 20,
      ),
    ),
  );
}

Widget replyPreviewTextWidget(BuildContext context) {
  return ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: box("reply_message_type") == "photo" ||
              box("reply_message_type") == "video"
          ? width(context) * 0.52
          : width(context) * 0.68,
      minWidth: width(context) * 0.07,
      maxHeight: 20,
      minHeight: 1,
    ),
    child: Container(
      padding: const EdgeInsets.only(right: 5),
      child: Text(
        box("reply_message_type") == "text"
            ? box("reply_message")
            : box("reply_caption"),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    ),
  );
}

Widget replyPreviewIconWidget(BuildContext context) {
  return box("reply_message_type") == "text"
      ? nothing()
      : box("reply_message_type") == "photo"
          ? const Padding(
              padding: EdgeInsets.only(right: 5.0),
              child: Icon(
                color: Colors.white,
                Icons.photo,
                size: 15,
              ),
            )
          : box("reply_message_type") == "video"
              ? const Padding(
                  padding: EdgeInsets.only(right: 5.0),
                  child: Icon(
                    Icons.video_collection_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                )
              : box("reply_message_type") == "document"
                  ? const Padding(
                      padding: EdgeInsets.only(right: 5.0),
                      child: Icon(
                        color: Colors.white,
                        Icons.file_copy,
                        size: 15,
                      ),
                    )
                  : nothing();
}

Widget replyPreviewFirstNameWidget(BuildContext context) {
  return box("reply_sent_by_uid") == null
      ? nothing()
      : Text(
          box("reply_sent_by_uid") == box("user_id")
              ? "You"
              : box("reply_sent_by_first_name"),
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.bold,
            color: box("reply_sent_by_uid") == box("user_id")
                ? Colors.teal[300]
                : Colors.pink[300],
          ),
        );
}

Widget replyPreviewColorWidget(BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(right: 5),
    width: 5,
    height: 62.5,
    decoration: BoxDecoration(
      color: box("reply_sent_by_uid") == box("user_id")
          ? Colors.teal[300]
          : Colors.pink[300],
      borderRadius: const BorderRadius.all(
        Radius.circular(8),
      ),
    ),
    child: wGap(2),
  );
}

// ================ other sub widgets

Widget fileSendingWidget(BuildContext context, bool isSendingFile) {
  return Positioned(
    top: 0,
    child: isSendingFile
        ? Container(
            height: 30,
            width: width(context),
            color: Colors.green,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Sending file, please wait...",
                  style: GoogleFonts.ubuntu(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 1.5,
                  ),
                )
              ],
            ),
          )
        : nothing(),
  );
}

Widget messageSendingWidget(BuildContext context, bool messageSending) {
  return Positioned(
    bottom: 0,
    child: SizedBox(
      width: width(context),
      child: messageSending
          ? const LinearProgressIndicator(
              minHeight: 0.9,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            )
          : nothing(),
    ),
  );
}

Widget chatroomIconWidget(BuildContext context, String icon_url) {
  return GestureDetector(
    onTap: () => goBack(context),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          color: Colors.grey[400],
          Icons.arrow_back,
          size: 35,
        ),
        wGap(10),
        icon_url.isNotEmpty
            ? CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Image.asset(
                  "assets/ProfileAvatar.png",
                  color: Colors.grey[400],
                  height: 39,
                ),
              )
            : CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(icon_url),
                backgroundColor: Colors.white,
                radius: 18.5,
              )
      ],
    ),
  );
}

// ================ styling widgets

BoxDecoration customReplyPreviewAccent() {
  return BoxDecoration(
    color: Colors.grey[900],
    borderRadius: const BorderRadius.only(
      bottomRight: Radius.circular(10),
      topRight: Radius.circular(10),
    ),
  );
}

BoxDecoration customReply_messageBodyStyle() {
  return BoxDecoration(
    color: Colors.grey[900],
    borderRadius: const BorderRadius.only(
      topRight: Radius.circular(10),
      topLeft: Radius.circular(10),
    ),
  );
}

Decoration msgInputDecor() {
  return const BoxDecoration(
    color: Colors.white,
    border: Border(
      top: BorderSide(
        color: Colors.grey,
        width: 0.5,
      ),
    ),
  );
}
