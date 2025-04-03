// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:jayben/Utilities/provider_functions.dart';
import 'package:jayben/Home/elements/feed/elements/feed_tile_widgets.dart';

class FeedTile extends StatelessWidget {
  const FeedTile({super.key, required this.post_map});

  final Map post_map;

  @override
  Widget build(BuildContext context) {
    return post_map["is_published"]
        ? box("BlockedPeople") != null &&
                box("BlockedPeople").contains(post_map['user_id'])
            ? const SizedBox()
            : feedTileBody(context, post_map)
        : nothing();
  }
}
