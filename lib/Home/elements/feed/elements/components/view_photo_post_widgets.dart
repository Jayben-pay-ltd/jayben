// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';

Widget viewPhotoPageBody(BuildContext context, Map post_info) {
  return Container(
    color: Colors.transparent,
    alignment: Alignment.center,
    padding: const EdgeInsets.symmetric(vertical: 30),
    child: Stack(
      alignment: Alignment.center,
      children: [
        mediaPreviewWidget(context, post_info["media_details"][0]["media_url"]),
        backButton(context)
      ],
    ),
  );
}

Widget backButton(BuildContext context) {
  return Consumer<VideoProviderFunctions>(
    builder: (_, value, child) {
      return Positioned(
        top: 20,
        left: 20,
        child: !value.returnShowActionButtons()
            ? const SizedBox()
            : GestureDetector(
                onTap: () => Navigator.pop(context),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[800]!,
                  child: const Icon(
                    color: Colors.white,
                    Icons.arrow_back,
                    size: 30,
                  ),
                ),
              ),
      );
    },
  );
}

Widget mediaPreviewWidget(BuildContext context, String photoUrl) {
  return Consumer<VideoProviderFunctions>(
    builder: (_, value, child) {
      return GestureDetector(
        onTap: () =>
            value.toggleShowActionButtons(!value.returnShowActionButtons()),
        child: Container(
          color: Colors.black,
          width: width(context),
          height: height(context),
          alignment: Alignment.center,
          child: InteractiveViewer(
            maxScale: 2,
            minScale: 0.5,
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(100),
            child: CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.fill,
            ),
          ),
        ),
      );
    },
  );
}
