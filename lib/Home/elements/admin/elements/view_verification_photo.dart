// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/general_widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ViewVerificationPhotoPage extends StatefulWidget {
  const ViewVerificationPhotoPage({Key? key, required this.image})
      : super(key: key);

  final String image;

  @override
  State<ViewVerificationPhotoPage> createState() => _ViewPhotoPageState();
}

class _ViewPhotoPageState extends State<ViewVerificationPhotoPage> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Container(
              color: Colors.black,
              width: width(context),
              height: height(context),
              alignment: Alignment.center,
              child: InteractiveViewer(
                maxScale: 2,
                minScale: 0.5,
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(1000),
                child: CachedNetworkImage(
                  imageUrl: widget.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            backButton(context)
          ],
        ),
      ),
    );
  }
}
