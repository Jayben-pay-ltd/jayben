// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names
import 'package:jayben/Utilities/provider_functions.dart';

import 'components/view_media_page_widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ViewMediaPage extends StatefulWidget {
  const ViewMediaPage({Key? key, required this.message_info}) : super(key: key);

  final Map message_info;

  @override
  State<ViewMediaPage> createState() => _ViewMediaPageState();
}

class _ViewMediaPageState extends State<ViewMediaPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.message_info["message_type"] == "Photo") return;

    vidController =
        VideoPlayerController.networkUrl(widget.message_info["media_url"])
          ..initialize()
              .then((value) => setState(() => videoIsInitialized = true))
          ..setLooping(true)
          ..play();
  }

  VideoPlayerController? vidController;
  bool videoIsInitialized = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.black,
        body: WillPopScope(
          onWillPop: () async {
            if (vidController != null) {
              await vidController!.dispose();
            }

            goBack(context);
            return Future.value(false);
          },
          child: viewMediaMessageBody(
            context,
            {
              "aspect_ratio": widget.message_info["aspect_ratio"],
              "message_type": widget.message_info["message_type"],
              "media_url": widget.message_info["media_url"],
              "videoIsInitialized": videoIsInitialized,
              "video_controller": vidController,
            },
          ),
        ),
      ),
    );
  }
}
