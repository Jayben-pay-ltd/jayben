// ignore_for_file: non_constant_identifier_names
import 'package:jayben/Home/elements/attach_media/components/attach_media_widgets.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AttachMediaPage extends StatefulWidget {
  const AttachMediaPage({Key? key, required this.transaction_info})
      : super(key: key);

  final Map transaction_info;

  @override
  State<AttachMediaPage> createState() => _AttachMediaPageState();
}

class _AttachMediaPageState extends State<AttachMediaPage> {
  @override
  void initState() {
    var prov = context.read<AttachProviderFunctions>();

    if (widget.transaction_info["media_type"] == "photo") return;

    prov.initializeVideo(prov.returnSelectedMedia()!);
    super.initState();
  }

  final comment_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Consumer<AttachProviderFunctions>(
        builder: (_, value, child) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.black,
            body: WillPopScope(
              onWillPop: () {
                if (widget.transaction_info["media_type"] == "video") {
                  value.returnVideoPlayerController()!.dispose();
                }

                goBack(context);
                return Future.value(false);
              },
              child: uploadMediaBody(context, {
                "aspect_ratio": widget.transaction_info["aspect_ratio"],
                "media_type": widget.transaction_info["media_type"],
                "comment_controller": comment_controller,
                ...widget.transaction_info,
              }),
            ),
          );
        },
      ),
    );
  }
}
