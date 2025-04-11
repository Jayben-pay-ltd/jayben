// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:jayben/Home/elements/feed/elements/my_posts_tile_widget.dart';
import 'package:jayben/Utilities/provider_functions.dart';

class MyPostsTile extends StatelessWidget {
  const MyPostsTile({super.key, required this.post_map});

  final Map post_map;

  @override
  Widget build(BuildContext context) {
    return post_map["is_published"]
        ? box("blocked_people") != null &&
                box("blocked_people").contains(post_map['user_id'])
            ? const SizedBox()
            : myPostTileBody(context, post_map)
        : nothing();
  }
}
