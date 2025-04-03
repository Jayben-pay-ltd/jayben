// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget viewMediaMessageBody(BuildContext context, Map messageInfo) {
  return SafeArea(
    child: Stack(
      children: [
        mediaPreviewWidget(context, messageInfo),
        backButton(context, messageInfo)
      ],
    ),
  );
}

Widget mediaPreviewWidget(BuildContext context, Map messageInfo) {
  return Container(
    color: Colors.black,
    height: height(context),
    alignment: Alignment.center,
    child: InkWell(
      onTap: () {
        if (messageInfo["message_type"] == "photo") return;

        if (messageInfo["video_controller"]!.value.isPlaying) {
          messageInfo["video_controller"]!.pause();
        } else {
          messageInfo["video_controller"]!.play();
        }

        hideKeyboard();
      },
      child: messageInfo["message_type"] == "photo"
          ? InkWell(
              onTap: () => hideKeyboard(),
              child: CachedNetworkImage(
                imageUrl: messageInfo["media_url"],
                fit: BoxFit.cover,
              ),
            )
          : !messageInfo["videoIsInitialized"]
              ? loadingScreenPlainNoBackButton(context)
              : AspectRatio(
                  aspectRatio: messageInfo["aspect_ratio"],
                  child: VideoPlayer(
                    messageInfo["video_controller"]!,
                  ),
                ),
    ),
  );
}

Widget backButton(BuildContext context, Map messageInfo) {
  return Consumer<MessageProviderFunctions>(
    builder: (_, value, child) {
      return Positioned(
        top: value.returnIsLoading() ? 80 : 50,
        left: 20,
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.black,
          child: IconButton(
            onPressed: () {
              if (messageInfo["message_type"] == "video") {
                messageInfo["video_controller"]!.dispose();
              }

              goBack(context);
            },
            icon: const Icon(
              color: Colors.white,
              Icons.arrow_back,
            ),
          ),
        ),
      );
    },
  );
}
