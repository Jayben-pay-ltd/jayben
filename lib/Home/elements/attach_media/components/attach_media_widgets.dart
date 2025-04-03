// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../../../Utilities/provider_functions.dart';

Widget uploadMediaBody(BuildContext context, Map body_info) {
  return Consumer<AttachProviderFunctions>(
    builder: (_, value, child) {
      return SafeArea(
        child: Stack(
          children: [
            mediaPreviewWidget(context, body_info),
            commentTextfieldWidget(context, body_info),
            uploadButtonWidget(context, body_info),
            uploadingMediaTextWidget(context),
            attachbackButton(context, body_info)
          ],
        ),
      );
    },
  );
}

Widget attachbackButton(BuildContext context, Map body_info) {
  return Consumer<AttachProviderFunctions>(
    builder: (_, value, child) {
      return Positioned(
        top: value.returnIsLoading() ? 65 : 40,
        left: 20,
        child: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.grey[600]!.withOpacity(0.5),
          child: IconButton(
            onPressed: () {
              if (body_info["media_type"] == "video") {
                value.returnVideoPlayerController()!.dispose();
              }

              goBack(context);
            },
            icon: const Icon(
              color: Colors.white,
              Icons.arrow_back,
              size: 27,
            ),
          ),
        ),
      );
    },
  );
}

Widget mediaPreviewWidget(BuildContext context, Map body_info) {
  return Consumer<AttachProviderFunctions>(builder: (_, value, child) {
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
        child: body_info["media_type"] == "photo"
            ? InkWell(
                onTap: () => hideKeyboard(),
                child: Image.file(
                  value.returnSelectedMedia()!,
                  fit: BoxFit.cover,
                ),
              )
            : AspectRatio(
                aspectRatio: body_info["aspect_ratio"],
                child: VideoPlayer(
                  value.returnVideoPlayerController()!,
                ),
              ),
      ),
    );
  });
}

Widget uploadButtonWidget(BuildContext context, Map transfer_info) {
  return Positioned(
    bottom: 20,
    right: 20,
    child: Consumer<AttachProviderFunctions>(
      builder: (_, value, child) {
        return InkWell(
          onTap: () async {
            hideKeyboard();

            if (value.returnIsLoading()) {
              showSnackBar(context, 'Media is uploading, please be patient...',
                  color: Colors.grey[800]!);

              return;
            }

            if (transfer_info["comment_controller"].text.isEmpty) {
              showSnackBar(context, "Please add a comment",
                  color: Colors.grey[800]!);

              return;
            }

            // shows the loading widget
            value.toggleIsLoading();

            switch (transfer_info["transaction_type"]) {
              case "savings":
                // uploads media files to firebase
                // and creates the post afterwards
                await value.addCashToSavingsWithMedia(context, {
                  "comment": transfer_info["comment_controller"].text,
                  "aspect_ratio": transfer_info["aspect_ratio"],
                  "media_type": transfer_info["media_type"],
                  ...transfer_info
                });
                break;
              case "p2p transfer":
                // uploads media files to firebase
                // and creates the post afterwards
                await value.sendP2PWithMedia(context, {
                  "comment": transfer_info["comment_controller"].text,
                  "aspect_ratio": transfer_info["aspect_ratio"],
                  "media_type": transfer_info["media_type"],
                  ...transfer_info
                });
                break;
            }

            // hides the loading widget
            value.toggleIsLoading();
          },
          child: CircleAvatar(
            radius: 27,
            backgroundColor: Colors.green,
            child: !value.returnIsLoading()
                ? Image.asset(
                    "assets/send.png",
                    color: Colors.white,
                    height: 25,
                  )
                : const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    ),
  );
}

Widget uploadingMediaTextWidget(BuildContext context) {
  return Positioned(
    top: 0,
    child: Consumer<AttachProviderFunctions>(
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
                        value: double.parse(
                            value.returnUploadProgress().toString()),
                        backgroundColor: Colors.white24,
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

Widget commentTextfieldWidget(BuildContext context, Map body_info) {
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
        controller: body_info["comment_controller"],
        inputFormatters: [LengthLimitingTextInputFormatter(1000)],
        style: GoogleFonts.ubuntu(fontSize: 18, color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.transparent,
            child: Image.asset(
              "assets/comments.png",
              color: Colors.white,
              height: 25,
            ),
          ),
          contentPadding: const EdgeInsets.only(
            bottom: 15,
            right: 75,
            left: 35,
            top: 15,
          ),
          hintText: "Write a comment...",
          hintStyle: GoogleFonts.ubuntu(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    ),
  );
}

Widget selectMediaCard(BuildContext context, Map transaction_info) {
  return Consumer<AttachProviderFunctions>(
    builder: (_, value, child) {
      return SizedBox(
        width: width(context),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40),
              topLeft: Radius.circular(40),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                left: 30, right: 30, top: 30, bottom: Platform.isIOS ? 40 : 25),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async => await value.getMediaP2P(context, {
                      "media_type": "photo",
                      ...transaction_info,
                    }),
                    child: Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 23,
                            backgroundColor: Colors.grey[200],
                            child: Image.asset(
                              "assets/picture.png",
                              height: 25,
                              width: 25,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Attach a Photo",
                                style: GoogleFonts.ubuntu(
                                  color: const Color(0xFF616161),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                              hGap(2),
                              Text(
                                "Timeline post will have a photo",
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey[600],
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  hGap(20),
                  GestureDetector(
                    onTap: () async => await value.getMediaP2P(context, {
                      "media_type": "video",
                      ...transaction_info,
                    }),
                    child: Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 23,
                            backgroundColor: Colors.grey[200],
                            child: Image.asset(
                              "assets/movie.png",
                              height: 22,
                              width: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Attach a Video",
                                style: GoogleFonts.ubuntu(
                                  color: const Color(0xFF616161),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                              ),
                              hGap(2),
                              Text(
                                "Timeline post will have a video",
                                style: GoogleFonts.ubuntu(
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey[600],
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
