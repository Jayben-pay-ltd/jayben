// ignore_for_file: non_constant_identifier_names

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:jayben/Home/elements/feed/elements/components/view_photo_post_widgets.dart';

class ViewPhotoPage extends StatefulWidget {
  const ViewPhotoPage({Key? key, required this.post_map}) : super(key: key);

  final Map post_map;

  @override
  State<ViewPhotoPage> createState() => _ViewPhotoPageState();
}

class _ViewPhotoPageState extends State<ViewPhotoPage> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.black,
        body: SafeArea(
          child: viewPhotoPageBody(
            this.context,
            widget.post_map,
          ),
        ),
      ),
    );
  }
}
