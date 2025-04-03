import 'package:cached_network_image/cached_network_image.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({Key? key, required this.commentDoc}) : super(key: key);

  final Map commentDoc;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width(context),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          commentDoc["comment_creator_details"]["profile_image_url"] == ""
              ? const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage("assets/ProfileAvatar.png"))
              : CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  backgroundImage: CachedNetworkImageProvider(
                      commentDoc["comment_creator_details"]
                          ["profile_image_url"])),
          const SizedBox(width: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${commentDoc["comment_creator_details"]["first_name"]} ${commentDoc["comment_creator_details"]["last_name"]}",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        fontSize: 17,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        "•",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Text(
                      timeago.format(DateTime.parse(commentDoc["created_at"])),
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  commentDoc["comment"].trim(),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ubuntu(
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
