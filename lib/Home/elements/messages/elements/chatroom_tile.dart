// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'components/chatroom_tile_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class ChatroomTile extends StatefulWidget {
  const ChatroomTile({Key? key, required this.chatroom_map}) : super(key: key);

  final Map chatroom_map;

  @override
  State<ChatroomTile> createState() => _ChatroomTileState();
}

class _ChatroomTileState extends State<ChatroomTile> {
  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    // context.read<MessageProviderFunctions>().getGroupsStream();
    print("Updating UI boss...");
  }

  @override
  Widget build(BuildContext context) {
    print("Rebuilding group tile boss...");
    List<dynamic> members = widget.chatroom_map["members_with_their_details"];
    members.removeWhere((user) => user['user_id'] == box("user_id"));
    return Container(
      width: width(context),
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          chatroomImageWidget(context, members[0]["profile_image_url"]),
          wGap(15),
          SizedBox(
            width: width(context) * 0.6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                chtroomName(
                    context,
                    "${members[0]["first_name"]} "
                    "${members[0]["last_name"]}"),
                hGap(3),
                lastMessageBody(context, widget.chatroom_map),
              ],
            ),
          ),
          const Spacer(),
          lastMessageDateWidget(context, widget.chatroom_map),
        ],
      ),
    );
  }
}
