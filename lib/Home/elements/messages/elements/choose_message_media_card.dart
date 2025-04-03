// ignore_for_file: non_constant_identifier_names

import 'dart:io';

import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Utilities/constants.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ChooseMediaCard extends StatefulWidget {
  const ChooseMediaCard({Key? key, required this.chatroom_info})
      : super(key: key);

  // 1 on 1 room row or group row
  final Map chatroom_info;

  @override
  State<ChooseMediaCard> createState() => _ChooseMediaCardState();
}

class _ChooseMediaCardState extends State<ChooseMediaCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProviderFunctions>(
      builder: (_, value, child) {
        return SizedBox(
          width: width(context),
          child: Container(
            decoration: cardDecor(),
            padding: EdgeInsets.only(
              bottom: Platform.isIOS ? 40 : 25,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ListTile(
                //   onTap: () => value.getMedia(
                //     context,
                //     {
                //       ...widget.chatroom_info,
                //       "media_type": "money",
                //     },
                //   ),
                //   leading: CircleAvatar(
                //     radius: 30,
                //     backgroundColor: Colors.grey[200],
                //     child: Image.asset(
                //       "assets/money.png",
                //       height: 35,
                //     ),
                //   ),
                //   title: Text(
                //     "Send Money",
                //     style: googleStyle(
                //       weight: FontWeight.w400,
                //       color: Colors.black,
                //       size: 18,
                //     ),
                //   ),
                // ),
                // hGap(15),
                // ListTile(
                //   onTap: () => value.getMedia(
                //     context,
                //     {
                //       ...widget.chatroom_info,
                //       "media_type": "gift",
                //     },
                //   ),
                //   leading: CircleAvatar(
                //     radius: 30,
                //     backgroundColor: Colors.grey[200],
                //     child: Image.asset(
                //       "assets/gift-box.png",
                //       height: 29,
                //     ),
                //   ),
                //   title: Text(
                //     "Send Gift",
                //     style: googleStyle(
                //       weight: FontWeight.w400,
                //       color: Colors.black,
                //       size: 18,
                //     ),
                //   ),
                // ),
                // hGap(15),
                ListTile(
                  onTap: () => value.getMedia(
                    context,
                    {
                      ...widget.chatroom_info,
                      "media_type": "video",
                    },
                  ),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    child: Image.asset(
                      "assets/movie.png",
                      height: 29,
                    ),
                  ),
                  title: Text(
                    "Send Video",
                    style: googleStyle(
                      weight: FontWeight.w400,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ),
                hGap(15),
                ListTile(
                  onTap: () => value.getMedia(
                    context,
                    {
                      ...widget.chatroom_info,
                      "media_type": "photo",
                    },
                  ),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[200],
                    child: Image.asset(
                      "assets/picture.png",
                      height: 29,
                    ),
                  ),
                  title: Text(
                    "Send Photo",
                    style: googleStyle(
                      weight: FontWeight.w400,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Decoration cardDecor() {
    return const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(40),
        topLeft: Radius.circular(40),
      ),
    );
  }
}
