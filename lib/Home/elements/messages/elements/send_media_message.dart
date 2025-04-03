import 'package:jayben/Home/elements/messages/elements/components/send_media_message_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class CreateMediaMessagePage extends StatefulWidget {
  const CreateMediaMessagePage(
      {Key? key,
      required this.mediaFile,
      required this.mediaType,
      required this.aspectRatio,
      required this.groupInfo})
      : super(key: key);

  final Map groupInfo;
  final File mediaFile;
  final String mediaType;
  final double aspectRatio;

  @override
  State<CreateMediaMessagePage> createState() => _CreateMediaMessagePageState();
}

class _CreateMediaMessagePageState extends State<CreateMediaMessagePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    if (widget.mediaType == "photo") return;
    context.read<MessageProviderFunctions>().initializeVideo(widget.mediaFile);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  final captionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.black,
        body: WillPopScope(
          onWillPop: () {
            if (widget.mediaType == "video") {
              context
                  .read<MessageProviderFunctions>()
                  .returnVideoPlayerController()!
                  .dispose();
            }

            Navigator.pop(context);
            return Future.value(false);
          },
          child: createMediaMessageBody(
            context,
            {
              "caption_controller": captionController,
              "aspect_ratio": widget.aspectRatio,
              "message_type": widget.mediaType,
              "media_type": widget.mediaType,
              "media_file": widget.mediaFile,
              ...widget.groupInfo,
            },
          ),
        ),
      ),
    );
  }
}
