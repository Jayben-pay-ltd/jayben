// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:jayben/Utilities/provider_functions.dart';

Widget createMediaMessageBody(BuildContext context, Map groupInfo) {
  return SafeArea(
    child: Stack(
      children: [
        mediaPreviewWidget(context, groupInfo),
        captionTextfieldWidget(context, groupInfo),
        uploadButtonWidget(context, groupInfo),
        uploadingMediaTextWidget(context),
        backButton(context, groupInfo)
      ],
    ),
  );
}

Widget mediaPreviewWidget(BuildContext context, Map groupInfo) {
  return Consumer<MessageProviderFunctions>(
    builder: (_, value, child) {
      return Container(
        color: Colors.black,
        height: height(context),
        alignment: Alignment.center,
        child: InkWell(
          onTap: () {
            if (value.returnVideoPlayerController()!.value.isPlaying) {
              value.returnVideoPlayerController()!.pause();
            } else {
              value.returnVideoPlayerController()!.play();
            }

            hideKeyboard();
          },
          child: groupInfo["media_type"] == "Photo"
              ? InkWell(
                  onTap: () => hideKeyboard(),
                  child: Image.file(
                    value.returnSelectedMediaFile(),
                    fit: BoxFit.cover,
                  ),
                )
              : AspectRatio(
                  aspectRatio: groupInfo["aspect_ratio"],
                  child: VideoPlayer(
                    value.returnVideoPlayerController()!,
                  ),
                ),
        ),
      );
    },
  );
}

Widget uploadButtonWidget(BuildContext context, Map groupInfo) {
  return Consumer<MessageProviderFunctions>(
    builder: (_, value, child) {
      return Positioned(
        bottom: 20,
        right: 20,
        child: InkWell(
          onTap: () async {
            hideKeyboard();

            if (value.returnIsLoading()) {
              showSnackBar(context, "File is uploading, please be patient...",
                  color: Colors.grey[700]!);

              return;
            }

            // shows the loading widget
            value.toggleIsLoading();

            // uploads media files to supabase
            // and sends the message afterwards
            await value.sendMediaMessage(groupInfo);

            // hides the loading widget
            value.toggleIsLoading();

            goBack(context);
          },
          child: CircleAvatar(
            radius: 27,
            backgroundColor: Colors.green,
            child: !value.returnIsLoading()
                ? Image.asset(
                    "assets/upload.png",
                    color: Colors.white,
                    height: 30,
                  )
                : const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
          ),
        ),
      );
    },
  );
}

Widget uploadingMediaTextWidget(BuildContext context) {
  return Positioned(
    top: 0,
    child: Consumer<MessageProviderFunctions>(
      builder: (_, value, child) {
        return Container(
          width: width(context),
          height: height(context) * 0.05,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: value.returnIsLoading() ? Colors.green : Colors.transparent,
          child: value.returnIsLoading()
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Uploading, please wait...",
                      style: GoogleFonts.ubuntu(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white24,
                        value: value.returnMediaUploadProgress(),
                        color: Colors.white,
                        strokeWidth: 1.5,
                      ),
                    )
                  ],
                )
              : const SizedBox(),
        );
      },
    ),
  );
}

Widget backButton(BuildContext context, Map groupInfo) {
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
              if (groupInfo["media_type"] == "video") {
                value.returnVideoPlayerController()!.dispose();
              }
              goBack(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
      );
    },
  );
}

Widget captionTextfieldWidget(BuildContext context, Map groupInfo) {
  return Positioned(
    bottom: 0,
    child: Container(
      width: width(context),
      alignment: Alignment.center,
      margin: const EdgeInsets.only(right: 85),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: Colors.white,
            width: 0.2,
          ),
        ),
      ),
      child: TextFormField(
        maxLines: 6,
        minLines: 1,
        cursorHeight: 18,
        cursorColor: Colors.white,
        controller: groupInfo["caption_controller"],
        inputFormatters: [LengthLimitingTextInputFormatter(1000)],
        style: GoogleFonts.ubuntu(fontSize: 20, color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent,
            child: Image.asset(
              "assets/comments.png",
              color: Colors.white,
              height: 25,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 35,
            vertical: 15,
          ),
          hintText: "Write a caption...",
          hintStyle: GoogleFonts.ubuntu(
            fontWeight: FontWeight.w400,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    ),
  );
}
