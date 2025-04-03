
import '../../drawer/elements/components/ProfileWidgets.dart';
import 'package:jayben/Home/elements/messages/chatroom.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import '../elements/chatroom_tile.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

Widget messagesBody(BuildContext context) {
  return Consumer<MessageProviderFunctions>(
    builder: (_, value, chidl) {
      return value.returnAllChatrooms() == null
          ? loadingScreenPlainNoBackButton(context)
          : MediaQuery.removePadding(
              removeBottom: true,
              context: context,
              removeTop: true,
              child: value.returnAllChatrooms()!.isEmpty
                  ? Center(
                      child: Text(
                        "No chats yet",
                        style: googleStyle(
                          color: Colors.green,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        // plays refresh sound
                        await playSound('refresh.mp3');

                        await value.getChatrooms();
                      },
                      displacement: 70,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 55.0),
                        itemCount: value.returnAllChatrooms()!.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (_, index) {
                          return !value.returnAllChatrooms()![index]
                                  ['is_active']
                              ? const SizedBox()
                              : Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    RepaintBoundary(
                                      child: ChatroomTile(
                                        chatroom_map:
                                            value.returnAllChatrooms()![index],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => changePage(
                                        context,
                                        ChatroomPage(
                                          chatroom_map: value
                                              .returnAllChatrooms()![index],
                                        ),
                                      ),
                                      child: Container(
                                        width: width(context),
                                        margin: const EdgeInsets.only(
                                          left: 100,
                                        ),
                                        height: 60,
                                      ),
                                    ),
                                  ],
                                );
                        },
                      ),
                    ),
            );
    },
  );
}

Widget chatsroomsAppBar(BuildContext context) {
  return Consumer<MessageProviderFunctions>(
    builder: (_, value, child) {
      return Positioned(
        top: 0,
        child: Container(
          width: width(context),
          decoration: appBarDeco(),
          padding: const EdgeInsets.only(bottom: 5, top: 7),
          child: Stack(
            children: [
              Container(
                width: width(context),
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                  bottom: 7,
                  right: 10,
                  left: 10,
                  top: 2,
                ),
                child: Text(
                  "Chats",
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
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 40,
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
