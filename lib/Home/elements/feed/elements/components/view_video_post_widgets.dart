import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

Widget actionButtons(
    BuildContext context, VideoPlayerController? vidController, Map postMap) {
  return Consumer<VideoProviderFunctions>(
    builder: (_, value, child) {
      return GestureDetector(
        onTap: () =>
            value.toggleShowActionButtons(!value.returnShowActionButtons()),
        child: Container(
          width: width(context),
          height: height(context),
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
          child: !value.returnShowActionButtons()
              ? const SizedBox()
              : Column(
                  children: [
                    const Spacer(),
                    playPauseButton(context, vidController),
                    const SizedBox(height: 10),
                    progressBar(vidController),
                    const SizedBox(height: 20),
                  ],
                ),
        ),
      );
    },
  );
}

Widget playPauseButton(
    BuildContext context, VideoPlayerController? vidController) {
  return GestureDetector(
    onTap: () =>
        context.read<VideoProviderFunctions>().playPauseVideo(vidController),
    child: Container(
      width: width(context),
      alignment: Alignment.centerLeft,
      child: vidController!.value.isPlaying
          ? const Icon(Icons.pause, color: Colors.white, size: 30)
          : const Icon(Icons.play_arrow, color: Colors.white, size: 30),
    ),
  );
}

Widget backIcon(BuildContext context, VideoPlayerController? vidController) {
  return Consumer<VideoProviderFunctions>(
    builder: (_, value, child) {
      return Positioned(
        left: 20,
        top: 42.5,
        child: !value.returnShowActionButtons()
            ? const SizedBox()
            : GestureDetector(
                onTap: () async {
                  Navigator.pop(context);

                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                      overlays: SystemUiOverlay.values);

                  if (vidController == null) return;

                  await vidController.dispose();
                },
                child: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.black,
                  child: Icon(
                    Icons.arrow_back,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
      );
    },
  );
}

Widget userWidget(BuildContext context, Map postMap) {
  return Row(
    children: [
      postMap["post_owner_details"]["profile_image_url"] == "" || postMap["post_owner_details"]["profile_image_url"] == null
          ? Image.asset(
              "assets/ProfileAvatar.png",
              color: Colors.grey[300],
              height: 55,
            )
          : CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              backgroundImage: CachedNetworkImageProvider(
                postMap["post_owner_details"]["profile_image_url"],
              ),
            ),
      const SizedBox(width: 10),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${postMap["post_owner_details"]["first_name"]} ${postMap["post_owner_details"]["last_name"]}",
            style: googleStyle(
              weight: FontWeight.w500,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 5),
        ],
      )
    ],
  );
}

Widget progressBar(VideoPlayerController? vidController) {
  return Consumer<VideoProviderFunctions>(builder: (_, value, child) {
    return ProgressBar(
      barHeight: 3.0,
      thumbRadius: 5.0,
      thumbColor: Colors.red,
      progressBarColor: Colors.red,
      total: vidController!.value.duration,
      timeLabelType: TimeLabelType.totalTime,
      timeLabelLocation: TimeLabelLocation.below,
      baseBarColor: Colors.white.withOpacity(0.24),
      bufferedBarColor: Colors.white.withOpacity(0.24),
      progress: Duration(seconds: value.returnVideoPosition()),
      timeLabelTextStyle: const TextStyle(color: Colors.white),
      onSeek: (duration) => value.changeVideoPosition(duration, vidController),
    );
  });
}
