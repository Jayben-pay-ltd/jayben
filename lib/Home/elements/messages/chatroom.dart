// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/messages/components/chatroom_widgets.dart';

class ChatroomPage extends StatefulWidget {
  const ChatroomPage({
    Key? key,
    required this.chatroom_map,
  }) : super(key: key);

  final Map chatroom_map;

  @override
  State<ChatroomPage> createState() => _ChatroomPageState();
}

class _ChatroomPageState extends State<ChatroomPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    onPageLaunch();
    super.initState();
  }

  onPageLaunch() async {
    var prov = context.read<MessageProviderFunctions>();

    prov.getMessagesStream(widget.chatroom_map["chatroom_id"]);

    _scrollController.addListener(() {
      if (_scrollController.initialScrollOffset != _scrollController.offset) {
        hideKeyboard();
      }
    });
  }

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    List<dynamic> members = widget.chatroom_map["members_with_their_details"];
    members.removeWhere((user) => user['user_id'] == box("user_id"));
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.black,
        body: WillPopScope(
          child: SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              children: [
                wallpaperWidget(context),
                RepaintBoundary(
                  child: Container(
                    width: width(context),
                    height: height(context),
                    color: Colors.transparent,
                    child: Scrollbar(
                      interactive: false,
                      trackVisibility: false,
                      controller: _scrollController,
                      radius: const Radius.circular(8),
                      child: ListView(
                        reverse: true,
                        shrinkWrap: true,
                        controller: _scrollController,
                        children: [
                          chatInputsFieldBLANK(context, _messageController),
                          temporaryMessageBubbles(
                              context, widget.chatroom_map["chatroom_id"]),
                          chatMessages(context, _scrollController),
                        ],
                      ),
                    ),
                  ),
                ),
                RepaintBoundary(
                  child: chatInputsField(
                    context,
                    {
                      "message_controller": _messageController,
                      "scroll_controller": _scrollController,
                      "chatroom_map": widget.chatroom_map,
                    },
                  ),
                ),
                appbarWidget(context, members)
              ],
            ),
          ),
          onWillPop: () async {
            goBack(context);
            return Future.value(true);
          },
        ),
      ),
    );
  }
}
