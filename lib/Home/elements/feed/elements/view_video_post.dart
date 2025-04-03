// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:jayben/Home/elements/feed/elements/components/view_video_post_widgets.dart';

class ViewVideoPage extends StatefulWidget {
  const ViewVideoPage({Key? key, required this.post_map}) : super(key: key);

  final Map post_map;

  @override
  State<ViewVideoPage> createState() => _ViewVideoPageState();
}

class _ViewVideoPageState extends State<ViewVideoPage> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    if (!mounted) return;

    dynamic prov = context.read<VideoProviderFunctions>();

    vidController = VideoPlayerController.network(widget.post_map["media_details"][0]["media_url"])
      ..initialize().then((_) {
        // updates the UI to show video
        setState(() => isInitialized = true);

        // updates the videos' progress bar
        vidController!.addListener(() async {
          prov.videoProgressListener(vidController);
        });
      })
      ..setLooping(true)
      ..play();

    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    if (vidController == null) return;
    await vidController!.dispose();
  }

  bool isInitialized = false;
  VideoPlayerController? vidController;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Consumer<VideoProviderFunctions>(
        builder: (_, value, child) {
          return !isInitialized
              ? loadingScreenPlainNoBackButton(context)
              : Scaffold(
                  backgroundColor: Colors.black,
                  body: WillPopScope(
                    onWillPop: () async {
                      Navigator.pop(context);

                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                          overlays: SystemUiOverlay.values);

                      await vidController!.dispose();

                      return false;
                    },
                    child: Container(
                      color: Colors.transparent,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                              aspectRatio: widget.post_map["media_details"][0]["aspect_ratio"],
                              child: VideoPlayer(vidController!)),
                          actionButtons(context, vidController, widget.post_map),
                          backIcon(context, vidController)
                        ],
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
